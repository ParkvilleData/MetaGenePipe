############################################
#
# metaGenPipe diamond WDL function
# Bobbie Shaban	
# Should be reusable inbetween tasks
# Performs diamond alignment of genes
# will attempt to be reusable
##########################################


task diamond_task {
	Int diamondRunThreads
        Int diamondRunMinutes
        Int diamondRunMem
        File genesAlignmentOutput
	String outputDir
        String sampleName

        command {
                module load diamond
		
		diamond blastp -p 30 -f 5 -d /data/cephfs/punim0256/metaGenPipe/phase4testing/pipelineCreation_02092019/kegg/kegg.dmnd -q '${genesAlignmentOutput}' -o '${sampleName}'.xml.out

        }
        runtime {
                runtime_minutes: '${diamondRunMinutes}'
                cpus: '${diamondRunThreads}'
                mem: '${diamondRunMem}'
        }
        output {
		File diamondOutput = "${sampleName}.xml.out" 
        }        
}
