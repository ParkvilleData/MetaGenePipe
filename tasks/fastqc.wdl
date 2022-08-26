task fastqc_task {
  Int FQC_threads
  Int FQC_minutes
  Int FQC_mem
  File forwardReads
  File reverseReads
  String fwdName = sub(basename(forwardReads),".f.*q.*$","")
  String revName = sub(basename(reverseReads),".f.*q.*$","")

  command {
    mkdir -p ./qc/fastqc
    fastqc -t ${FQC_threads} ${forwardReads} ${reverseReads} --outdir ./qc/fastqc
  }
  runtime {
    runtime_minutes: '${FQC_minutes}'
    cpus: '${FQC_threads}'
    mem: '${FQC_mem}'
  }
  output {
    Array[File] fastqcArray = ["./qc/fastqc/${fwdName}_fastqc.zip", "./qc/fastqc/${revName}_fastqc.zip"]
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
    fastqcArray: "otype:folder: All the zip files output"
  }
}



