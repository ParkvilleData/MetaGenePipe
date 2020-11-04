task matching_contigs_reads_task {
        File? merged_Contigs
     	Array[File?]? non_merged_Contigs
	File forwardReads
        File reverseReads
        Boolean merge_opt
	Int BMN_threads
        Int BMN_minutes
        Int BMN_mem

        String sampleTempName = basename(forwardReads)
        String sampleMatch = sub(sampleTempName,"_val(?!.*_val).*","")
        
        command {
          if [[ ${merge_opt} = false ]]; then
          	for file in ${sep=' ' non_merged_Contigs}; do
	  		if grep -q "${sampleMatch}" <<< "$file"; then
	  			echo $file
	  		fi
          	done
          else
	  	echo ${merged_Contigs}
	  fi
        }
        runtime {
                runtime_minutes: '${BMN_minutes}'
                cpus: '${BMN_threads}'
                mem: '${BMN_mem}'
        }
        output {
                Array[String] cont_match_arr = read_lines(stdout())
                File cont_match = cont_match_arr[0]
                Map[String, File] matchedclr = {"index":"${cont_match}","left":"${forwardReads}", "right":"${reverseReads}"}
        }        

    meta {
        author: "Edoardo Tescari"
        email: "etescari@unimelb.edu.au"
        description: "<DESCRIPTION>"
    }
    parameter_meta {
        # Inputs:
        Input1: "itype:<TYPE>: <DESCRIPTION>"
        # Outputs:
        Output1: "otype:<TYPE>: <DESCRIPTION>"
    }
}
