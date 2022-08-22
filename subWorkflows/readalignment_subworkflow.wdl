import "./tasks/matching_contigs_reads.wdl" as matchingTask
import "./tasks/readalignment.wdl" as readalignTask

workflow readalignment_subworkflow {
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
  Boolean readalignBoolean
  Boolean mergeBoolean
  File? non_merged_Contigs 
  File? merged_Contigs
  Array[Pair[File?, File?]] pairReads

  ## matching of contigs and reads before read alignment
  if(mergeBoolean) {
    scatter (reads in pairReads) {
      call matchingTask.matching_contigs_reads_task {
        input:
          merged_Contigs = merged_Contigs,
          forwardReads = reads.left,
          reverseReads = reads.right,
          merge_opt = mergeBoolean
      }
    }


    ## read alignment task
    if (readalignBoolean) {
      scatter (matchmap in matching_contigs_reads_task.matchedclr) {
        call readalignTask.readalignment_task {
          input:
          Inputmap = matchmap
        }
      }
    }

  }

  ## matching of contigs and reads before read alignment for non merged approach
  if(!mergeBoolean) {
    scatter (reads in pairReads) {
      call matchingTask.matching_contigs_reads_task as non_merged_matching_contigs_reads_task {
        input:
          merged_Contigs = merged_Contigs,
          non_merged_Contigs = non_merged_Contigs,
          forwardReads = reads.left,
          reverseReads = reads.right,
          merge_opt = mergeBoolean
      }
    }

     ## read alignment task
     if (readalignBoolean) {
       scatter (matchmap in non_merged_matching_contigs_reads_task.matchedclr) {
         call readalignTask.readalignment_task as non_merged_readalignment_task {
           input:
           Inputmap = matchmap
         }
       }
     }
  }

  output {
    Array[File?]? sampleSamOutput = readalignment_task.sampleSamOutput
    Array[File?]? sampleSortedBam = readalignment_task.sampleSortedBam
    Array[File?]? sampleFlagstatText = readalignment_task.sampleFlagstatText
    Array[File?]? sampleSamOutputNonMerged = non_merged_readalignment_task.sampleSamOutput
    Array[File?]? sampleSortedBamNonMerged = non_merged_readalignment_task.sampleSortedBam
    Array[File?]? sampleFlagstatTextNonMerged = non_merged_readalignment_task.sampleFlagstatText
  }
}

