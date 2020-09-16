import "./tasks/fastqc.wdl" as fastqcTask
import "./tasks/flash.wdl" as flashTask  
import "./tasks/multiqc.wdl" as multiqcTask
import "./tasks/trimmomatic.wdl" as trimTask

workflow qc_subworkflow {
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

#### File inputs
Boolean flashBoolean
File forwardReads
File reverseReads
String sampleName

	call fastqcTask.fastqc_task {
	    input:
		sampleName = sampleName,
		forwardReads = forwardReads,
		reverseReads = reverseReads
	}

	call trimTask.trimmomatic_task {
        input:
            forwardReads = forwardReads,
            reverseReads  = reverseReads,
            outputPrefix = sampleName,
            forwardReads = forwardReads,
            reverseReads = reverseReads
        }
	
	## if flash boolean is true merge reads
	if( flashBoolean ) {
		call flashTask.flash_task {
       		     input: forwardReads=forwardReads,
			   reverseReads=reverseReads,
			   sampleName=sampleName
		}
	}

	output {
		Array[File] fastqcArray = fastqc_task.fastqcArray
		File? flashExtFrags = flash_task.extendedFrags
		File trimmedFwdReads = trimmomatic_task.outFwdPaired 
		File trimmedRevReads = trimmomatic_task.outRevPaired
		File trimmedFwdUnpaired = trimmomatic_task.outFwdUnpaired
		File trimmedRevUnpaired = trimmomatic_task.outRevUnpaired
	}

}
