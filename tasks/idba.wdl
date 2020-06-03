############################################
#
# metaGenPipe idba WDL function
# Bobbie Shaban	
# Should be reusable inbetween tasks
# Performs assembly on samples
#
##########################################


task idba_task {
	Int idbaRunThreads
        Int idbaRunMinutes
        Int idbaRunMem
	File cleanFastq
        String sampleName

        command {
		module load IDBA 

		fq2fa --paired '${cleanFastq}' clean.fa
		idba_ud -r clean.fa --num_threads '${idbaRunThreads}' 
		mv ./out/scaffold.fa '${sampleName}'.scaffold.fa	
        }
        runtime {
                runtime_minutes: '${idbaRunMinutes}'
                cpus: '${idbaRunThreads}'
                mem: '${idbaRunMem}'
        }
        output {
		File scaffoldFasta = "${sampleName}.scaffold.fa"
        }        
}
