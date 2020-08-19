import interleave
import deconseq

workflow hostremoval_subworkflow {
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

	call interLeaveTask.interleave_task {

	    input: flashNotCombined1=flash_task.flashArray[1], 
		   flashNotCombined2=flash_task.flashArray[2], 
		   flashExtended=flash_task.flashArray[0], 
		   sampleName=sample[0], 
		   outputDir=outputDir,
		   workingDir=workingDir
	}

	 call hostRemovalTask.hostremoval_task {

            input: flashMergedFastq=interleave_task.flashMergedFastq,
		   sampleName=sample[0],outputDir=outputDir,
		   workingDir=workingDir,
		   removalSequence=removeMouseSequence
        }

	call hostRemovalTask.hostremoval_task as sequence_removal_task {

            input: flashMergedFastq=interleave_task.flashMergedFastq,
		   sampleName=sample[0],
		   outputDir=outputDir,
		   workingDir=workingDir,
		   removalSequence=removalSequence
        }
}
