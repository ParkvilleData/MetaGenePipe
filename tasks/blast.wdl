############################################
#
# metaGenPipe blast WDL function
# Bobbie Shaban	
# Should be reusable inbetween tasks
# Collates all output into human readable form
#
##########################################


task blast_task {
	Int blastRunThreads
        Int blastRunMinutes
        Int blastRunMem
	Int numOfHits
	String database
	String sampleName
	String scriptsDirectory
	String workingDir
	File blast
	File bparser
	File inputScaffolds

        command {
		module load Perl/5.26.2-intel-2018.u4
                module load BioPerl
		#module load BLAST

		#remove quotes from xml for processing
		/usr/bin/time -v '${blast}' -db '${database}' -num_threads '${blastRunThreads}' -query '${inputScaffolds}' -out '${sampleName}'.scaffold.out -num_descriptions '${numOfHits}' -num_alignments 5
		/usr/bin/time -v perl '${bparser}' '${sampleName}'.scaffold.out '${numOfHits}' '${sampleName}'.scaffold.parsed  
        }
        runtime {
                runtime_minutes: '${blastRunMinutes}'
                cpus: '${blastRunThreads}'
                mem: '${blastRunMem}'
        }
        output {
		File parsedOutput = "${sampleName}.scaffold.parsed"	
        }        
}
