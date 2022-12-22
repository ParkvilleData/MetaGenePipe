task hmmer_taxon_task {
  File? hmmerTable
  File? diamondXML
  Array[File?]? hmmerTables
  Array[File?]? diamondXMLs
  Int HTAX_minutes
  Int HTAX_mem
  Int HTAX_threads
  File briteList
  File briteLineage
  File hmm_parser
  File xml_parser
  String outputFileName

  command {
    python3 ${hmm_parser} --outprefix ${outputFileName} --consistent-pathways ${briteList} ${sep=' ' hmmerTables} ${hmmerTable}
    python3 ${xml_parser} --outfile OTU.${outputFileName}.tsv ${briteLineage} ${sep=' ' diamondXMLs} ${diamondXML}

    mkdir -p ./geneprediction/taxon
    mv *.${outputFileName}.* ./geneprediction/taxon
  }
  runtime {
    runtime_minutes: '${HTAX_minutes}'
    cpus: '${HTAX_threads}'
    mem: '${HTAX_mem}'
  }
  output {
    File? level1Brite = "./geneprediction/taxon/LevelA.${outputFileName}.counts.tsv"
    File? level2Brite = "./geneprediction/taxon/LevelB.${outputFileName}.counts.tsv"
    File? level3Brite = "./geneprediction/taxon/LevelC.${outputFileName}.counts.tsv"
    File? OTU = "./geneprediction/taxon/OTU.${outputFileName}.tsv" 
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
