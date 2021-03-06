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

## import tasks
import "./tasks/multiqc.wdl" as multiqcTask
import "./tasks/merge.wdl" as mergeTask
import "./tasks/matching_contigs_reads.wdl" as matchingTask
import "./tasks/readalignment.wdl" as readalignTask
import "./tasks/hmmer_taxon.wdl" as hmmerTaxonTask

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
  String briteJson
  String mergedOutput
  String bparser
  String database
  String DB
  String blastMode
  String outputFileName
  String preset
  String? metaOption

  ## boolean variables 
  Boolean flashBoolean
  Boolean mergeBoolean
  Boolean megahitBoolean
  Boolean blastBoolean
  Boolean taxonBoolean
  Boolean trimmomaticBoolean
  Boolean trimGaloreBoolean
  Boolean readalignBoolean
  
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

  Array[File] mQCArray = flatten(qc_subworkflow.fastqcArray)

  ## call multiqc after the qc workflow on all fastqc output
  call multiqcTask.multiqc_task {
    input:
    fastqcArray = mQCArray
  }

  
  ## If merge dataset is set to true
  if (mergeBoolean) {
    call mergeTask.merge_task {
      input:
      readsToMergeFlash = qc_subworkflow.flashExtFrags,
      readsToMergeFwd = qc_subworkflow.trimmedFwdReads,
      readsToMergeRev = qc_subworkflow.trimmedRevReads
    }

    call assemblySubWorkflow.assembly_subworkflow {
      input:
      megaGraph = megaGraph,
      preset = preset,
      megahitBoolean = megahitBoolean,
      blastBoolean = blastBoolean,
      trimmedReadsFwd = merge_task.mergedReadsFwd,
      trimmedReadsRev = merge_task.mergedReadsRev,
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
      outputPrefix = mergedOutput,
      metaOption=metaOption,
      DB=DB
    }
  } ## end merge dataset

  Array[Pair[File?, File?]] pairReads = zip(qc_subworkflow.trimmedFwdReads, qc_subworkflow.trimmedRevReads)

  ## if merge dataset is set to false: Includes scatter but same tasks
  if(!mergeBoolean) {
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
        assemblyScaffolds = nonMergedAssembly.assemblyScaffolds,
        hmmerDB=hmmerDB,
        hmmerBoolean=hmmerBoolean,
        outputType=outputType,
        blastMode=blastMode,
        metaOption=metaOption,
        maxTargetSeqs=maxTargetSeqs,
        DB=DB
      }
    } ## end scatter
  } ## end don't merge datasets


  ## matching of contigs and reads before read alignment                 
  scatter (reads in pairReads) {
    call matchingTask.matching_contigs_reads_task {
      input:
        merged_Contigs = assembly_subworkflow.assemblyScaffolds,
        non_merged_Contigs = nonMergedAssembly.assemblyScaffolds,
        forwardReads = reads.left,
        reverseReads = reads.right,
        merge_opt = mergeBoolean
    }
  }

  ## read alignment task                                                 
  if (readalignBoolean) {
    scatter (matchmap in matching_contigs_reads_task.matchedclr) {
      call readalignTask.readalignment_task {
        input:
        Inputmap = matchmap
      }
    }
  }

  if (taxonBoolean) {
    if(mergeBoolean){
      call hmmerTaxonTask.hmmer_taxon_task as hmmerMergedTaxon {
        input:
        hmmerTable=geneprediction_subworkflow.hmmerTable,
        diamondXML=geneprediction_subworkflow.collationOutput,
        xml_parser=xml_parser,
        hmm_parser=hmm_parser,
        briteList=briteList,
        briteJson=briteJson,
        outputFileName=outputFileName
      }
    }
    if(!mergeBoolean){
      call hmmerTaxonTask.hmmer_taxon_task {
        input:
        hmmerTables=nonMergedGenePrediction.hmmerTable,
        diamondXMLs=nonMergedGenePrediction.collationOutput,
        xml_parser=xml_parser,
        hmm_parser=hmm_parser,
        briteList=briteList,
        briteJson=briteJson,
        outputFileName=outputFileName
      }
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
    File? flashReadsRevComb = merge_task.flashReadsRevComb
    File? mergedReadsFwd = merge_task.mergedReadsFwd
    File? mergedReadsRev = merge_task.mergedReadsRev 

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

    ## Read alignment output                                                                                  
    Array[File?]? sampleSamOutput = readalignment_task.sampleSamOutput
    Array[File?]? sampleSortedBam = readalignment_task.sampleSortedBam
    Array[File?]? sampleFlagstatText = readalignment_task.sampleFlagstatText

    ## Taxonomy output merged
    File? level1BriteMerged = hmmerMergedTaxon.level1Brite
    File? level2BriteMerged = hmmerMergedTaxon.level2Brite
    File? level3BriteMerged = hmmerMergedTaxon.level3Brite
    File? OTUMerged = hmmerMergedTaxon.OTU

    ## Taxonomy output unmerged
    File? level1Brite = hmmer_taxon_task.level1Brite
    File? level2Brite = hmmer_taxon_task.level2Brite
    File? level3Brite = hmmer_taxon_task.level3Brite
    File? OTU = hmmer_taxon_task.OTU
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
