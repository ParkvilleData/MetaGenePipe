task megahit_task {
	File trimmedReadsFwdComb
	File trimmedReadsRevComb
        Int MEH_threads
        Int MEH_minutes
        Int MEH_mem
	String outputPrefix
	String forwardRead = basename(trimmedReadsFwdComb)
	String reverseRead = basename(trimmedReadsRevComb)

        command {
		module load megahit/1.2.9-python-2.7.16
		megahit -t ${MEH_threads} -1 ${trimmedReadsFwdComb} -2 ${trimmedReadsRevComb}  	
		cp ./megahit_out/final.contigs.fa ${outputPrefix}.megahit.final.contigs.fa
        }
        runtime {
                runtime_minutes: '${MEH_minutes}'
                cpus: '${MEH_threads}'
                mem: '${MEH_mem}'
        }
        output {
               File megahitOutput = "${outputPrefix}.megahit.final.contigs.fa"
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

