task alignment_task {
	Int ALN_threads
        Int ALN_minutes
        Int ALN_mem
        File megahitOutputTranscripts
        String baseName

        command {
                module load prodigal
		
		prodigal -i '${megahitOutputTranscripts}' -o '${baseName}'.prodgial.genes.fa -a '${sampleName}'.prodigal.proteins.fa -d '${sampleName}'.prodigal.nucl.genes.fa -s '${sampleName}'.prodigal.potential_genes.fa

        }
        runtime {
                runtime_minutes: '${ALN_minutes}'
                cpus: '${ALN_threads}'
                mem: '${ALN_mem}'
        }
        output {
		File genesAlignemntOutput = "${baseName}.prodgial.genes.fa"
		File proteinAlignmentOutput = "${baseName}.prodigal.proteins.fa"
		File nucleotiedGenesOutput = "${baseName}.prodigal.nucl.genes.fa"
		File potentialGenesAlignmentOutput = "${baseName}.prodigal.potential_genes.fa"
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
