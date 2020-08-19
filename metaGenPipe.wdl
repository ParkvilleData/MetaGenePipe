## Metagenomics pipeline 15/08/19
## MDAP Team Verbruggen
## 
## Melbourne Integrative Genomics
## Updated on 02/09/19
## Metagenomics pipeline as per phase 4 testing notes


## import subworkflows
import "./subWorkflows/qc_subworkflow.wdl" as qcSubWorkflow


workflow metaGenPipe {

## global variables for wdl workflow
## input files
File inputSamplesFile
Array[Array[File]] inputSamples = read_tsv(inputSamplesFile)

## boolean variables 
Boolean flashBoolean

   scatter (sample in inputSamples) {

	call qcSubWorkflow.qc_subworkflow {
	input:
		forwardReads = sample[1],
		reverseReads = sample[2],
		flashBoolean = flashBoolean,
		sampleName = sample[0]
	}
   }
   ## end qc subworkflow
   
	## call multiqc after the qc workflow on all fastqc output
	#call filtering_tasks.multiqc_task {
        #    input:
        #        fastqcArray = fastqc_task.fastqcArray,
        #        sampleName = sampleName
        #}
	

	#if (merge) {
	#	call mergeDatasetSubworkflow {
        #	}
	#}

	## XML parser to be run outside of scatter

	output {
		Array[Array[File]] fastqcArray = qc_subworkflow.fastqcArray
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

