############################################
#
# metaGenPipe genePrediction WDL function
# Bobbie Shaban	
# Should be reusable inbetween tasks
# Performs genePrediction of genes
# will attempt to be reusable
##########################################


task geneprediction_task {
	Int genePredictionRunThreads
        Int genePredictionRunMinutes
        Int genePredictionRunMem
        File megahitOutputTranscripts
	String outputDir
        String sampleName

        command {
                module load prodigal
		
		prodigal -i '${megahitOutputTranscripts}' -o '${sampleName}'.prodgial.genes.fa -a '${sampleName}'.prodigal.proteins.fa -d '${sampleName}'.prodigal.nucl.genes.fa -s '${sampleName}'.prodigal.potential_genes.fa

        }
        runtime {
                runtime_minutes: '${genePredictionRunMinutes}'
                cpus: '${genePredictionRunThreads}'
                mem: '${genePredictionRunMem}'
        }
        output {
		File genesAlignmentOutput = "${sampleName}.prodgial.genes.fa"
		File proteinAlignmentOutput = "${sampleName}.prodigal.proteins.fa"
		File nucleotiedGenesOutput = "${sampleName}.prodigal.nucl.genes.fa"
		File potentialGenesAlignmentOutput = "${sampleName}.prodigal.potential_genes.fa"
        }        
}
