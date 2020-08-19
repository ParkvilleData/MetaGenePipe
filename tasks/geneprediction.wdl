task geneprediction_task {
	Int GEP_threads
        Int GEP_minutes
        Int GEP_mem
        File megahitOutputTranscripts
        String baseName

        command {
                module load prodigal
		
		prodigal -i '${megahitOutputTranscripts}' -o '${sampleName}'.prodgial.genes.fa -a '${sampleName}'.prodigal.proteins.fa -d '${sampleName}'.prodigal.nucl.genes.fa -s '${sampleName}'.prodigal.potential_genes.fa

        }
        runtime {
                runtime_minutes: '${GEP_minutes}'
                cpus: '${GEP_threads}'
                mem: '${GEP_mem}'
        }
        output {
		File genesAlignmentOutput = "${sampleName}.prodgial.genes.fa"
		File proteinAlignmentOutput = "${sampleName}.prodigal.proteins.fa"
		File nucleotiedGenesOutput = "${sampleName}.prodigal.nucl.genes.fa"
		File potentialGenesAlignmentOutput = "${sampleName}.prodigal.potential_genes.fa"
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
