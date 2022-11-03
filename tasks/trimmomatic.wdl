task trimmomatic_task {
  File forwardReads
  File reverseReads
  Int TRIM_threads
  Int TRIM_minutes
  Int TRIM_mem
  Int minLength
  String Phred
  String EndType
  String sampleName
  File truseq_pe_adapter
  File? trueseq_se_adapter
  String trimmomatic

  command {
    mkdir -p ./qc/trimmed/orphaned

    ${trimmomatic} \
    ${EndType} -threads ${TRIM_threads} -phred${Phred} \
    ${forwardReads} ${reverseReads} \
    ./qc/trimmed/${sampleName}.TT_R1.fq.gz ./qc/trimmed/orphaned/${sampleName}.unpaired_R1.fq.gz \
    ./qc/trimmed/${sampleName}.TT_R2.fq.gz ./qc/trimmed/orphaned/${sampleName}.unpaired_R2.fq.gz \
    ILLUMINACLIP:${truseq_pe_adapter}:2:30:10:2 \
    LEADING:3 TRAILING:3 SLIDINGWINDOW:4:20 MINLEN:${minLength};

    echo ".. Done\n";
  }
  output {
    File outFwdPaired="./qc/trimmed/${sampleName}.TT_R1.fq.gz"
    File outRevPaired="./qc/trimmed/${sampleName}.TT_R2.fq.gz"
    File outFwdUnpaired="./qc/trimmed/orphaned/${sampleName}.unpaired_R1.fq.gz"
    File outRevUnpaired="./qc/trimmed/orphaned/${sampleName}.unpaired_R2.fq.gz"
  }
  runtime {
    runtime_minutes: '${TRIM_minutes}'
    cpus: '${TRIM_threads}'
    mem: '${TRIM_mem}'
  }
  meta {
    author: "Bobbie Shaban"
    email: "bshaban@unimelb.edu.au"
    description: "<DESCRIPTION>"
  }
  parameter_meta {
    # Inputs:
    Input1: "itype:<TYPE>: <DESCRIPTION>"
    # Outputs:
    Output1: "otype:<TYPE>: <DESCRIPTION>"
  }
}
