############################################
#
# metaGenPipe collation WDL function
# Bobbie Shaban	
# Should be reusable inbetween tasks
# Collates all output into human readable form
#
##########################################


task xmlparser_task {
	Int xmlParserRunThreads
        Int xmlParserRunMinutes
        Int xmlParserRunMem
	String outputDir
	String outputFileName
	String scriptsDirectory
	String workingDir
	Array[String] scatterCompleteFlag
	String koFormattedFile
	String keggSpeciesFile
	String taxRankFile
	String fullLineageFile	

        command {
		module load Perl/5.26.2-intel-2018.u4
                module load web_proxy
		#remove quotes from xml for processing
		/usr/bin/time -v perl '${workingDir}'/'${scriptsDirectory}'/xml_parser.function.pl '${workingDir}'/'${outputDir}' '${outputFileName}' 1 '${workingDir}'/reference_files/'${koFormattedFile}' '${workingDir}'/reference_files/'${keggSpeciesFile}'
		/usr/bin/time -v perl '${workingDir}'/'${scriptsDirectory}'/orgID_2_name.pl '${workingDir}'/reference_files/'${taxRankFile}' '${workingDir}'/reference_files/'${fullLineageFile}' '${workingDir}'/'${outputDir}' > '${workingDir}'/'${outputDir}'/OTU.out.txt 
        }
        runtime {
                runtime_minutes: '${xmlParserRunMinutes}'
                cpus: '${xmlParserRunThreads}'
                mem: '${xmlParserRunMem}'
        }
        output {
		Array[File] outputArray = glob("*.txt")	
		# No output needed here as all xml output will be put in a dirctory for further processing
        }        
}
