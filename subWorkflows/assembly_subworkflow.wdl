import "./tasks/idba.wdl" as idbaTask
import "./tasks/megahit.wdl" as megahitTask
import "./tasks/metahipmer.wdl" as metahipmerTask
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
  Boolean metahipmerBoolean
  Boolean metaspadesBoolean
  Boolean blastBoolean
  File trimmedReadsFwd
  File trimmedReadsRev
  File megaGraph
  Int numOfHits
  String? outputPrefix
  String bparser
  String database
  String preset

  if(idbaBoolean) {
    call idbaTask.idba_task {
      input:
      trimmedReadsFwd = trimmedReadsFwd,
      trimmedReadsRev = trimmedReadsRev
    }
  }

  if(megahitBoolean){
    call megahitTask.megahit_task {
      input: 
      preset=preset,
      megaGraph = megaGraph,
      trimmedReadsFwd = trimmedReadsFwd,
      trimmedReadsRev = trimmedReadsRev
    }
  }

  if(metahipmerBoolean){
    call metahipmerTask.metahipmer_task {
      input:
        trimmedReadsFwd = trimmedReadsFwd,
        trimmedReadsRev = trimmedReadsRev
    }
  }

  if(metaspadesBoolean){
    call metaspadesTask.metaspades_task {
      input:
        trimmedReadsFwd = trimmedReadsFwd,
        trimmedReadsRev = trimmedReadsRev
    }
  }

  if(blastBoolean) {
    call blastTask.blast_task {
      input:
        outputPrefix=outputPrefix,
        bparser = bparser,
        numOfHits = numOfHits,
        database = database,
        inputScaffolds = select_first([megahit_task.assemblyOutput, metahipmer_task.assemblyOutput, metaspades_task.assemblyOutput, idba_task.assemblyOutput])
    }
  }

  output {
    File assemblyScaffolds = select_first([megahit_task.assemblyOutput, metahipmer_task.assemblyOutput, metaspades_task.assemblyOutput, idba_task.assemblyOutput])
    File? parsedBlast = blast_task.parsedOutput
    File? blastOutput = blast_task.blastOutput
    File? assemblyGraph = megahit_task.assemblyGraph
    Array[File]? assemblyFastaArray = megahit_task.assemblyFastaArray
  }
}
