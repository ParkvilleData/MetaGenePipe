############################################
#
# metaGenPipe MegaHit WDL function
# Bobbie Shaban
# Should be reusable inbetween tasks
# Performs assembly on reads
#
##########################################

task megahit_task {
        Int megaHitRunThreads
        Int megaHitRunMinutes
        Int megaHitRunMem
        String outputDir
        String sampleName
	String workingDir
	File deconseqReadFile

        command {
		/usr/bin/time -v '${workingDir}'/bin/mh/mh/megahit -t '${megaHitRunThreads}' -r '${deconseqReadFile}' 	
		cp ./megahit_out/final.contigs.fa ${sampleName}.final.contigs.fa
        }
        runtime {
                runtime_minutes: '${megaHitRunMinutes}'
                cpus: '${megaHitRunThreads}'
                mem: '${megaHitRunMem}'
        }
        output {
               File megahitOutput = "${sampleName}.final.contigs.fa"
        }
}

