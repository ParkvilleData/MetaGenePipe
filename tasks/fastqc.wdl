task fastqc_task {
	Int FQC_threads
        Int FQC_minutes
        Int FQC_mem
        File forwardReads
	File reverseReads

        command {
                fastqc -t ${FQC_threads} ${forwardReads} ${reverseReads} -O $PWD
        }
        runtime {
                runtime_minutes: '${FQC_minutes}'
                cpus: '${FQC_threads}'
                mem: '${FQC_mem}'
        }
        output {
		Array[File] fastqcArray = glob("*.zip")
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



