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
import "./tasks/readalignment.wdl" as readalignTask
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
	String preset

	## boolean variables 
	Boolean flashBoolean
	Boolean mergeBoolean
	Boolean megahitBoolean
	Boolean idbaBoolean
	Boolean metaspadesBoolean
	Boolean blastBoolean
	Boolean taxonBoolean
	Boolean hostRemovalBoolean
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

	
	## If merge dataset is set to true
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

		call assemblySubWorkflow.assembly_subworkflow {
			input:
			idbaBoolean = idbaBoolean,
			preset = preset,
			metaspadesBoolean = metaspadesBoolean,
			megahitBoolean = megahitBoolean,
			blastBoolean = blastBoolean,
			trimmedReadsFwd = merge_task.trimmedReadsFwd,
			trimmedReadsRev = merge_task.trimmedReadsRev,
			numOfHits = numOfHits,
			bparser = bparser,
			database = database
		}

		call genepredictionSubWorkflow.geneprediction_subworkflow {
			input:
			assemblyScaffolds = assembly_subworkflow.assemblyScaffolds,
			outputType=outputType,
			blastMode=blastMode,
			maxTargetSeqs=maxTargetSeqs,
			outputPrefix = mergedOutput,
			mode=mode,
			DB=DB
		}
	} ## end merge dataset

	## check to see if the input is hostremoved or regular                                                            
        Int mergeArrayLength = length(select_all( hostremoval_subworkflow.hostRemovedFwdReads))

        Array[Pair[File?, File?]] pairReads = if mergeArrayLength > 0 then zip(hostremoval_subworkflow.hostRemovedFwdReads, hostremoval_subworkflow.hostRemovedRevReads) else zip(qc_subworkflow.trimmedFwdReads, qc_subworkflow.trimmedRevReads)

	## if merge dataset is set to false: Includes scatter but same tasks
	if(!mergeBoolean) {

	   ## check to see if the input is hostremoved or regular
	   Int mergeArrayLength = length(select_all( hostremoval_subworkflow.hostRemovedFwdReads))

	   Array[Pair[File, File]] pairReads = zip(qc_subworkflow.trimmedFwdReads, qc_subworkflow.trimmedRevReads)
	   Array[Pair[File?, File?]] pairHostRemReads = zip(hostremoval_subworkflow.hostRemovedFwdReads, hostremoval_subworkflow.hostRemovedRevReads)
	  
	   scatter (reads in pairReads) {
		call assemblySubWorkflow.assembly_subworkflow as nonMergedAssembly {
			input:
				idbaBoolean = idbaBoolean,
				preset = preset,
				metaspadesBoolean = metaspadesBoolean,
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
				outputType=outputType,
				blastMode=blastMode,
				maxTargetSeqs=maxTargetSeqs,
				mode=mode,
				DB=DB
			}
		} ## end scatter
	} ## end don't merge datasets

	if (readalignBoolean) {

          if (mergeBoolean) {
            scatter (reads in pairReads) {
	            call readalignTask.readalignment_task {
                        input:
		      		finalContigs = assembly_subworkflow.assemblyScaffolds,
                                forwardReads = reads.left,
		      		reverseReads = reads.right,
                                sampleName = reads.left
             	    }
            }
          }

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
		Array[File?] trimmedFwdUnpairedArray = qc_subworkflow.trimmedFwdUnpaired
		Array[File?] trimmedRevUnpairedArray = qc_subworkflow.trimmedRevUnpaired

		## Removed for now add later if output required
		Array[File?] flashArray = qc_subworkflow.flashExtFrags
		File? flashReadsRevComb = merge_task.flashReadsRevComb
		File? trimmedReadsFwd = merge_task.trimmedReadsFwd
		File? trimmedReadsRev = merge_task.trimmedReadsRev 

		## Assembly output
		File? assemblyScaffolds = assembly_subworkflow.assemblyScaffolds
		File? parsedBlast = assembly_subworkflow.parsedBlast
		File? blastOutput = assembly_subworkflow.blastOutput

		## Non merged Assembly
		Array[File?]? assemblyScaffoldsArray = nonMergedAssembly.assemblyScaffolds
		Array[File?]? parsedBlastArray = nonMergedAssembly.parsedBlast
		Array[File?]? blastOutputArray = nonMergedAssembly.blastOutput

		## geneprediction output
		File? collationOutput = geneprediction_subworkflow.collationOutput
		File? diamondOutput = geneprediction_subworkflow.diamondOutput
		File? proteinAlignmentOutput = geneprediction_subworkflow.proteinAlignmentOutput
		File? nucleotideGenesOutput = geneprediction_subworkflow.nucleotideGenesOutput
		File? potentialGenesAlignmentOutput = geneprediction_subworkflow.potentialGenesAlignmentOutput
		File? genesAlignmentOutput = geneprediction_subworkflow.genesAlignmentOutput

		## Non merged gene prediction
		Array[File]? collationOutputArray = nonMergedGenePrediction.collationOutput
		Array[File]? diamondOutputArray = nonMergedGenePrediction.diamondOutput
		Array[File]? proteinAlignmentOutputArray = nonMergedGenePrediction.proteinAlignmentOutput
		Array[File]? nucleotideGenesOutputArray = nonMergedGenePrediction.nucleotideGenesOutput
		Array[File]? potentialGenesAlignmentOutputArray = nonMergedGenePrediction.potentialGenesAlignmentOutput
		Array[File]? genesAlignmentOutputArray = nonMergedGenePrediction.genesAlignmentOutput

	  	## Read alignment output                                                                                  
                Array[File?]? sampleSamOutput = readalignment_task.sampleSamOutput
                Array[File?]? sampleSortedBam = readalignment_task.sampleSortedBam
	  	Array[File?]? sampleFlagstatText = readalignment_task.sampleFlagstatText

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
## end of workflow metaGenPipe
