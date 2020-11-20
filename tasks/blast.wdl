task blast_task {
	File bparser
	File inputScaffolds
	Int BLST_threads
    Int BLST_minutes
    Int BLST_mem
	Int numOfHits
	String database
	String? outputPrefix
    String? sampleName = if defined(outputPrefix) then outputPrefix else basename(inputScaffolds)

    command {
		#remove quotes from xml for processing
		blastn -db ${database} -num_threads ${BLST_threads} -query ${inputScaffolds} -out ${sampleName}.scaffold.out -num_descriptions ${numOfHits} -num_alignments 5
		perl ${bparser} ${sampleName}.scaffold.out ${numOfHits} ${sampleName}.scaffold.parsed  
    }
    runtime {
        runtime_minutes: '${BLST_minutes}'
        cpus: '${BLST_threads}'
        mem: '${BLST_mem}'
    }
    output {
		File blastOutput = "${sampleName}.scaffold.out"
		File? parsedOutput = "${sampleName}.scaffold.parsed"	
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
