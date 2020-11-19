task megahit_task {
	File trimmedReadsFwd
	File trimmedReadsRev
	File megaGraph
    	Int MEH_threads
    	Int MEH_minutes
    	Int MEH_mem
	String? outputPrefix
	String sample = basename(trimmedReadsFwd, ".gz")
	String sampleFastq = basename(sample, ".combined.trimmed_R1.fq")
	String sampleName = basename(sampleFastq, ".combined.trimmed_R1.fastq") 
	String sampleNameTemp = basename(sampleName, ".merged_R1.fastq")
	String sampleNameFinal = basename(sampleNameTemp, ".TG_R1.fq")
	String preset

        command {
		    # run megahit
		    megahit -t ${MEH_threads} --presets ${preset} -m ${MEH_mem} -1 ${trimmedReadsFwd} -2 ${trimmedReadsRev}  	

		    #copy megahit final output to execution directory
		    cp ./megahit_out/final.contigs.fa ${sampleNameFinal}.megahit.contigs.fa

		    #run python script to create fastg graph
		    python3 ${megaGraph} --directory ./megahit_out/intermediate_contigs --sampleName ${sampleNameFinal}

		    #copy fastg graph to execution directory
		    mv ./megahit_out/intermediate_contigs/${sampleNameFinal}.*.fastg .
        }
        runtime {
                runtime_minutes: '${MEH_minutes}'
                cpus: '${MEH_threads}'
                mem: '${MEH_mem}'
        }
        output {
               File assemblyOutput = "${sampleNameFinal}.megahit.contigs.fa"
	       Array[File] assemblyFastaArray = glob("./megahit_out/intermediate_contigs/*.contigs.*.fa")
	       String kmer = read_string(stdout())
	       File assemblyGraph = "${sampleNameFinal}.${kmer}.fastg"
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

