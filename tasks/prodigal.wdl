task prodigal_task {
  Int GEP_threads
  Int GEP_minutes
  Int GEP_mem
  File assemblyScaffolds
  String? outputPrefix
  String? sampleName = if defined(outputPrefix) then outputPrefix else basename(basename(assemblyScaffolds, ".fa"), ".contigs")
  String? metaOption

  command {
    prodigal ${metaOption} -i ${assemblyScaffolds} -o ${sampleName}.prodigal.genes.fa -a ${sampleName}.prodigal.proteins.fa -d ${sampleName}.prodigal.nucl.genes.fa -s ${sampleName}.prodigal.potential_genes.fa
    mkdir -p ./geneprediction
    mv *.prodigal.*.fa ./geneprediction/
  }
  runtime {
    runtime_minutes: '${GEP_minutes}'
    cpus: '${GEP_threads}'
    mem: '${GEP_mem}'
  }
  output {
    File genesAlignmentOutput = "./geneprediction/${sampleName}.prodigal.genes.fa"
    File proteinAlignmentOutput = "./geneprediction/${sampleName}.prodigal.proteins.fa"
    File nucleotideGenesOutput = "./geneprediction/${sampleName}.prodigal.nucl.genes.fa"
    File potentialGenesAlignmentOutput = "./geneprediction/${sampleName}.prodigal.potential_genes.fa"
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
