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
	File deconseqReadFile

        command {
		/data/cephfs/punim0256/metaGenPipe/phase4testing/pipelineCreation_02092019/mh/megahit -t 16 -r '${deconseqReadFile}' 	
        }
        runtime {
                runtime_minutes: '${megaHitRunMinutes}'
                cpus: '${megaHitRunThreads}'
                mem: '${megaHitRunMem}'
        }
        output {
                Array[File] megahitArray = glob("./megahit_out/final.contigs.fa")
        }
}

