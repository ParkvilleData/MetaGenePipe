## Metagenomics pipeline 15/08/19
## MDAP Team Verbruggen
## 
## Melbourne Integrative Genomics
## Updated on 02/09/19
## Metagenomics pipeline as per phase 4 testing notes


## import subworkflows
import "./subWorkflows/qc_subworkflow.wdl" as qcSubWorkflow
import "./subWorkflows/hostremoval_subworkflow.wdl" as hostRemovalSubWorkflow
import "./subWorkflows/assembly_subworkflow.wdl" as assemblySubWorkflow
import "./subWorkflows/geneprediction_subworkflow.wdl" as genepredictionSubWorkflow

## import tasks
import "./tasks/multiqc.wdl" as multiqcTask
import "./tasks/merge.wdl" as mergeTask
import "./tasks/taxon_class.wdl" as taxonTask


workflow metaGenPipe {

## global variables for wdl workflow
## input files
File inputSamplesFile
File xml_parser
File orgID_2_name
File interleaveShell
Array[Array[File]] inputSamples = read_tsv(inputSamplesFile)
Int numOfHits
Int maxTargetSeqs
Int outputType
Int identityPercentage
Int coverage
String multiQCoutput
String mergedOutput
String bparser
String database
String DB
String mode
String blastMode
String koFormattedFile
String keggSpeciesFile
String taxRankFile
String fullLineageFile
String outputFileName
String removalSequence

## boolean variables 
Boolean flashBoolean
Boolean mergeBoolean
Boolean megahitBoolean
Boolean idbaBoolean
Boolean metaspadesBoolean
Boolean blastBoolean
Boolean taxonBoolean
Boolean hostRemovalBoolean

   scatter (sample in inputSamples) {

	call qcSubWorkflow.qc_subworkflow {
	input:
		forwardReads = sample[1],
		reverseReads = sample[2],
		flashBoolean = flashBoolean,
		sampleName = sample[0]
	}

	## host removal before merge if chosen
        ## set array for host removal processing
        if (hostRemovalBoolean) {
                call hostRemovalSubWorkflow.hostremoval_subworkflow {
                        input:
                            flashBoolean = flashBoolean,
                            interleaveShell = interleaveShell,
                            identityPercentage = identityPercentage,
                            removalSequence = removalSequence,
                            coverage = coverage,
                            outputPrefix = mergedOutput,
                            hostRemovalFlash = qc_subworkflow.flashExtFrags,
			    sampleName = sample[0],
                            hostRemovalFwd = qc_subworkflow.trimmedFwdReads,
                            hostRemovalRev = qc_subworkflow.trimmedRevReads
                }
        }
   }
   ## end qc subworkflow

	Array[File] mQCArray = flatten(qc_subworkflow.fastqcArray)   

	## call multiqc after the qc workflow on all fastqc output
	call multiqcTask.multiqc_task {
            input:
                fastqcArray = mQCArray,
                outputPrefix = multiQCoutput
        }

	if (mergeBoolean) {
		call mergeTask.merge_task {
		    input:
			outputPrefix = mergedOutput,
			readsToMergeFlash = qc_subworkflow.flashExtFrags,
			readsToMergeFwd = qc_subworkflow.trimmedFwdReads,
			readsToMergeRev = qc_subworkflow.trimmedRevReads,
			hostRemFwdReads = hostremoval_subworkflow.hostRemovedFwdReads,
			hostRemRevReads = hostremoval_subworkflow.hostRemovedRevReads
        	}
	}

	call assemblySubWorkflow.assembly_subworkflow {
		input:
			idbaBoolean = idbaBoolean,
			metaspadesBoolean = metaspadesBoolean,
			megahitBoolean = megahitBoolean,
			blastBoolean = blastBoolean,
			trimmedReadsFwdComb = merge_task.trimmedReadsFwdComb,
			trimmedReadsRevComb = merge_task.trimmedReadsRevComb,	
			outputPrefix = mergedOutput,
			numOfHits = numOfHits,
			bparser = bparser,
			database = database
	}

	call genepredictionSubWorkflow.geneprediction_subworkflow {
		input:
			megahitScaffolds = assembly_subworkflow.megahitScaffolds,
			outputType=outputType,
			blastMode=blastMode,
			maxTargetSeqs=maxTargetSeqs,
			outputPrefix = mergedOutput,
			mode=mode,
			DB=DB
	}



	if (taxonBoolean) {
		call taxonTask.taxonclass_task{		
			input:
				collationArray=geneprediction_subworkflow.collationOutput,
				xml_parser=xml_parser,
				orgID_2_name=orgID_2_name,
				koFormattedFile=koFormattedFile,
				keggSpeciesFile=keggSpeciesFile,
				outputFileName=outputFileName,
				taxRankFile=taxRankFile,
				fullLineageFile=fullLineageFile			
		}
	}

	output {
		### QC output
		Array[Array[File]] fastqcArray = qc_subworkflow.fastqcArray
		File multiqcHTML = multiqc_task.multiqcHTML
		Array[File] trimmedFwdReadsArray = qc_subworkflow.trimmedFwdReads
                Array[File] trimmedRevReadsArray = qc_subworkflow.trimmedRevReads
                Array[File] trimmedFwdUnpairedArray = qc_subworkflow.trimmedFwdUnpaired
                Array[File] trimmedRevUnpairedArray = qc_subworkflow.trimmedRevUnpaired

		## Removed for now add later if output required
		Array[File?] flashArray = qc_subworkflow.flashExtFrags
		File? flashReadsRevComb = merge_task.flashReadsRevComb
		File? trimmedReadsFwdComb = merge_task.trimmedReadsFwdComb
		File? trimmedReadsRevComb = merge_task.trimmedReadsRevComb 

		## Assembly output
		File? megahitOutput = assembly_subworkflow.megahitOutput
		File? parsedBlast = assembly_subworkflow.parsedBlast
		File? blastOutput = assembly_subworkflow.blastOutput

		## geneprediction output
		File collationOutput = geneprediction_subworkflow.collationOutput
		File diamondOutput = geneprediction_subworkflow.diamondOutput
		File proteinAlignmentOutput = geneprediction_subworkflow.proteinAlignmentOutput
		File nucleotideGenesOutput = geneprediction_subworkflow.nucleotideGenesOutput
		File potentialGenesAlignmentOutput = geneprediction_subworkflow.potentialGenesAlignmentOutput
		File genesAlignmentOutput = geneprediction_subworkflow.genesAlignmentOutput

		## Taxonomy output
		File? functionalTable = taxonclass_task.functionalTable
                File? geneCounts =  taxonclass_task.geneCounts
                File? level1Brite = taxonclass_task.level1Brite
                File? level2Brite = taxonclass_task.level2Brite
                File? level3Brite = taxonclass_task.level3Brite
                File? mergedXml = taxonclass_task.mergedXml
                File? OTU = taxonclass_task.OTU

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
## end of worklfow metaGenPipe

