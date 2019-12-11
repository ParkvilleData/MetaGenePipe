## Metagenomics pipeline 15/08/19
## Bobbie Shaban
## 
## Melbourne Integrative Genomics
## Updated on 02/09/19
## Metagenomics pipeline as per phase 4 testing notes


##import of tasks from individual wdl files
import "./tasks/geneprediction.wdl" as genePredictionTask
import "./tasks/diamond.wdl" as diamondTask  
import "./tasks/fastqc.wdl" as fastqcTask
import "./tasks/flash.wdl" as flashTask  
import "./tasks/hostremoval.wdl" as hostRemovalTask
import "./tasks/idba.wdl" as idbaTask
import "./tasks/blast.wdl" as blastTask
import "./tasks/interleave.wdl" as interLeaveTask
import "./tasks/megahit.wdl" as megahitTask  
import "./tasks/collation.wdl" as collationTask
import "./tasks/xml_parser.wdl" as xmlParserTask
import "./tasks/copyoutput.wdl" as copyOutputTask

workflow metaGenPipe {

#global variables for wdl workflow
File inputSamplesFile
Array[Array[File]] inputSamples = read_tsv(inputSamplesFile)
String outputDir
String outputFileName
String scriptsDirectory
String workingDir
String removeMouseSequence
String removalSequence
String ntDatabase
Int numOfHits
File bparser
File kolist
File koFormattedFile
File keggSpeciesFile
File DB
File taxRankFile
File fullLineageFile
File blast

   scatter (sample in inputSamples) {

	call fastqcTask.fastqc_task {
	    Int fastqcRunThreads 
	    Int fastqcRunMinutes
	    Int fastqcRunMem

            input: inputFastqRead1=sample[1],inputFastqRead2=sample[2],sampleName=sample[0],outputDir=outputDir,workingDir=workingDir
	}

	call flashTask.flash_task {
	    Int flashRunThreads 
	    Int flashRunMinutes
	    Int flashRunMem

            input: inputFastqRead1=sample[1],inputFastqRead2=sample[2],sampleName=sample[0],outputDir=outputDir,workingDir=workingDir
	}

	call interLeaveTask.interleave_task {
	    Int interLeaveRunThreads
            Int interLeaveRunMinutes
            Int interLeaveRunMem		

	    input: flashNotCombined1=flash_task.flashArray[1], flashNotCombined2=flash_task.flashArray[2], flashExtended=flash_task.flashArray[0], sampleName=sample[0], outputDir=outputDir,workingDir=workingDir
	}

	 call hostRemovalTask.hostremoval_task {
	    Int hostRemovalRunThreads
	    Int hostRemovalRunMinutes
	    Int hostRemovalRunMem 

            input: flashMergedFastq=interleave_task.flashMergedFastq,sampleName=sample[0],outputDir=outputDir,workingDir=workingDir,removalSequence=removeMouseSequence
        }

	call hostRemovalTask.hostremoval_task as sequence_removal_task {

            input: flashMergedFastq=interleave_task.flashMergedFastq,sampleName=sample[0],outputDir=outputDir,workingDir=workingDir,removalSequence=removalSequence
        }

	call idbaTask.idba_task {
	   Int idbaRunThreads
	   Int idbaRunMinutes
	   Int idbaRunMem

	   input: sampleName=sample[0],cleanFastq=sequence_removal_task.hostRemovalArray[0]
	
	}

	call blastTask.blast_task {
           Int blastRunThreads
           Int blastRunMinutes
           Int blastRunMem

           input: numOfHits=numOfHits,blast=blast,sampleName=sample[0],scriptsDirectory=scriptsDirectory,database=ntDatabase,inputScaffolds=idba_task.scaffoldFasta,numOfHits=numOfHits,bparser=bparser,workingDir=workingDir

        }

	call megahitTask.megahit_task {
	    Int megaHitRunThreads
            Int megaHitRunMinutes
            Int megaHitRunMem

	    input: sampleName=sample[0],outputDir=outputDir,deconseqReadFile=hostremoval_task.hostRemovalArray[0],workingDir=workingDir	

	}

	call genePredictionTask.geneprediction_task {
            Int genePredictionRunThreads
            Int genePredictionRunMinutes
            Int genePredictionRunMem

            input: sampleName=sample[0],outputDir=outputDir,megahitOutputTranscripts=megahit_task.megahitArray[0],workingDir=workingDir

        }
	
	 call diamondTask.diamond_task {
            Int diamondRunThreads
            Int diamondRunMinutes
            Int diamondRunMem

            input: database=DB,sampleName=sample[0],outputDir=outputDir,genesAlignmentOutput=geneprediction_task.proteinAlignmentOutput,workingDir=workingDir
        }
		
	call collationTask.collation_task {
            Int collationRunThreads
            Int collationRunMinutes
            Int collationRunMem

            input: sampleName=sample[0],outputDir=outputDir,inputXML=diamond_task.diamondOutput,workingDir=workingDir
        }
   }
	
	#end of scatter
	call xmlParserTask.xmlparser_task {
            Int xmlParserRunThreads
            Int xmlParserRunMinutes
            Int xmlParserRunMem

            input: outputDir=outputDir,taxRankFile=taxRankFile,fullLineageFile=fullLineageFile,scriptsDirectory=scriptsDirectory,koFormattedFile=koFormattedFile,keggSpeciesFile=keggSpeciesFile,outputFileName=outputFileName,scatterCompleteFlag=collation_task.scatterCompleteFlag,workingDir=workingDir
        }

	call copyOutputTask.copyoutput_task {
	    Int copyOutputRunThreads
            Int copyOutputRunMinutes
            Int copyOutputRunMem

	     input: outputDir=outputDir,all_level_table=xmlparser_task.outputArray[0],gene_count_table=xmlparser_task.outputArray[1],level_one=xmlparser_task.outputArray[2],level_two=xmlparser_task.outputArray[3],level_three=xmlparser_task.outputArray[4],workingDir=workingDir,scaffoldsParsed=blast_task.parsedOutput
 	}
}
## end of worklfow metaGenPipe

