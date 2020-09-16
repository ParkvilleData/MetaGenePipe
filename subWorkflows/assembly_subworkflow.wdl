import "./tasks/idba.wdl" as idbaTask
import "./tasks/megahit.wdl" as megahitTask
import "./tasks/metaspades.wdl" as metaspadesTask
import "./tasks/blast.wdl" as blastTask

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

### input variables
Boolean idbaBoolean
Boolean megahitBoolean
Boolean metaspadesBoolean
Boolean blastBoolean
File trimmedReadsFwdComb 
File trimmedReadsRevComb
Int numOfHits
String outputPrefix
String bparser
String database

  if(idbaBoolean) {
    call idbaTask.idba_task {
	input: 
	    outputPrefix=outputPrefix,
	    trimmedReadsFwdComb = trimmedReadsFwdComb,
	    trimmedReadsRevComb = trimmedReadsRevComb
    }
  }

   if(megahitBoolean){
     call megahitTask.megahit_task {
	input: 
	    outputPrefix=outputPrefix,
            trimmedReadsFwdComb = trimmedReadsFwdComb,
            trimmedReadsRevComb = trimmedReadsRevComb
	}
    }

   if(metaspadesBoolean){
     call metaspadesTask.metaspades_task {
	input:	
	    outputPrefix=outputPrefix,
            trimmedReadsFwdComb = trimmedReadsFwdComb,
            trimmedReadsRevComb = trimmedReadsRevComb
	}
   }

    if(blastBoolean) {
    	call blastTask.blast_task {
	 input:
	    outputPrefix=outputPrefix,
	    bparser = bparser,
	    numOfHits = numOfHits,
	    database = database,
	    inputScaffolds = megahit_task.megahitOutput 
        }
    }

    output {
	File? megahitScaffolds = megahit_task.megahitOutput
	File? megahitOutput = megahit_task.megahitOutput
	File? parsedBlast = blast_task.parsedOutput
	File? blastOutput = blast_task.blastOutput
    }
}
