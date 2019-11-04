############################################
#
# metaGenPipe fastqc WDL function
# Bobbie Shaban	
# Should be reusable inbetween tasks
# Performs fastqc on samples
#
##########################################


task fastqc_task {
	Int fastqcRunThreads
        Int fastqcRunMinutes
        Int fastqcRunMem
        File inputFastqRead1
	File inputFastqRead2
	String outputDir
        String sampleName
	String workingDir

        command {
                module load fastqc
		
                /usr/bin/time -v fastqc -t '${fastqcRunThreads}' '${inputFastqRead1}' '${inputFastqRead2}' -o '${workingDir}'/'${outputDir}'
        }
        runtime {
                runtime_minutes: '${fastqcRunMinutes}'
                cpus: '${fastqcRunThreads}'
                mem: '${fastqcRunMem}'
        }
        output {
		Array[File] fastqcArray = glob("*.zip")
        }        
}
