############################################
#
# metaGenPipe fastqc WDL function
# Bobbie Shaban	
# Should be reusable inbetween tasks
# Performs fastqc on samples
#
##########################################


task hostremoval_task {
	Int hostRemovalRunThreads
        Int hostRemovalRunMinutes
        Int hostRemovalRunMem
	File flashMergedFastq
	String outputDir
        String sampleName
	String workingDir
	String removalSequence

        command {
		module load Perl/5.26.2-intel-2018.u4

		/usr/bin/time -v perl '${workingDir}'/bin/dqc/deconseq.pl -dbs '${removalSequence}' -i 70 -c 70 -f '${flashMergedFastq}'
        }
        runtime {
                runtime_minutes: '${hostRemovalRunMinutes}'
                cpus: '${hostRemovalRunThreads}'
                mem: '${hostRemovalRunMem}'
        }
        output {
		Array[File] hostRemovalArray = glob("*.fq")
        }        
}
