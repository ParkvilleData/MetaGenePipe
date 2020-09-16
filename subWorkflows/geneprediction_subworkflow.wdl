import "./tasks/diamond.wdl" as diamondTask
import "./tasks/prodigal.wdl" as prodigalTask
import "./tasks/collation.wdl" as collationTask

workflow geneprediction_subworkflow {

### Imported files #####
File DB
File? megahitScaffolds
Int maxTargetSeqs
Int outputType
String outputPrefix
String mode
String blastMode


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
		megahitScaffolds=megahitScaffolds
        }
	
	 call diamondTask.diamond_task {

            input: 
		DB=DB,
		outputPrefix=outputPrefix,
		maxTargetSeqs=maxTargetSeqs,
		mode=mode,
		outputType=outputType,
		blastMode=blastMode,
		genesAlignmentOutput=prodigal_task.proteinAlignmentOutput,        }
		
	call collationTask.collation_task {

            input: 
		outputPrefix=outputPrefix,
		inputXML=diamond_task.diamondOutput
        }

	output {
		 File collationOutput = collation_task.collationOutput
		 File diamondOutput = diamond_task.diamondOutput
		 File proteinAlignmentOutput = prodigal_task.proteinAlignmentOutput 
                 File nucleotideGenesOutput = prodigal_task.nucleotideGenesOutput 
                 File potentialGenesAlignmentOutput = prodigal_task.potentialGenesAlignmentOutput
		 File genesAlignmentOutput = prodigal_task.genesAlignmentOutput

	}
}
