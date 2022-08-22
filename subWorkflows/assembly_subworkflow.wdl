import "./tasks/megahit.wdl" as megahitTask
import "./tasks/blast.wdl" as blastTask
import "./tasks/matching_contigs_reads.wdl" as matchingTask
import "./tasks/readalignment.wdl" as readalignTask

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
  Boolean megahitBoolean
  Boolean blastBoolean
  Boolean readalignBoolean
  Boolean mergeBoolean
  File trimmedReadsFwd
  File trimmedReadsRev
  File megaGraph
  Int numOfHits
  String? outputPrefix
  String bparser
  String database
  String preset

  if(megahitBoolean){
    call megahitTask.megahit_task {
      input: 
      preset=preset,
      megaGraph = megaGraph,
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
        inputScaffolds = megahit_task.assemblyOutput
    }
  }

  output {
    File? assemblyScaffolds = megahit_task.assemblyOutput
    File? parsedBlast = blast_task.parsedOutput
    File? blastOutput = blast_task.blastOutput
    File? assemblyGraph = megahit_task.assemblyGraph
    Array[File]? assemblyFastaArray = megahit_task.assemblyFastaArray
  }
}
