task blast_task {
	File bparser
	File inputScaffolds
	Int BLST_threads
        Int BLST_minutes
        Int BLST_mem
	Int numOfHits
	String database
	String outputPrefix

        command {
		#remove quotes from xml for processing
		blastn -db ${database} -num_threads ${BLST_threads} -query ${inputScaffolds} -out ${outputPrefix}.scaffold.out -num_descriptions ${numOfHits} -num_alignments 5
		perl ${bparser} ${outputPrefix}.scaffold.out ${numOfHits} ${outputPrefix}.scaffold.parsed  
        }
        runtime {
                runtime_minutes: '${BLST_minutes}'
                cpus: '${BLST_threads}'
                mem: '${BLST_mem}'
        }
        output {
		File blastOutput = "${outputPrefix}.scaffold.out"
		File? parsedOutput = "${outputPrefix}.scaffold.parsed"	
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
