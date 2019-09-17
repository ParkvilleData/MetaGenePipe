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
	Array[String] scatterCompleteFlag
	File koFormattedFile
	File keggSpeciesFile

        command {
		module load Perl/5.26.2-intel-2018.u4
                module load web_proxy
		#remove quotes from xml for processing
		perl /data/cephfs/punim0256/metaGenPipe/phase4testing/pipelineCreation_02092019/scripts/xml_parser.function.pl '${outputDir}' '${outputFileName}' 1 '${koFormattedFile}' '${keggSpeciesFile}'
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
