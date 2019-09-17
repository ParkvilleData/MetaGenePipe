############################################
#
# metaGenPipe collation WDL function
# Bobbie Shaban	
# Should be reusable inbetween tasks
# Collates all output into human readable form
#
##########################################


task copyoutput_task {
	Int copyOutputRunThreads
        Int copyOutputRunMinutes
        Int copyOutputRunMem
	String outputDir
	File all_level_table
	File gene_count_table
	File level_one
	File level_two
	File level_three

        command {
		cp '${all_level_table}'  '${gene_count_table}'  '${level_one}'  '${level_two}'  '${level_three}' '${outputDir}'
        }
        runtime {
                runtime_minutes: '${copyOutputRunMinutes}'
                cpus: '${copyOutputRunThreads}'
                mem: '${copyOutputRunMem}'
        }
        output {

		# No output needed here as all xml output will be put in a dirctory for further processing
        }        
}
