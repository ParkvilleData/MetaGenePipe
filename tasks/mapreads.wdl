task mapreads_task {
  Map[String, File] Inputmap
  Int BRA_threads
  Int BRA_minutes
  Int BRA_mem
  String sampleTempName = basename(Inputmap["left"])
  String sampleOutput = sub(sampleTempName,"_R(?!.*_R).*","")

  command {
    mkdir -p ./mapreads
    bowtie2-build ${Inputmap["index"]} bowtieContigIndex;
    bowtie2 -x bowtieContigIndex -1 ${Inputmap["left"]} -2 ${Inputmap["right"]} -S ${sampleOutput}.sam -p ${BRA_threads};

    samtools view -bS ${sampleOutput}.sam | samtools sort > ${sampleOutput}.sorted.bam;
    samtools flagstat ${sampleOutput}.sorted.bam > ${sampleOutput}.flagstat.txt

    mv ${sampleOutput}.* ./mapreads
  }
  runtime {
    runtime_minutes: '${BRA_minutes}'
    cpus: '${BRA_threads}'
    mem: '${BRA_mem}'
  }
  output {
    File sampleSamOutput = "./mapreads/${sampleOutput}.sam"
    File sampleSortedBam = "./mapreads/${sampleOutput}.sorted.bam"
    File sampleFlagstatText = "./mapreads/${sampleOutput}.flagstat.txt"
  }        
  meta {
    author: "Edoardo Tescari"
    email: "etescari@unimelb.edu.au"
    description: "<DESCRIPTION>"
  }
  parameter_meta {
    # Inputs:                                                              
    Input1: "itype:<TYPE>: <DESCRIPTION>"
    # Outputs:                                                             
    Output1: "otype:<TYPE>: <DESCRIPTION>"
  }
}
