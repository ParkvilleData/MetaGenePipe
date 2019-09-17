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

        command {
		module load Perl

#		perl /data/cephfs/punim0256/metaGenPipe/phase4testing/dqc/deconseq.pl -dbs mm10_1,mm10_2,mm10_3,mm10_4 -i 70 -c 70 -out_dir '${outputDir}' -f '${flashMergedFastq}'
		perl /data/cephfs/punim0256/metaGenPipe/phase4testing/dqc/deconseq.pl -dbs mm10_1,mm10_2,mm10_3,mm10_4 -i 70 -c 70 -f '${flashMergedFastq}'
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
