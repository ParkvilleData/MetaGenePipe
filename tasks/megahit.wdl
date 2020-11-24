task megahit_task {
  File trimmedReadsFwd
  File trimmedReadsRev
  File megaGraph
  Int MEH_threads
  Int MEH_minutes
  Int MEH_mem
  String sampleName = basename(basename(basename(basename(trimmedReadsFwd, ".gz"), ".fq"), ".fastq"), "_R1")
  String preset
  command {
    # run megahit
    megahit -t ${MEH_threads} --presets ${preset} -m ${MEH_mem} -1 ${trimmedReadsFwd} -2 ${trimmedReadsRev} -o assembly --out-prefix ${sampleName}.megahit
      
    #run python script to create fastg graph
    python3 ${megaGraph} --directory ./assembly/intermediate_contigs --sampleName ${sampleName}
      
    #copy fastg graph to assembly directory
    mv ./assembly/intermediate_contigs/${sampleName}*.fastg ./assembly/${sampleName}*.fastg
  }
  runtime {
    runtime_minutes: '${MEH_minutes}'
    cpus: '${MEH_threads}'
    mem: '${MEH_mem}'
  }
  output {
    File assemblyOutput = "./assembly/${sampleName}.megahit.contigs.fa"
    Array[File] assemblyFastaArray = glob("./assembly/intermediate_contigs/*.contigs.*.fa")
    String kmer = read_string(stdout())
    File assemblyGraph = "./assembly/${sampleName}.${kmer}.fastg"
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