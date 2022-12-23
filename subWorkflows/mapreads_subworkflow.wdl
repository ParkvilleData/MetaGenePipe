import "./tasks/matching_contigs_reads.wdl" as matchingTask
import "./tasks/mapreads.wdl" as mapreadsTask

workflow mapreads_subworkflow {
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
  Boolean concatenateBoolean
  Array[File?]? non_merged_contigs 
  File? merged_contigs
  Array[Pair[File?, File?]] pairReads

  ## matching of contigs and reads before read alignment
  ## This task is needed to match each sample to the assembled contigs, even in the case where the samples were merged
  scatter (reads in pairReads) {
    call matchingTask.matching_contigs_reads_task {
      input:
        merged_contigs = merged_contigs,
        non_merged_contigs = non_merged_contigs,
        forwardReads = reads.left,
        reverseReads = reads.right,
        concatenateBoolean = concatenateBoolean
    }
  }

  ## read alignment task
  scatter (matchmap in matching_contigs_reads_task.matchedclr) {
    call mapreadsTask.mapreads_task {
      input:
        Inputmap = matchmap
    }
  }

  output {
    Array[File?]? sampleSamOutput = mapreads_task.sampleSamOutput
    Array[File?]? sampleSortedBam = mapreads_task.sampleSortedBam
    Array[File?]? sampleFlagstatText = mapreads_task.sampleFlagstatText
  }
}

