task prodigal_task {
	Int GEP_threads
        Int GEP_minutes
        Int GEP_mem
        File megahitScaffolds
	String outputPrefix

        command {
		prodigal -i ${megahitScaffolds} -o ${outputPrefix}.prodgial.genes.fa -a ${outputPrefix}.prodigal.proteins.fa -d ${outputPrefix}.prodigal.nucl.genes.fa -s ${outputPrefix}.prodigal.potential_genes.fa

        }
        runtime {
                runtime_minutes: '${GEP_minutes}'
                cpus: '${GEP_threads}'
                mem: '${GEP_mem}'
        }
        output {
		File genesAlignmentOutput = "${outputPrefix}.prodgial.genes.fa"
		File proteinAlignmentOutput = "${outputPrefix}.prodigal.proteins.fa"
		File nucleotideGenesOutput = "${outputPrefix}.prodigal.nucl.genes.fa"
		File potentialGenesAlignmentOutput = "${outputPrefix}.prodigal.potential_genes.fa"
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
