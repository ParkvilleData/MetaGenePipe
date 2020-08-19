import diamond
import prodigal
import collation_task

workflow geneprediction_subworkflow {
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

	call genePredictionTask.geneprediction_task {

            input: sampleName=sample[0],
		   outputDir=outputDir,
		   megahitOutputTranscripts=megahit_task.megahitOutput,
		   workingDir=workingDir

        }
	
	 call diamondTask.diamond_task {

            input: database=DB,sampleName=sample[0],
		   outputDir=outputDir,
		   genesAlignmentOutput=geneprediction_task.proteinAlignmentOutput,
		   workingDir=workingDir
        }
		
	call collationTask.collation_task {

            input: sampleName=sample[0],
		   outputDir=outputDir,
		   inputXML=diamond_task.diamondOutput,
		   workingDir=workingDir
        }
}
