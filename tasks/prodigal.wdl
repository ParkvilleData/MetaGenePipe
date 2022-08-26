task prodigal_task {
  Int GEP_threads
  Int GEP_minutes
  Int GEP_mem
  File assemblyScaffolds
  String? outputPrefix
  String? sampleName = if defined(outputPrefix) then outputPrefix else basename(basename(assemblyScaffolds, ".fa"), ".contigs")
  String? metaOption

  command {
    prodigal ${metaOption} -i ${assemblyScaffolds} -o ${sampleName}.gene_coordinates.gbk -a ${sampleName}.proteins.fa -d ${sampleName}.nucl_genes.fa -s ${sampleName}.starts.txt
    mkdir -p ./geneprediction/prodigal
    mv *.prodigal.*.fa ./geneprediction/prodigal
  }
  runtime {
    runtime_minutes: '${GEP_minutes}'
    cpus: '${GEP_threads}'
    mem: '${GEP_mem}'
  }
  output {
    File genesAlignmentOutput = "./geneprediction/prodigal/${sampleName}.gene_coordinates.gbk"
    File proteinAlignmentOutput = "./geneprediction/prodigal/${sampleName}.proteins.fa"
    File nucleotideGenesOutput = "./geneprediction/prodigal/${sampleName}.nucl_genes.fa"
    File potentialGenesAlignmentOutput = "./geneprediction/prodigal/${sampleName}.starts.txt"
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
