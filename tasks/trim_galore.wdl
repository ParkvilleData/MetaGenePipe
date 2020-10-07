task trim_galore_task {
	File forwardReads
	File reverseReads
	Int TRMG_threads
	Int TRMG_minutes
	Int TRMG_mem
	Int minLength
	String Phred
	String outputPrefix
	Int clip_r5
	Int clip_r3
	Int quality

	### Note add leading and trailing as input params

	command {
		echo "Trimming sample .";

		trim_galore --cores ${TRMG_threads} --phred${Phred} --length ${minLength} --quality ${quality} --basename ${outputPrefix} \ 
		--clip_R1 ${clip_r5} --clip_R2 ${clip_r5} --three_prime_clip_R1 ${clip_r3} --three_prime_clip_R2 ${clip_r3} \ 
		--paired ${forwardReads} ${reverseReads}

		echo ".. Done\n";
	}
	output {
		File outFwdPaired="${outputPrefix}_val_1.fq.gz"
		File outRevPaired="${outputPrefix}_val_2.fq.gz"
	}
	runtime {
		runtime_minutes: '${TRMG_minutes}'
        cpus: '${TRMG_threads}'
        mem: '${TRMG_mem}'
    }
	meta {
		author: "Maria del Mar Quiroga"
        email: "mquiroga@unimelb.edu.au"
        description: "<DESCRIPTION>"
    }
    parameter_meta {
		# Inputs:
        Input1: "itype:<TYPE>: <DESCRIPTION>"
        # Outputs:
        Output1: "otype:<TYPE>: <DESCRIPTION>"
    }
}


