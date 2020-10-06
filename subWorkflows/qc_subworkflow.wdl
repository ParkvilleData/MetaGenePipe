import "./tasks/fastqc.wdl" as fastqcTask
import "./tasks/flash.wdl" as flashTask  
import "./tasks/multiqc.wdl" as multiqcTask
import "./tasks/trim_galore.wdl" as trimgaloreTask

workflow qc_subworkflow {
    meta {
        author: "Bobbie Shaban, Mar Quiroga"
        email: "bshaban@unimelb.edu.au, mquiroga@unimelb.edu.au"
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

	call trimgaloreTask.trim_galore_task {
		input:
		forwardReads = forwardReads,
		reverseReads = reverseReads,
		outputPrefix = sampleName
	}

	call fastqcTask.fastqc_task {
	    input:
		forwardReads = trim_galore_task.outFwdPaired,
		reverseReads = trim_galore_task.outRevPaired
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
		File trimmedFwdReads = trim_galore_task.outFwdPaired 
		File trimmedRevReads = trim_galore_task.outRevPaired
	}

}
