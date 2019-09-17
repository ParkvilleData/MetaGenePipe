############################################
#
# metaGenPipe flash WDL function
# Bobbie Shaban	
# Should be reusable inbetween tasks
# Performs merging of reads witinn samples
#
##########################################


task flash_task {
	Int flashRunThreads
        Int flashRunMinutes
        Int flashRunMem
        File inputFastqRead1
	File inputFastqRead2
	String outputDir
        String sampleName

        command {
                module load FLASH
		
		flash -t 16 -o '${sampleName}' '${inputFastqRead1}'  '${inputFastqRead2}'
        }
        runtime {
                runtime_minutes: '${flashRunMinutes}'
                cpus: '${flashRunThreads}'
                mem: '${flashRunMem}'
        }
        output {
		Array[File] flashArray = glob("*.fastq")
        }        
}
