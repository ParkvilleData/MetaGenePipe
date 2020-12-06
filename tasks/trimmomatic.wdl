task trimmomatic_task {
  File forwardReads
  File reverseReads
  Int TRIM_threads
  Int TRIM_minutes
  Int TRIM_mem
  Int minLength
  String Phred
  String EndType
  String outputPrefix
  File truseq_pe_adapter
  File? trueseq_se_adapter
  String trimmomatic

  command {
    mkdir -p ./data/trimmed/orphaned

    ${trimmomatic} \
    ${EndType} -threads ${TRIM_threads} -phred${Phred} \
    ${forwardReads} ${reverseReads} \
    ./data/trimmed/${outputPrefix}.TT_R1.fq.gz ./data/trimmed/orphaned/${outputPrefix}.unpaired_R1.fq.gz \
    ./data/trimmed/${outputPrefix}.TT_R2.fq.gz ./data/trimmed/orphaned/${outputPrefix}.unpaired_R2.fq.gz \
    ILLUMINACLIP:${truseq_pe_adapter}:2:30:10:2 \
    LEADING:3 TRAILING:3 SLIDINGWINDOW:4:20 MINLEN:${minLength};

    echo ".. Done\n";
  }
  output {
    File outFwdPaired="./data/trimmed/${outputPrefix}.TT_R1.fq.gz"
    File outRevPaired="./data/trimmed/${outputPrefix}.TT_R2.fq.gz"
    File outFwdUnpaired="./data/trimmed/orphaned/${outputPrefix}.unpaired_R1.fq.gz"
    File outRevUnpaired="./data/trimmed/orphaned/${outputPrefix}.unpaired_R2.fq.gz"
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


