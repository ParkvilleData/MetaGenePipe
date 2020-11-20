task metaspades_task {
	File trimmedReadsFwd
    File trimmedReadsRev
    Int MES_threads
    Int MES_minutes
    Int MES_mem
    String sampleName = basename(basename(basename(basename(trimmedReadsFwd, ".gz"), ".fq"), ".fastq"), ".trimmed_R1")

    command {
        metaspades.py -1 ${trimmedReadsFwd} -2 ${trimmedReadsRev} -k 21,33,55,77 -o assembly -t ${MES_threads} -m ${MES_mem}
        cp ./assembly/scaffolds.fasta ./assembly/${sampleName}.metaspades.scaffolds.fa
    }
    runtime {
        runtime_minutes: '${MES_minutes}'
        cpus: '${MES_threads}'
        mem: '${MES_mem}'
    }
    output {
        File assemblyOutput = "./assembly/${sampleName}.metaspades.scaffolds.fa"
    }
    meta {
        author: "Mar Quiroga, Bobbie Shaban"
        email: "mar.quiroga@unimelb.edu.au, bshaban@unimelb.edu.au"
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

