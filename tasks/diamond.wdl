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
        String outputPrefix
	String mode
	String blastMode

        command {
		diamond ${blastMode} --max-target-seqs ${maxTargetSeqs} -p ${mode} -f ${outputType} -d ${DB} -q ${genesAlignmentOutput} -o ${outputPrefix}.xml.out

        }
        runtime {
                runtime_minutes: '${DIM_minutes}'
                cpus: '${DIM_threads}'
                mem: '${DIM_mem}'
        }
        output {
		File diamondOutput = "${outputPrefix}.xml.out" 
        }        
}
