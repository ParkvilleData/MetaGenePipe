import "./tasks/diamond.wdl" as diamondTask
import "./tasks/prodigal.wdl" as prodigalTask
import "./tasks/collation.wdl" as collationTask
import "./tasks/hmmer.wdl" as hmmerTask
import "./tasks/hmmer_taxon.wdl" as hmmerTaxonTask

workflow geneprediction_subworkflow {

  ### Imported files #####
  Boolean hmmerBoolean
  Boolean mergeBoolean
  Boolean taxonBoolean
  File DB
  File? assemblyScaffolds
  File hmmerDB
  File xml_parser
  File hmm_parser
  Int maxTargetSeqs
  Int outputType
  String? outputPrefix
  String blastMode
  String? metaOption
  String briteList
  String briteJson
  String outputFileName


  meta {
    author: "Bobbie Shaban"
    email: "bshaban@unimelb.edu.au"
    description: "<DESCRIPTION>"
  }
  parameter_meta {
    # Inputs:
    Input1: "itype:<TYPE>: <DESCRIPTION>"
    # Outputs:
    Output1: "otype:<TYPE>: <DESCRIPTION>"
  }
  call prodigalTask.prodigal_task {
    input: 
    outputPrefix=outputPrefix,
    metaOption=metaOption,
    assemblyScaffolds=assemblyScaffolds
  }
  
  #if hmmer boolean = true run hmmer else run diamond
  if(hmmerBoolean){
    call hmmerTask.hmmer_task{
      input:
      outputPrefix=outputPrefix,
      proteinAlignmentOutput=prodigal_task.proteinAlignmentOutput,
      hmmerDB=hmmerDB      
    }
  }

  call diamondTask.diamond_task {
    input: 
    DB=DB,
    outputPrefix=outputPrefix,
    maxTargetSeqs=maxTargetSeqs,
    outputType=outputType,
    blastMode=blastMode,
    genesAlignmentOutput=prodigal_task.proteinAlignmentOutput
  }
    
  call collationTask.collation_task {
    input: 
    outputPrefix=outputPrefix,
    inputXML=diamond_task.diamondOutput
  }

   if (taxonBoolean) {
     if (mergeBoolean){
        call hmmerTaxonTask.hmmer_taxon_task as hmmerMergedTaxon {
           input:
           hmmerTable=hmmer_task.hmmerTable,
           diamondXML=collation_task.collationOutput,
           xml_parser=xml_parser,
           hmm_parser=hmm_parser,
           briteList=briteList,
           briteJson=briteJson,
           outputFileName=outputFileName
        }
      }
      if (!mergeBoolean) {
        call hmmerTaxonTask.hmmer_taxon_task {
          input:
            hmmerTables=hmmer_task.hmmerTable,
            diamondXMLs=collation_task.collationOutput,
            xml_parser=xml_parser,
            hmm_parser=hmm_parser,
            briteList=briteList,
            briteJson=briteJson,
            outputFileName=outputFileName
        }
      }
    }

  output {
    File? collationOutput = collation_task.collationOutput
    File? diamondOutput = diamond_task.diamondOutput
    File proteinAlignmentOutput = prodigal_task.proteinAlignmentOutput 
    File nucleotideGenesOutput = prodigal_task.nucleotideGenesOutput 
    File potentialGenesAlignmentOutput = prodigal_task.potentialGenesAlignmentOutput
    File genesAlignmentOutput = prodigal_task.genesAlignmentOutput
    File? hmmerTable = hmmer_task.hmmerTable
    File? hmmerOutput = hmmer_task.hmmerOutput
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
}
