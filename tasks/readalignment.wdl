task readalignment_task {
     	File finalContigs
	File forwardReads
	File reverseReads
	Int BRA_threads
        Int BRA_minutes
        Int BRA_mem
	String sampleName

  	String sampleTempName = basename(sampleName)
        String sampleOutput = sub(sampleTempName,"_R(?!.*_R).*","")

        command {
		bowtie2-build ${finalContigs} bowtieContigIndex;
		bowtie2 -x bowtieContigIndex -1 ${forwardReads} -2 ${reverseReads} -S ${sampleOutput}.sam -p ${BRA_threads};

		samtools view -bS ${sampleOutput}.sam | samtools sort > ${sampleOutput}.sorted.bam;
		samtools flagstat ${sampleOutput}.sorted.bam > ${sampleOutput}.flagstat.txt

        }
        runtime {
                runtime_minutes: '${BRA_minutes}'
                cpus: '${BRA_threads}'
                mem: '${BRA_mem}'
        }
        output {
		File sampleSamOutput = "${sampleOutput}.sam"
		File sampleSortedBam = "${sampleOutput}.sorted.bam"
		File sampleFlagstatText = "${sampleOutput}.flagstat.txt"
        }        

    meta {
        author: "Edoardo Tescari"
        email: "etescari@unimelb.edu.au"
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
