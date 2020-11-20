task taxonclass_task {
	File xml_parser
	File orgID_2_name
	File collationArray
	Int XMLP_threads
    Int XMLP_minutes
    Int XMLP_mem
	String koFormattedFile
	String keggSpeciesFile
	String taxRankFile
	String fullLineageFile	
	String outputFileName

    command {
		#perl ${xml_parser} ${outputFileName} 1 /data/cephfs/punim0639/metaGenPipe/${koFormattedFile} /data/cephfs/punim0639/metaGenPipe/${keggSpeciesFile} ${sep=';' collationArray}
		perl ${xml_parser} $PWD ${outputFileName} 1  ${koFormattedFile} ${keggSpeciesFile} ${collationArray}
		perl ${orgID_2_name} ${taxRankFile} ${fullLineageFile} $PWD $PWD > OTU.out.txt
    }
    runtime {
        runtime_minutes: '${XMLP_minutes}'
        cpus: '${XMLP_threads}'
        mem: '${XMLP_mem}'
    }
    output {
		File? functionalTable = "Functional.table.counts.txt"
		File? geneCounts = "geneCountTable.txt"
		File? level1Brite = "level1.counts.txt"
		File? level2Brite = "level2.counts.txt"
		File? level3Brite = "level3.counts.txt"
		File? mergedXml = "merged_reads.xml.domTable.txt"
		File? OTU = "OTU.out.txt"
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
