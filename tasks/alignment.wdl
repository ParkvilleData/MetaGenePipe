############################################
#
# metaGenPipe alignment WDL function
# Bobbie Shaban	
# Should be reusable inbetween tasks
# Performs alignment of genes
# will attempt to be reusable
##########################################


task alignment_task {
	Int alignmentRunThreads
        Int alignmentRunMinutes
        Int alignmentRunMem
        File megahitOutputTranscripts
	String outputDir
        String sampleName

        command {
                module load prodigal
		
		prodigal -i '${megahitOutputTranscripts}' -o '${sampleName}'.prodgial.genes.fa -a '${sampleName}'.prodigal.proteins.fa -d '${sampleName}'.prodigal.nucl.genes.fa -s '${sampleName}'.prodigal.potential_genes.fa

        }
        runtime {
                runtime_minutes: '${alignmentRunMinutes}'
                cpus: '${alignmentRunThreads}'
                mem: '${alignmentRunMem}'
        }
        output {
		File genesAlignemntOutput = "${sampleName}.prodgial.genes.fa"
		File proteinAlignmentOutput = "${sampleName}.prodigal.proteins.fa"
		File nucleotiedGenesOutput = "${sampleName}.prodigal.nucl.genes.fa"
		File potentialGenesAlignmentOutput = "${sampleName}.prodigal.potential_genes.fa"
        }        
}
