############################################
#
# metaGenPipe fastqc WDL function
# Bobbie Shaban	
# Should be reusable inbetween tasks
# intereleaves flash output and merges into one file 
# to prepare for decontamination
##########################################


task interleave_task {
	Int interLeaveRunThreads
        Int interLeaveRunMinutes
        Int interLeaveRunMem
        File flashNotCombined1
	File flashNotCombined2
	File flashExtended
	String outputDir
        String sampleName
	String workingDir

        command {
		/usr/bin/time -v sh /data/cephfs/punim0256/MGP_ComEnc_011119/scripts/interleave_fastq.sh '${flashNotCombined1}' '${flashNotCombined2}' > ${sampleName}.interLeaved.fastq
		/usr/bin/time -v cat ${sampleName}.interLeaved.fastq '${flashExtended}' > ${sampleName}.merged.fastq
        }
        runtime {
                runtime_minutes: '${interLeaveRunMinutes}'
                cpus: '${interLeaveRunThreads}'
                mem: '${interLeaveRunMem}'
        }
        output {
		File interLeavedFile = "${sampleName}.interLeaved.fastq"
		File flashMergedFastq = "${sampleName}.merged.fastq"
        }        
}
