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
    String outputPrefix

    command {
      if [[ ${hostMergeArray} > 0 ]]
        then
          cat ${sep = ' ' hostRemFwdReads} > ${outputPrefix}.merged_R1.fastq.gz
          cat ${sep = ' ' hostRemRevReads} > ${outputPrefix}.merged_R2.fastq.gz
        else
          cat ${sep = ' ' readsToMergeFwd} > ${outputPrefix}.merged_R1.fastq.gz
          cat ${sep = ' ' readsToMergeRev} > ${outputPrefix}.merged_R2.fastq.gz
      fi
    }
    runtime {
      runtime_minutes: '${MGS_minutes}'
      cpus: '${MGS_threads}'
      mem: '${MGS_mem}'
    }
    output {
      File? flashReadsFwdComb = "${outputPrefix}.flash_R1.fastq"
      File? flashReadsRevComb = "${outputPrefix}.flash_R2.fastq"
      File trimmedReadsFwd = "${outputPrefix}.merged_R1.fastq"
      File trimmedReadsRev = "${outputPrefix}.merged_R2.fastq"
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



