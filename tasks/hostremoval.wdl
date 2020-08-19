############################################
#
# metaGenPipe fastqc WDL function
# Bobbie Shaban	
# Should be reusable inbetween tasks
# Performs fastqc on samples
#
##########################################


task hostremoval_task {
	Int HRM_threads
        Int HRM_minutes
        Int HRM_mem
	Int identityPercent
	Int coverage
	File flashMergedFastq
	File deconseq
        String baseName
	String removalSequence

        command {
		module load Perl/5.26.2-intel-2018.u4

		perl '${deconseq}'/bin/dqc/deconseq.pl -dbs '${removalSequence}' -i '${percentIdentity}' -c '${coverage}' -f '${flashMergedFastq}' -id ${sampleName}
        }
        runtime {
                runtime_minutes: '${HRM_minutes}'
                cpus: '${HRM_threads}'
                mem: '${HRM_mem}'
        }
        output {
		File hostRemovalOutput = "${sampleName}_clean.fq"
        }        
    meta {
        author: "Bobbie Shaban"
        email: "bshaban@unimelb.edu.au"
        description: "<DESCRIPTION>"
    }
    parameter_meta {
        # Inputs:
        forwardReads: "itype:fastq: Forward reads in read pair"
        reverseReads: "itype:fastq: Reverse reads in read pair"
        # Outputs:
        fastqcArray: "otype:glob: All the zip files output"
    }
}
