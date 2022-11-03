task mapreads_task {
  Map[String, File] Inputmap
  Int BRA_threads
  Int BRA_minutes
  Int BRA_mem
  String sampleTempName = basename(Inputmap["left"])
  String sampleOutput = sub(sampleTempName,"_R(?!.*_R).*","")

  command {
    mkdir -p ./readalignment
    bowtie2-build ${Inputmap["index"]} bowtieContigIndex;
    bowtie2 -x bowtieContigIndex -1 ${Inputmap["left"]} -2 ${Inputmap["right"]} -S ./readalignment/${sampleOutput}.sam -p ${BRA_threads};

    samtools view -bS ./readalignment/${sampleOutput}.sam | samtools sort > ./readalignment/${sampleOutput}.sorted.bam;
    samtools flagstat ./readalignment/${sampleOutput}.sorted.bam > ./readalignment/${sampleOutput}.flagstat.txt
  }
  runtime {
    runtime_minutes: '${BRA_minutes}'
    cpus: '${BRA_threads}'
    mem: '${BRA_mem}'
  }
  output {
    File sampleSamOutput = "./readalignment/${sampleOutput}.sam"
    File sampleSortedBam = "./readalignment/${sampleOutput}.sorted.bam"
    File sampleFlagstatText = "./readalignment/${sampleOutput}.flagstat.txt"
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
