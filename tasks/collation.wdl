############################################
#
# metaGenPipe collation WDL function
# Bobbie Shaban	
# Should be reusable inbetween tasks
# Collates all output into human readable form
#
##########################################


task collation_task {
	Int COL_threads
        Int COL_minutes
        Int COL_mem
        File inputXML
        String outputPrefix

        command {
		#remove quotes from xml for processing
		sed 's/\&quot;//g' ${inputXML} | sed 's/\&//g' > ${outputPrefix}.xml
        }
        runtime {
                runtime_minutes: '${COL_minutes}'
                cpus: '${COL_threads}'
                mem: '${COL_mem}'
        }
        output {
		File collationOutput = "${outputPrefix}.xml"
        }        
	
}
