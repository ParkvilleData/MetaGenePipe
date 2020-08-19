############################################
#
# metaGenPipe flash WDL function
# Bobbie Shaban	
# Should be reusable inbetween tasks
# Performs merging of reads witinn samples
#
##########################################


task flash_task {
	Int FLA_threads
        Int FLA_minutes
        Int FLA_mem
        File forwardReads
	File reverseReads
        String sampleName

        command {
                module load FLASH
		
		flash -t '${FLA_threads}' -o '${sampleName}' '${forwardReads}'  '${reverseReads}'
        }
        runtime {
                runtime_minutes: '${FLA_minutes}'
                cpus: '${FLA_threads}'
                mem: '${FLA_mem}'
        }
        output {
		Array[File] flashArray = glob("*.fastq")
        }        
}
