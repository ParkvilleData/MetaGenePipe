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
    mv ./assembly/intermediate_contigs/${sampleName}.*.fastg ./assembly

    #find ./assembly/intermediate_contigs -type f -name '*.contigs.*.fa' | xargs echo | sed 's/\(^\|$\)/"/g' | sed 's/ /, /g' > contigs.txt
  }
  runtime {
    runtime_minutes: '${MEH_minutes}'
    cpus: '${MEH_threads}'
    mem: '${MEH_mem}'
  }
  output {
    File assemblyOutput = "./assembly/${sampleName}.megahit.contigs.fa"
    File? twenty = "./assembly/intermediate_contigs/${sampleName}.contigs.k27.fa"
    File? thirty = "./assembly/intermediate_contigs/${sampleName}.contigs.k37.fa"
    File? forty = "./assembly/intermediate_contigs/${sampleName}.contigs.k47.fa"
    File? fifty = "./assembly/intermediate_contigs/${sampleName}.contigs.k57.fa"
    File? sixty = "./assembly/intermediate_contigs/${sampleName}.contigs.k67.fa"
    File? seventy = "./assembly/intermediate_contigs/${sampleName}.contigs.k77.fa"
    File? eighty = "./assembly/intermediate_contigs/${sampleName}.contigs.k87.fa"
    File? ninety = "./assembly/intermediate_contigs/${sampleName}.contigs.k97.fa"
    File? hundred = "./assembly/intermediate_contigs/${sampleName}.contigs.k107.fa"
    File? hundredten = "./assembly/intermediate_contigs/${sampleName}.contigs.k117.fa"
    File? hundredtwenty = "./assembly/intermediate_contigs/${sampleName}.contigs.k127.fa"
    Array[File] assemblyFastaArray = if defined(preset)
      then select_all([twenty, thirty, forty, fifty, sixty, seventy, eighty, ninety, hundred, hundredten, hundredtwenty])
      else glob("./assembly/intermediate_contigs/${sampleName}.contigs.*.fa")
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