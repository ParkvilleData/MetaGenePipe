task hmmer_task {
  Int HMMER_threads
  Int HMMER_minutes
  Int HMMER_mem
  File proteinAlignmentOutput
  File hmmerDB
  String? outputPrefix
  String? sampleName = if defined(outputPrefix) then outputPrefix else basename(proteinAlignmentOutput, ".fa")

  command {
    mkdir -p ./geneprediction/hmmer
    hmmsearch --cpu ${HMMER_threads} --tblout ${sampleName}.hmmer.tblout ${hmmerDB} ${proteinAlignmentOutput} > ${sampleName}.hmmer.out
    mv ${sampleName}.hmmer.* ./geneprediction/hmmer
  }
  runtime {
    runtime_minutes: '${HMMER_minutes}'
    cpus: '${HMMER_threads}'
    mem: '${HMMER_mem}'
  }
  output {
    File hmmerTable = "./geneprediction/hmmer/${sampleName}.hmmer.tblout"
    File hmmerOutput = "./geneprediction/hmmer/${sampleName}.hmmer.out"
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
