task megahit_task {
	File megahit
	File deconseqReadFile
        Int MEH_threads
        Int MEH_minutes
        Int MEH_mem
        String baseName

        command {
		megahit -t '${MEH_threads}' -r '${deconseqReadFile}' 	
		cp ./megahit_out/final.contigs.fa ${sampleName}.final.contigs.fa
        }
        runtime {
                runtime_minutes: '${MEH_minutes}'
                cpus: '${MEH_threads}'
                mem: '${MEH_mem}'
        }
        output {
               File megahitOutput = "${sampleName}.final.contigs.fa"
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

