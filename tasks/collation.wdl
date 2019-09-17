############################################
#
# metaGenPipe collation WDL function
# Bobbie Shaban	
# Should be reusable inbetween tasks
# Collates all output into human readable form
#
##########################################


task collation_task {
	Int collationRunThreads
        Int collationRunMinutes
        Int collationRunMem
        File inputXML
	String outputDir
        String sampleName

        command {
		#remove quotes from xml for processing
		sed 's/\&quot;//g' '${inputXML}' | sed 's/\&//g' > '${outputDir}'/'${sampleName}'.xml
		#ugly but will work for now
        }
        runtime {
                runtime_minutes: '${collationRunMinutes}'
                cpus: '${collationRunThreads}'
                mem: '${collationRunMem}'
        }
        output {
		String scatterCompleteFlag = "complete"
		# No output needed here as all xml output will be put in a dirctory for further processing
        }        
}
