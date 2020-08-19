task megahit_task {
	File megahit
	File deconseqReadFile
        Int MES_threads
        Int MES_minutes
        Int MES_mem
        String baseName

        command {
		metaspades  	
        }
        runtime {
                runtime_minutes: '${MES_minutes}'
                cpus: '${MES_threads}'
                mem: '${MES_mem}'
        }
        output {
               File metaspadesOutput = "${sampleName}.final.contigs.fa"
        }
    meta {
        author: "Mar Quiroga"
        email: "mar.quiroga@unimelb.edu.au"
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

