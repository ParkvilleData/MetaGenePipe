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
			cat ${sep = ' ' hostRemFwdReads} > ${outputPrefix}.combined.trimmed_R1.fastq
                        cat ${sep = ' ' hostRemRevReads} > ${outputPrefix}.combined.trimmed_R2.fastq
		else
                        cat ${sep = ' ' readsToMergeFwd} > ${outputPrefix}.combined.trimmed_R1.fastq
                        cat ${sep = ' ' readsToMergeRev} > ${outputPrefix}.combined.trimmed_R2.fastq
		fi
        }
        runtime {
                runtime_minutes: '${MGS_minutes}'
                cpus: '${MGS_threads}'
                mem: '${MGS_mem}'
        }
        output {
		File? flashReadsFwdComb = "${outputPrefix}.combined.flash_R1.fastq"
		File? flashReadsRevComb = "${outputPrefix}.combined.flash_R2.fastq"
		File trimmedReadsFwdComb = "${outputPrefix}.combined.trimmed_R1.fastq"
		File trimmedReadsRevComb = "${outputPrefix}.combined.trimmed_R2.fastq"
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



