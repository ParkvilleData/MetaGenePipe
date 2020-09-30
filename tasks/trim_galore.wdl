task trim_galore_task {
	File forwardReads
	File reverseReads
	Int TRMG_threads
	Int TRMG_minutes
	Int TRMG_mem
	Int minLength
	String outputPrefix
	Int clip_r5
	## Add trim_galore variables

	### Note add leading and trailing as input params

	command {
		echo "Trimming sample .";
		#trim_galore commands

 		${trimmomatic} \
		${EndType} -threads ${TRIM_threads} -phred${Phred} \
		${forwardReads} ${reverseReads} \
		${outputPrefix}_R1.fwd.fq.gz ${outputPrefix}.fwd.unpaired.fq.gz \
		${outputPrefix}_R2.rev.fq.gz ${outputPrefix}.rev.unpaired.fq.gz \
		ILLUMINACLIP:${truseq_pe_adapter}:2:30:10:2 \
		LEADING:3 TRAILING:3 SLIDINGWINDOW:4:20 MINLEN:${minLength};

		echo ".. Done\n";
	}
	output {
		File outFwdPaired="${outputPrefix}_R1.fwd.fq.gz"
		File outRevPaired="${outputPrefix}_R2.rev.fq.gz"
		File outFwdUnpaired="${outputPrefix}.fwd.unpaired.fq.gz"
		File outRevUnpaired="${outputPrefix}.rev.unpaired.fq.gz"
	}
	runtime {
                runtime_minutes: '${TRIM_minutes}'
                cpus: '${TRIM_threads}'
                mem: '${TRIM_mem}'
        }
	meta {
                author: "Bobbie Shaban"
                email: "bshaban@unimelb.edu.au"
                description: "<DESCRIPTION>"
        }
        parameter_meta {
                # Inputs:
                Input1: "itype:<TYPE>: <DESCRIPTION>"
                # Outputs:
                Output1: "otype:<TYPE>: <DESCRIPTION>"
        }
}


