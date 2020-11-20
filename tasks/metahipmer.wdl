task metahipmer_task {
	File trimmedReadsFwd
	File trimmedReadsRev
    Int MHM_threads
    Int MHM_minutes
    Int MHM_mem
	String sampleName = basename(basename(basename(basename(trimmedReadsFwd, ".gz"), ".fq"), ".fastq"), ".trimmed_R1")

    command {
        reformat.sh in1=${trimmedReadsFwd} in2=${trimmedReadsRev} out=reads.fq
        mhm2.py -r reads.fq -o assembly
        cp ./assembly/final_assembly.fasta ./assembly/${sampleName}.metahipmer.assembly.fa	
    }
    runtime {
        runtime_minutes: '${MHM_minutes}'
        cpus: '${MHM_threads}'
        mem: '${MHM_mem}'
    }
    output {
        File assemblyOutput = "./assembly/${sampleName}.metahipmer.assembly.fa"
    }
    meta {
        author: "Mar Quiroga"
        email: "mar.quiroga@unimelb.edu.au"
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

