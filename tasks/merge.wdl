task merge_task {
  Array[File?] readsToMergeFlash
  Array[File] readsToMergeFwd
  Array[File] readsToMergeRev
  Array[File?] hostRemFwdReads
  Array[File?] hostRemRevReads
  Int MGS_threads
  Int MGS_minutes
  Int MGS_mem
  Int mergeArray = length(select_all(readsToMergeFwd))
  Int hostMergeArray = length(select_all(hostRemFwdReads))

  command {
    mkdir -p ./data/merged
    if [[ ${hostMergeArray} > 0 ]]
      then
        cat ${sep = ' ' hostRemFwdReads} > ./data/merged/merged_R1.fq.gz
        cat ${sep = ' ' hostRemRevReads} > ./data/merged/merged_R2.fq.gz
      else
        cat ${sep = ' ' readsToMergeFwd} > ./data/merged/merged_R1.fq.gz
        cat ${sep = ' ' readsToMergeRev} > ./data/merged/merged_R2.fq.gz
    fi
  }
  runtime {
    runtime_minutes: '${MGS_minutes}'
    cpus: '${MGS_threads}'
    mem: '${MGS_mem}'
  }
  output {
    File? flashReadsFwdComb = "./data/merged/flash_R1.fq.gz"
    File? flashReadsRevComb = "./data/merged/flash_R2.fq.gz"
    File mergedReadsFwd = "./data/merged/merged_R1.fq.gz"
    File mergedReadsRev = "./data/merged/merged_R2.fq.gz"
  }        
  meta {
    author: "Bobbie Shaban"
    email: "bshaban@unimelb.edu.au"
    description: "<DESCRIPTION>"
  }
  parameter_meta {
    # Inputs:
    forwardReads: "itype:fastq: Forward reads in read pair"
    reverseReads: "itype:fastq: Reverse reads in read pair"
    # Outputs:
    fastqcArray: "otype:glob: All the zip files output"
  }
}



