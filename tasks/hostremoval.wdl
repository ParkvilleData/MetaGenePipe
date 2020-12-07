############################################
#
# metaGenPipe fastqc WDL function
# Bobbie Shaban
# Should be reusable inbetween tasks
# Performs fastqc on samples
#
##########################################

task hostremoval_task {
  File deconseq
  File deconConfig
  Int HRM_threads
  Int HRM_minutes
  Int HRM_mem
  Int identityPercentage
  Int coverage
  String interleavedSequence
  String outputPrefix
  String removalSequence
  String sampleName

  command {
    perl ${deconseq} -t ${HRM_threads}  -dbs ${removalSequence} -i ${identityPercentage} -c ${coverage} -f ${interleavedSequence} -id ${sampleName}
    mkdir -p ./data/hostremoved
    reformat.sh in=${sampleName}_clean.fq out1=./data/hostremoved/${sampleName}_R1.fq out2=./data/hostremoved/${sampleName}_R2.fq
    pigz -p ${HRM_threads} ./data/hostremoved/${sampleName}_R1.fq ./data/hostremoved/${sampleName}_R2.fq
  }
  runtime {
    runtime_minutes: '${HRM_minutes}'
    cpus: '${HRM_threads}'
    mem: '${HRM_mem}'
  }
  output {
    File hostRemovedFwdReads = "./data/hostremoved/${sampleName}_R1.fq.gz"
    File hostRemovedRevReads = "./data/hostremoved/${sampleName}_R2.fq.gz"
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
