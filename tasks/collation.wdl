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
	String workingDir

        command {
		#remove quotes from xml for processing
		#/usr/bin/time -v sed 's/\&quot;//g' '${inputXML}' | sed 's/\&//g' | sed 's/\\/ /g' > '${outputDir}'/'${sampleName}'.xml
		/usr/bin/time -v sed 's/\&quot;//g' '${inputXML}' | sed 's/\&//g' > "${sampleName}".xml
		#Doesn't like ^A
		#ugly but will work for now
        }
        runtime {
                runtime_minutes: '${collationRunMinutes}'
                cpus: '${collationRunThreads}'
                mem: '${collationRunMem}'
        }
        output {
		String scatterCompleteFlag = "complete"
		File collationOutput = "${sampleName}.xml"
        }        
	
}
