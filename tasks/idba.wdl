task idba_task {
	Int IDBA_threads
        Int IDBA_minutes
        Int IDBA_mem
	File trimmedReadsFwd
	File trimmedReadsRev
        String? outputPrefix

        command {
		fq2fa --merge ${trimmedReadsFwd} ${trimmedReadsRev} clean.fa
		idba_ud -l clean.fa --num_threads '${IDBA_threads}' 
		mv ./out/contig.fa '${outputPrefix}'.scaffold.fa	
        }
        runtime {
                runtime_minutes: '${IDBA_minutes}'
                cpus: '${IDBA_threads}'
                mem: '${IDBA_mem}'
        }
        output {
		File scaffoldFasta = "${outputPrefix}.scaffold.fa"
        }        

	meta {
        author: "Mar Quiroga"
        email: "mar.quiroga@unimelb.edu.au"
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
