task xmlparser_task {
	Array[String] scatterCompleteFlag
	Array[File] collationArray
	File xml_parser
	File org_orgID_2_name
	Int XMLP_threads
        Int XMLP_minutes
        Int XMLP_mem
	String koFormattedFile
	String keggSpeciesFile
	String taxRankFile
	String fullLineageFile	

        command {
		module load Perl/5.26.2-intel-2018.u4
                module load web_proxy
		#remove quotes from xml for processing

		#perl xml_parser.function.pl "${outputDir}" '${outputFileName}' 1 /data/cephfs/punim0639/metaGenPipe/'${koFormattedFile}' /data/cephfs/punim0639/metaGenPipe/'${keggSpeciesFile}' "${sep=';' collationArray}"
		perl '${xml_parser}' '${outputFileName}' 1 /data/cephfs/punim0639/metaGenPipe/'${koFormattedFile}' /data/cephfs/punim0639/metaGenPipe/'${keggSpeciesFile}' "${sep=';' collationArray}"
		#perl '${workingDir}'/'${scriptsDirectory}'/orgID_2_name.pl /data/cephfs/punim0639/metaGenPipe/'${taxRankFile}' /data/cephfs/punim0639/metaGenPipe/'${fullLineageFile}' "${outputDir}" > "${outputDir}"/OTU.out.txt 
		perl '${orgID_2_name}' '${taxRankFile}' '${fullLineageFile}' "${outputDir}" > OTU.out.txt
        }
        runtime {
                runtime_minutes: '${XMLP_minutes}'
                cpus: '${XMLP_threads}'
                mem: '${XMLP_mem}'
        }
        output {
		Array[File] outputArray = glob("*.txt")	
		# No output needed here as all xml output will be put in a dirctory for further processing
        }        

     meta {
        author: "Bobbie Shaban"
        email: "bshaban@unimelb.edu.au"
        description: "<DESCRIPTION>"
    }
    parameter_meta {
        # Inputs:
        forwardReads: "itype:fastq: Forward reads in read pair"
        reverseReads: "itype:fastq: Reverse reads in read pair"
        # Outputs:
        fastqcArray: "otype:glob: All the zip files output"
    }
}
