task blast_task {
	Int BLST_threads
        Int BLST_minutes
        Int blastRunMem
	Int numOfHits
	String database
	String baseName
	File blast
	File bparser
	File inputScaffolds

        command {
		module load Perl/5.26.2-intel-2018.u4
                module load BioPerl
		#module load BLAST

		#remove quotes from xml for processing
		'${blast}' -db '${database}' -num_threads '${BLST_threads}' -query '${inputScaffolds}' -out '${sampleName}'.scaffold.out -num_descriptions '${numOfHits}' -num_alignments 5
		perl '${bparser}' '${sampleName}'.scaffold.out '${numOfHits}' '${sampleName}'.scaffold.parsed  
        }
        runtime {
                runtime_minutes: '${BLST_minutes}'
                cpus: '${BLST_threads}'
                mem: '${BLST_mem}'
        }
        output {
		File parsedOutput = "${sampleName}.scaffold.parsed"	
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
