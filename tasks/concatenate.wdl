task concatenate_task {
  Array[File?] readsToMergeFlash
  Array[File] readsToMergeFwd
  Array[File] readsToMergeRev
  Int MGS_threads
  Int MGS_minutes
  Int MGS_mem
  Int mergeArray = length(select_all(readsToMergeFwd))

  command {
    mkdir -p ./data
    cat ${sep = ' ' readsToMergeFwd} > ./data/combined_R1.fq.gz
    cat ${sep = ' ' readsToMergeRev} > ./data/combined_R2.fq.gz
  }
  runtime {
    runtime_minutes: '${MGS_minutes}'
    cpus: '${MGS_threads}'
    mem: '${MGS_mem}'
  }
  output {
    File? flashReadsFwdComb = "./data/combined_flash_R1.fq.gz"
    File? flashReadsRevComb = "./data/combined_flash_R2.fq.gz"
    File mergedReadsFwd = "./data/combined_R1.fq.gz"
    File mergedReadsRev = "./data/combined_R2.fq.gz"
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



