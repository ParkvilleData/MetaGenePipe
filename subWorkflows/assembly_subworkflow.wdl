import idba
import megahit
import metaspades

workflow assembly_subworkflow {
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

##IMPORT boolean variables
Boolean IDBArun = true

  if(IDBA) {
    call idbaTask.idba_task {

	   input: sampleName=sample[0],
		  cleanFastq=sequence_removal_task.hostRemovalOutput
	
	}
}

    call megahitTask.megahit_task {

	    input: sampleName=sample[0],
		   outputDir=outputDir,
		   deconseqReadFile=hostremoval_task.hostRemovalOutput,
		   workingDir=workingDir	
	}

    call blastTask.blast_task {

           input: numOfHits=numOfHits,
		  blast=blast,
		  sampleName=sample[0],
		  scriptsDirectory=scriptsDirectory,
		  database=ntDatabase,
		  inputScaffolds=idba_task.scaffoldFasta,
		  numOfHits=numOfHits,
		  bparser=bparser,
		  workingDir=workingDir

    }

}
