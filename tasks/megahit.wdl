task megahit_task {
	File trimmedReadsFwd
	File trimmedReadsRev
    Int MEH_threads
    Int MEH_minutes
    Int MEH_mem
	String? outputPrefix
	String sample = basename(trimmedReadsFwd, ".gz")
	String sampleFastq = basename(sample, ".fq")
	String sampleName = basename(sampleFastq, ".fastq") 
	String preset
	#String reverseRead = basename(trimmedReadsRev)

        command {
		    megahit -t ${MEH_threads} --presets ${preset} -m ${MEH_mem} -1 ${trimmedReadsFwd} -2 ${trimmedReadsRev}  	
		    cp ./megahit_out/final.contigs.fa ${sampleName}.megahit.final.contigs.fa
        }
        runtime {
                runtime_minutes: '${MEH_minutes}'
                cpus: '${MEH_threads}'
                mem: '${MEH_mem}'
        }
        output {
               File assemblyOutput = "${sampleName}.megahit.final.contigs.fa"
        }
    meta {
        author: "Bobbie Shaban, Mar Quiroga"
        email: "bshaban@unimelb.edu.au, mar.quiroga@unimelb.edu.au"
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

