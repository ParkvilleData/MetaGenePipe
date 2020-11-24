############################################
#
# metaGenPipe fastqc WDL function
# Bobbie Shaban
# Should be reusable inbetween tasks
# interleaves flash output and merges into one file 
# to prepare for decontamination
##########################################


task interleave_task {
  Boolean flashBoolean
  File? hostRemovalFlash
  File hostRemovalFwd
  File hostRemovalRev
  File interleaveShell
  Int ILE_threads
  Int ILE_minutes
  Int ILE_mem
  String outputPrefix

  command {
    mkdir -p ./data/interleaved
    if [[ ${hostRemovalFwd} =~ "gz" ]]; then
      gunzip -c ${hostRemovalFwd} > forwardReads.fastq
      gunzip -c ${hostRemovalRev} > reverseReads.fastq
      sh ${interleaveShell} forwardReads.fastq reverseReads.fastq > ./data/interleaved/${outputPrefix}.interLeaved.fq
    else
      sh ${interleaveShell} ${hostRemovalFwd} ${hostRemovalRev} > ./data/interleaved/${outputPrefix}.interLeaved.fq
    fi
  }
  runtime {
    runtime_minutes: '${ILE_minutes}'
    cpus: '${ILE_threads}'
    mem: '${ILE_mem}'
  }
  output {
    File interLeavedFile = "./data/interleaved/${outputPrefix}.interLeaved.fq"
  }        
}
