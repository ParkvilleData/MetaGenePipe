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
	File database
	String outputDir
        String sampleName
	String workingDir

        command {
		module load diamond/0.9.10
		
		/usr/bin/time -v diamond blastp --max-target-seqs 1 -p 30 -f 5 -d '${database}' -q '${genesAlignmentOutput}' -o '${sampleName}'.xml.out

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
