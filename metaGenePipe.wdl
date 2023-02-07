## Metagenomics pipeline 15/08/19
## MDAP Team Verbruggen
## 
## Melbourne Integrative Genomics
## Updated on 02/09/19
## Metagenomics pipeline as per phase 4 testing notes


## import subworkflows
import "./subWorkflows/qc_subworkflow.wdl" as qcSubWorkflow
import "./subWorkflows/assembly_subworkflow.wdl" as assemblySubWorkflow
import "./subWorkflows/geneprediction_subworkflow.wdl" as genepredictionSubWorkflow
import "./subWorkflows/mapreads_subworkflow.wdl" as mapreadsSubWorkflow

## import standalone tasks
import "./tasks/multiqc.wdl" as multiqcTask
import "./tasks/concatenate.wdl" as concatenateTask
import "./tasks/hmmer_taxon.wdl" as taxonTask

workflow metaGenePipe {

  ## global variables for wdl workflow
  ## input files
  Boolean hmmerBoolean
  File inputSamplesFile
  File xml_parser
  File hmm_parser
  File interleaveShell
  File hmmerDB
  File megaGraph
  Array[Array[File]] inputSamples = read_tsv(inputSamplesFile)
  Int numOfHits
  Int maxTargetSeqs
  Int outputType
  Int identityPercentage
  Int coverage
  String briteList
  String briteLineage
  String bparser
  String database
  String DB
  String blastMode
  String outputFileName
  String preset
  String? metaOption

  ## boolean variables 
  Boolean flashBoolean
  Boolean concatenateBoolean
  Boolean megahitBoolean
  Boolean blastBoolean
  Boolean taxonBoolean
  Boolean trimmomaticBoolean
  Boolean trimGaloreBoolean
  Boolean mapreadsBoolean
  
  scatter (sample in inputSamples) {
    
    call qcSubWorkflow.qc_subworkflow {
      input:
      forwardReads = sample[1],
      reverseReads = sample[2],
      flashBoolean = flashBoolean,
      sampleName = sample[0],
      trimmomaticBoolean = trimmomaticBoolean,
      trimGaloreBoolean = trimGaloreBoolean
    }
  ## end of qc subworkflow
  }

  Array[File] mQCArray = flatten(fastqcArray)

  ## call multiqc after the qc workflow on all fastqc output
  call multiqcTask.multiqc_task {
    input:
    fastqcArray = mQCArray
  }


  ## If concatenate dataset is set to true
  if (concatenateBoolean) {
    call concatenateTask.concatenate_task {
      input:
        readsToMergeFwd = qc_subworkflow.trimmedFwdReads,
        readsToMergeRev = qc_subworkflow.trimmedRevReads
    }

    call assemblySubWorkflow.assembly_subworkflow {
      input:
        megaGraph = megaGraph,
        preset = preset,
        megahitBoolean = megahitBoolean,
        blastBoolean = blastBoolean,
        trimmedReadsFwd = concatenate_task.mergedReadsFwd,
        trimmedReadsRev = concatenate_task.mergedReadsRev,
        numOfHits = numOfHits,
        bparser = bparser,
        database = database
    }

    call genepredictionSubWorkflow.geneprediction_subworkflow {
      input:
        hmmerDB = hmmerDB,
        hmmerBoolean = hmmerBoolean,
        assemblyScaffolds = assembly_subworkflow.assemblyScaffolds,
        outputType=outputType,
        blastMode=blastMode,
        maxTargetSeqs=maxTargetSeqs,
        metaOption=metaOption,
        DB=DB
    }

    if (taxonBoolean) {
      call taxonTask.hmmer_taxon_task {
        input:
        hmmerTable=geneprediction_subworkflow.hmmerTable,
        diamondXML=geneprediction_subworkflow.collationOutput,
        xml_parser=xml_parser,
        hmm_parser=hmm_parser,
        briteList=briteList,
        briteLineage=briteLineage,
        outputFileName=outputFileName
      }
    }
  } ## end merge dataset

  Array[Pair[File?, File?]] pairReads = zip(qc_subworkflow.trimmedFwdReads, qc_subworkflow.trimmedRevReads)

  ## if merge dataset is set to false: Includes scatter but same tasks
  if(!concatenateBoolean) {
    scatter (reads in pairReads) {
      call assemblySubWorkflow.assembly_subworkflow as nonMergedAssembly {
        input:
          megaGraph = megaGraph,
          preset = preset,
          megahitBoolean = megahitBoolean,
          blastBoolean = blastBoolean,
          trimmedReadsFwd = reads.left,
          trimmedReadsRev = reads.right,  
          numOfHits = numOfHits,
          bparser = bparser,
          database = database
      }

      call genepredictionSubWorkflow.geneprediction_subworkflow as nonMergedGenePrediction {
        input:
          hmmerDB=hmmerDB,
          hmmerBoolean=hmmerBoolean,
          assemblyScaffolds = nonMergedAssembly.assemblyScaffolds,
          outputType=outputType,
          blastMode=blastMode,
          maxTargetSeqs=maxTargetSeqs,
          metaOption=metaOption,
          DB=DB
      }
    } ## end scatter

    if (taxonBoolean) {
      call taxonTask.hmmer_taxon_task as taxonNonMerged {
        input:
          hmmerTables=nonMergedGenePrediction.hmmerTable,
          diamondXMLs=nonMergedGenePrediction.collationOutput,
          xml_parser=xml_parser,
          hmm_parser=hmm_parser,
          briteList=briteList,
          briteLineage=briteLineage,
          outputFileName=outputFileName
      }
    }

  } ## end don't merge datasets

  if(mapreadsBoolean) {
    call mapreadsSubWorkflow.mapreads_subworkflow {
      input:
          pairReads=pairReads,
          merged_contigs = assembly_subworkflow.assemblyScaffolds,
          non_merged_contigs = nonMergedAssembly.assemblyScaffolds,
          concatenateBoolean=concatenateBoolean
    }
  }

  output {
    ### QC output
    Array[Array[File]] fastqcArray = qc_subworkflow.fastqcArray
    File multiqcHTML = multiqc_task.multiqcHTML
    Array[File] trimmedFwdReadsArray = qc_subworkflow.trimmedFwdReads
    Array[File] trimmedRevReadsArray = qc_subworkflow.trimmedRevReads
    Array[File?] trimmedFwdUnpairedArray = qc_subworkflow.trimmedFwdUnpaired
    Array[File?] trimmedRevUnpairedArray = qc_subworkflow.trimmedRevUnpaired

    ## Removed for now add later if output required
    Array[File?] flashArray = qc_subworkflow.flashExtFrags
    File? mergedReadsFwd = concatenate_task.mergedReadsFwd
    File? mergedReadsRev = concatenate_task.mergedReadsRev 

    ## Assembly output
    File? assemblyScaffolds = assembly_subworkflow.assemblyScaffolds
    File? parsedBlast = assembly_subworkflow.parsedBlast
    File? blastOutput = assembly_subworkflow.blastOutput
    File? assemblyGraph = assembly_subworkflow.assemblyGraph
    Array[File]? assemblyFastaArray = assembly_subworkflow.assemblyFastaArray

    ## Non merged Assembly
    Array[File?]? assemblyScaffoldsArray = nonMergedAssembly.assemblyScaffolds
    Array[File?]? parsedBlastArray = nonMergedAssembly.parsedBlast
    Array[File?]? blastOutputArray = nonMergedAssembly.blastOutput
    Array[File?]? assemblyGraphs = nonMergedAssembly.assemblyGraph
    Array[Array[File]?]? assemblyFastaArrayNonMerged = nonMergedAssembly.assemblyFastaArray

    ## geneprediction output
    File? collationOutput = geneprediction_subworkflow.collationOutput
    File? diamondOutput = geneprediction_subworkflow.diamondOutput
    File? proteinAlignmentOutput = geneprediction_subworkflow.proteinAlignmentOutput
    File? nucleotideGenesOutput = geneprediction_subworkflow.nucleotideGenesOutput
    File? potentialGenesAlignmentOutput = geneprediction_subworkflow.potentialGenesAlignmentOutput
    File? genesAlignmentOutput = geneprediction_subworkflow.genesAlignmentOutput
    File? hmmerTable = geneprediction_subworkflow.hmmerTable
    File? hmmerOutput = geneprediction_subworkflow.hmmerOutput

    ## Non merged gene prediction
    Array[File?]? collationOutputArray = nonMergedGenePrediction.collationOutput
    Array[File?]? diamondOutputArray = nonMergedGenePrediction.diamondOutput
    Array[File]? proteinAlignmentOutputArray = nonMergedGenePrediction.proteinAlignmentOutput
    Array[File]? nucleotideGenesOutputArray = nonMergedGenePrediction.nucleotideGenesOutput
    Array[File]? potentialGenesAlignmentOutputArray = nonMergedGenePrediction.potentialGenesAlignmentOutput
    Array[File]? genesAlignmentOutputArray = nonMergedGenePrediction.genesAlignmentOutput
    Array[File?]? hmmerTableArray = nonMergedGenePrediction.hmmerTable
    Array[File?]? hmmerOutputArray = nonMergedGenePrediction.hmmerOutput

    ## Taxonomy output merged
    File? level1Brite = hmmer_taxon_task.level1Brite
    File? level2Brite = hmmer_taxon_task.level2Brite
    File? level3Brite = hmmer_taxon_task.level3Brite
    File? OTU = hmmer_taxon_task.OTU
    ## Taxonomy output non-merged
    File? level1BriteNonMerged = taxonNonMerged.level1Brite
    File? level2BriteNonMerged = taxonNonMerged.level2Brite
    File? level3BriteNonMerged = taxonNonMerged.level3Brite
    File? OTUNonMerged = taxonNonMerged.OTU

    ## Read alignment output                                                                                  
    Array[File?]? sampleSamOutput = mapreads_subworkflow.sampleSamOutput
    Array[File?]? sampleSortedBam = mapreads_subworkflow.sampleSortedBam
    Array[File?]? sampleFlagstatText = mapreads_subworkflow.sampleFlagstatText

  }
  meta {
    author: "Bobbie Shaban"
    email: "babak.shaban@unimelb.edu.au"
    description: "<DESCRIPTION>"
  }
  parameter_meta {
    # Inputs:
    Input1: "itype:<TYPE>: <DESCRIPTION>"
    # Outputs:
    Output1: "otype:<TYPE>: <DESCRIPTION>"
  }
}
## end of workflow metaGenPipe
