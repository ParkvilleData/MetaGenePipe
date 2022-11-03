############################################
#
# metaGenPipe diamond WDL function
# Bobbie Shaban  
# Should be reusable inbetween tasks
# Performs diamond alignment of genes
# will attempt to be reusable
##########################################


task diamond_task {
  Int DIM_threads
  Int DIM_minutes
  Int DIM_mem
  Int maxTargetSeqs
  Int outputType
  File genesAlignmentOutput
  File DB
  String blastMode
  String sampleName = basename(genesAlignmentOutput)

  command {
    diamond ${blastMode} --max-target-seqs ${maxTargetSeqs} --threads ${DIM_threads} -f ${outputType} -d ${DB} -q ${genesAlignmentOutput} -o ${sampleName}.xml.out
    mkdir -p ./geneprediction/diamond
    mv ${sampleName}.xml.out ./geneprediction/diamond
  }
  runtime {
    runtime_minutes: '${DIM_minutes}'
    cpus: '${DIM_threads}'
    mem: '${DIM_mem}'
  }
  output {
    File diamondOutput = "./geneprediction/diamond/${sampleName}.xml.out" 
  }        
}
