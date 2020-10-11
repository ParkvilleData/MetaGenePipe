task prodigal_task {
	Int GEP_threads
        Int GEP_minutes
        Int GEP_mem
        File assemblyScaffolds
	String? outputPrefix
	String? sampleName = if defined(outputPrefix) then outputPrefix else basename(assemblyScaffolds)

        command {
		prodigal -i ${assemblyScaffolds} -o ${sampleName}.prodigal.genes.fa -a ${sampleName}.prodigal.proteins.fa -d ${sampleName}.prodigal.nucl.genes.fa -s ${sampleName}.prodigal.potential_genes.fa

        }
        runtime {
                runtime_minutes: '${GEP_minutes}'
                cpus: '${GEP_threads}'
                mem: '${GEP_mem}'
        }
        output {
		File genesAlignmentOutput = "${sampleName}.prodigal.genes.fa"
		File proteinAlignmentOutput = "${sampleName}.prodigal.proteins.fa"
		File nucleotideGenesOutput = "${sampleName}.prodigal.nucl.genes.fa"
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
