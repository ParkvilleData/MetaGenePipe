task megahit_task {
	File trimmedReadsFwd
	File trimmedReadsRev
    Int MEH_threads
    Int MEH_minutes
    Int MEH_mem
	String sampleName = basename(basename(basename(basename(trimmedReadsFwd, ".gz"), ".fq"), ".fastq"), ".trimmed_R1")
	String preset
    
    command {
		megahit -t ${MEH_threads} --presets ${preset} -m ${MEH_mem} -1 ${trimmedReadsFwd} -2 ${trimmedReadsRev} -o assembly --out-prefix ${sampleName}.megahit
    }
    runtime {
        runtime_minutes: '${MEH_minutes}'
        cpus: '${MEH_threads}'
        mem: '${MEH_mem}'
    }
    output {
        File assemblyOutput = "./assembly/${sampleName}.megahit.contigs.fa"
    }
    meta {
        author: "Bobbie Shaban, Mar Quiroga"
        email: "bshaban@unimelb.edu.au, mar.quiroga@unimelb.edu.au"
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

