task trimmomatic_task {
	File forwardReads
	File reverseReads
	Int TRIM_threads
	Int TRIM_minutes
	Int TRIM_mem
	Int minLength
	String Phred
	String EndType
	String outputPrefix
	File truseq_pe_adapter
	File? trueseq_se_adapter
	String trimmomatic

	### Note add leading and trailing as input params

	command {
		echo "Trimming sample .";

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
		File outFwdPaired="${outputPrefix}.TT_R1.fq.gz"
		File outRevPaired="${outputPrefix}.TT_R2.gz"
		File outFwdUnpaired="${outputPrefix}.unpaired_R1.fq.gz"
		File outRevUnpaired="${outputPrefix}.unpaired_R2.fq.gz"
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


