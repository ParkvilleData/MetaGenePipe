## Metagenomics Assembly Pipeline
## Bobbie Shaban
## 28/06/2018
## Melbourne Integrative genomics
##

workflow metaGenePipe {
  File inputSamplesFile
  Array[Array[File]] inputSamples = read_tsv(inputSamplesFile)
  String idbaLocation
  String outputFolder
  File graftMLocation
  File refPackage
  File megahitLocation
  File megahit_asm_core
  File megahit_sdbg_build
  File megahit_toolkit
  File tigrHMM
  File pfamHMM
  File pfam_dat
  File active_site
  File pfam_h3f
  File pfam_h3i
  File pfam_h3m
  File pfam_h3p
  File tigrfam_h3f
  File tigrfam_h3i
  File tigrfam_h3m
  File tigrfam_h3p
  File tigrfam_info
  File tigrfam_seed
  File prodigalLocation

	scatter (sample in inputSamples){

		call emboss {
		    input:
			fastq1=sample[1],
                        fastq2=sample[2],
                        sampleName=sample[0]
		}

		call graftM {
                    input:
                        graftMLocation=graftMLocation,
                        sampleName=sample[0],
                        fastq1=sample[1],
                        fastq2=sample[2],
                        refPackage=refPackage
                }

		call idba {
	            input:
			idbaLocation=idbaLocation,
			idbaInputFasta=emboss.outputFasta,
			sampleName=sample[0]

		}

		call megahit {
		    input:
			megahitLocation=megahitLocation,
			megahit_asm_core=megahit_asm_core,
			megahit_sdbg_build=megahit_sdbg_build,
			megahit_toolkit=megahit_toolkit,
			sampleName=sample[0],
			fastq1=sample[1],
			fastq2=sample[2]
		}
		
		call prodigalMH {
		    input:
			contigs=megahit.megahitOutputFasta,
			prodigalLocation=prodigalLocation,
                        sampleName=sample[0]
		}

		call prodigalIDBA {
		   input:
			contigs=idba.idbaOutputFasta,
			prodigalLocation=prodigalLocation,
			sampleName=sample[0]
		}

		call pfam_idba {
	            input:
			prodigalIDBAProteinOutput=prodigalIDBA.prodigalIDBAProteinOutput,
			sampleName=sample[0],
			pfamHMM=pfamHMM,
			pfam_dat=pfam_dat,
			active_site=active_site,
			pfam_h3f=pfam_h3f,
			pfam_h3i=pfam_h3i,
			pfam_h3m=pfam_h3m,
			pfam_h3p=pfam_h3p

		}

		 call pfam_megahit {
                    input:
                        prodigalMHProteinOutput=prodigalMH.prodigalMHProteinOutput,
                        sampleName=sample[0],
                        pfamHMM=pfamHMM,
                        pfam_dat=pfam_dat,
                        active_site=active_site,
                        pfam_h3f=pfam_h3f,
                        pfam_h3i=pfam_h3i,
                        pfam_h3m=pfam_h3m,
                        pfam_h3p=pfam_h3p

                }

		call tigrfam_idba {
		    input:
			prodigalIDBAProteinOutput=prodigalIDBA.prodigalIDBAProteinOutput,
			sampleName=sample[0],
			tigrHMM=tigrHMM,
			tigrfam_h3f=tigrfam_h3f,
			tigrfam_h3i=tigrfam_h3i,
			tigrfam_h3m=tigrfam_h3m,
			tigrfam_h3p=tigrfam_h3p,
			tigrfam_info=tigrfam_info,
			tigrfam_seed=tigrfam_seed
		}

		call tigrfam_megahit {
                    input:
                        prodigalMHProteinOutput=prodigalMH.prodigalMHProteinOutput,
                        sampleName=sample[0],
                        tigrHMM=tigrHMM,
                        tigrfam_h3f=tigrfam_h3f,
                        tigrfam_h3i=tigrfam_h3i,
                        tigrfam_h3m=tigrfam_h3m,
                        tigrfam_h3p=tigrfam_h3p,
                        tigrfam_info=tigrfam_info,
                        tigrfam_seed=tigrfam_seed
                }

		call copy_output {
		    input:
			sampleName=sample[0],
			outputFolder=outputFolder,
			graftMoutputCombinedCount=graftM.combinedCount,
			idbaContigs=idba.idbaOutputFasta,
			megahitContigs=megahit.megahitOutputFasta,
			prodigalMHfna=prodigalMH.prodigalMHProteinOutput,
			prodigalMHfa=prodigalMH.prodigalMHNucleotideOutput,
			prodigalMHGff=prodigalMH.prodigalMHGffOutput,
			prodigalIDBAfna=prodigalIDBA.prodigalIDBAProteinOutput,
			prodigalIDBAfa=prodigalIDBA.prodigalIDBANucleotideOutput,
			prodigalIDBAGff=prodigalIDBA.prodigalIDBAGffOutput,
			idbaPfamOutput=pfam_idba.pfamOutput,
			idbaPfamTblOutput=pfam_idba.pfamTableOut,
			megahitPfamOutput=pfam_megahit.pfamOutput,
			megahitPfamTblOutput=pfam_megahit.pfamTableOut,
			tigrfamIDBAOutput=tigrfam_idba.tigrfamOutput,
			tigrfamIDBAtblOutput=tigrfam_idba.tigrfamTableOut,
			tigrfamMegahitOutput=tigrfam_megahit.tigrfamOutput,
			tigrfamMegahitTblOutput=tigrfam_megahit.tigrfamTableOut			
		}
	}
}

task emboss {
	File fastq1
	File fastq2
	String sampleName
	Int embossRunMinutes
	Int embossThreads
	Int embossMem

	command {
		module load EMBOSS
		
		fq2fa --merge ${fastq1} ${fastq2} ${sampleName}.fasta
        }
	output {
		File outputFasta="${sampleName}.fasta"
	}
        runtime {
                runtime_minutes: '${embossRunMinutes}'
                cpus: '${embossThreads}'
                mem: '${embossMem}'
        }

}

task graftM {
        Int graftMRunMinutes
        Int graftMThreads
        Int graftMMem
        File fastq1
        File fastq2
        File refPackage
        File graftMLocation
        String sampleName

        command {
                module load Python/2.7.12-vlsci_intel-2015.08.25
                module load diamond/0.9.10
                module load fxtract/2.3-GCC-4.9.4
                module load HMMER/3.1b2-vlsci_intel-2015.08.25
                module load Krona
                module load orfm/0.7.1
                module load pplacer
                module load HDF5

                ${graftMLocation} graft --forward ${fastq1} --reverse ${fastq2} --graftm_package ${refPackage} --output_directory eg.graftm --threads ${graftMThreads}
        }
        runtime {
                runtime_minutes: '${graftMRunMinutes}'
                cpus: '${graftMThreads}'
                mem: '${graftMMem}'
        }
        output {
                String directory=sub("${fastq1}", ".fastq", "")
                File combinedCount = "eg.graftm/combined_count_table.txt"
        }
}

task idba{
        File idbaInputFasta
        String sampleName
	File idbaLocation
	Int idbaRunMinutes
	Int idbaThreads
	Int idbaMem

        command {

		${idbaLocation} -o ${sampleName}_assembly -r ${idbaInputFasta} --num_threads ${idbaThreads}
        }
	runtime {
		runtime_minutes: '${idbaRunMinutes}'
		cpus: '${idbaThreads}'
		mem: '${idbaMem}'
	}
	output {
		File idbaOutputFasta = "${sampleName}_assembly/contig.fa"
	}
}

task megahit {
	Int megahitRunMinutes
	Int megahitThreads
	Int megahitMem
	File fastq1
	File fastq2
	File megahitLocation
	File megahit_asm_core
	File megahit_sdbg_build
	File megahit_toolkit
	String sampleName

	command {

		${megahitLocation}  -1 ${fastq1} -2 ${fastq2} -o ${sampleName}_assembly
	}
	runtime {
		runtime_minutes: '${megahitRunMinutes}'
		cpus: '${megahitThreads}'
		mem: '${megahitMem}'
	}
	output {
		File megahitOutputFasta = "${sampleName}_assembly/final.contigs.fa"
	}
}

task prodigalMH {
	File contigs
	File prodigalLocation
	String prodigalMHOutputFormat
	String sampleName
	Int prodigalMHRunMinutes
	Int prodigalMHThreads
	Int prodigalMHMem

	command {
		${prodigalLocation} -i ${contigs} -o ${sampleName}.genes.mh.gff -f ${prodigalMHOutputFormat} -d ${sampleName}.prodigal.mh.nucl.fa -a ${sampleName}.prodigal.mh.protein.fa
	}
	output {
		File prodigalMHProteinOutput="${sampleName}.prodigal.mh.protein.fa"
		File prodigalMHNucleotideOutput="${sampleName}.prodigal.mh.nucl.fa"
		File prodigalMHGffOutput="${sampleName}.genes.mh.gff"
	}
	runtime {
		runtime_minutes: '${prodigalMHRunMinutes}'
		cpus: '${prodigalMHThreads}'
		mem: '${prodigalMHMem}'
	}
}

task prodigalIDBA {
        File contigs
        File prodigalLocation
        String prodigalIDBAOutputFormat
        String sampleName
        Int prodigalIDBARunMinutes
        Int prodigalIDBAThreads
        Int prodigalIDBAMem

        command {
                ${prodigalLocation} -i ${contigs} -o ${sampleName}.genes.idba.gff -f ${prodigalIDBAOutputFormat} -d ${sampleName}.prodigal.idba.nucl.fa -a ${sampleName}.prodigal.idba.protein.fa
        }
        output {
                File prodigalIDBAProteinOutput="${sampleName}.prodigal.idba.protein.fa"
                File prodigalIDBANucleotideOutput="${sampleName}.prodigal.idba.nucl.fa"
                File prodigalIDBAGffOutput="${sampleName}.genes.idba.gff"
        }
        runtime {
                runtime_minutes: '${prodigalIDBARunMinutes}'
                cpus: '${prodigalIDBAThreads}'
                mem: '${prodigalIDBAMem}'
        }
}


task pfam_idba {
	Int pfamIDBARunMinutes
	Int pfamIDBAThreads
	Int pfamIDBAMem
        String sampleName
	File prodigalIDBAProteinOutput
	File pfamHMM
	File active_site
	File pfam_dat
	File pfam_h3f
	File pfam_h3i
	File pfam_h3m
	File pfam_h3p

	command {
		module load HMMER
	
		hmmscan -o ${sampleName}.idba.pfam --domtblout ${sampleName}.idba.domtbl.pfam --cpu ${pfamIDBAThreads} --noali -E 1e-40 ${pfamHMM} ${prodigalIDBAProteinOutput}
        }
        output {
		File pfamOutput="${sampleName}.idba.pfam"
		File pfamTableOut="${sampleName}.idba.domtbl.pfam"
	       }
        runtime {
                runtime_minutes: '${pfamIDBARunMinutes}'
                cpus: '${pfamIDBAThreads}'
                mem: '${pfamIDBAMem}'
	}
}

task pfam_megahit {
        Int pfamMHRunMinutes
        Int pfamMHThreads
        Int pfamMHMem
        String sampleName
        File prodigalMHProteinOutput
        File pfamHMM
        File active_site
        File pfam_dat
        File pfam_h3f
        File pfam_h3i
        File pfam_h3m
        File pfam_h3p

        command {
                module load HMMER

                hmmscan -o ${sampleName}.megahit.pfam --domtblout ${sampleName}.megahit.domtbl.pfam --cpu ${pfamMHThreads} --noali -E 1e-40 ${pfamHMM} ${prodigalMHProteinOutput}
        }
        output {
                File pfamOutput="${sampleName}.megahit.pfam"
                File pfamTableOut="${sampleName}.megahit.domtbl.pfam"
               }
        runtime {
                runtime_minutes: '${pfamMHRunMinutes}'
                cpus: '${pfamMHThreads}'
                mem: '${pfamMHMem}'
        }
}

task tigrfam_idba {
	Int tigrfamIDBARunMinutes
	Int tigrfamIDBAThreads
	Int tigrfamIDBAMem
	String sampleName
	File prodigalIDBAProteinOutput
	File tigrHMM
	File tigrfam_h3f
	File tigrfam_h3i
	File tigrfam_h3m
	File tigrfam_h3p
	File tigrfam_info
	File tigrfam_seed

	command {
		module load HMMER

		hmmscan -o ${sampleName}.idba.tigrfam --domtblout ${sampleName}.idba.domtbl.tigrfam --cpu ${tigrfamIDBAThreads} --noali -E 1e-40 ${tigrHMM} ${prodigalIDBAProteinOutput} 	
        }
        output {
		File tigrfamOutput="${sampleName}.idba.tigrfam"
		File tigrfamTableOut="${sampleName}.idba.domtbl.tigrfam"
        }
        runtime {
                runtime_minutes: '${tigrfamIDBARunMinutes}'
                cpus: '${tigrfamIDBAThreads}'
                mem: '${tigrfamIDBAMem}'
	}
}

task tigrfam_megahit {
        Int tigrfamMHRunMinutes
        Int tigrfamMHThreads
        Int tigrfamMHMem
        String sampleName
        File prodigalMHProteinOutput
        File tigrHMM
        File tigrfam_h3f
        File tigrfam_h3i
        File tigrfam_h3m
        File tigrfam_h3p
        File tigrfam_info
        File tigrfam_seed

        command {
                module load HMMER

                hmmscan -o ${sampleName}.megahit.tigrfam --domtblout ${sampleName}.megahit.domtbl.tigrfam --cpu ${tigrfamMHThreads} --noali -E 1e-40 ${tigrHMM} ${prodigalMHProteinOutput}
        }
        output {
                File tigrfamOutput="${sampleName}.megahit.tigrfam"
                File tigrfamTableOut="${sampleName}.megahit.domtbl.tigrfam"
        }
        runtime {
                runtime_minutes: '${tigrfamMHRunMinutes}'
                cpus: '${tigrfamMHThreads}'
                mem: '${tigrfamMHMem}'
        }
}

task copy_output {
	String sampleName
	String outputFolder
	File graftMoutputCombinedCount
        File idbaContigs
        File megahitContigs
        File prodigalMHfna
        File prodigalMHfa
        File prodigalMHGff
        File prodigalIDBAfna
        File prodigalIDBAfa
        File prodigalIDBAGff
        File idbaPfamOutput
        File idbaPfamTblOutput
        File megahitPfamOutput
        File megahitPfamTblOutput
        File tigrfamIDBAOutput
        File tigrfamIDBAtblOutput
        File tigrfamMegahitOutput
        File tigrfamMegahitTblOutput

	command {
		mkdir "${outputFolder}/${sampleName}"
		cp ${graftMoutputCombinedCount} ${idbaContigs} ${megahitContigs} ${prodigalMHfna} ${prodigalMHfa} ${prodigalMHGff} ${prodigalIDBAfna} ${prodigalIDBAfa} ${prodigalIDBAGff} ${idbaPfamOutput} ${idbaPfamTblOutput} ${megahitPfamOutput} ${megahitPfamTblOutput} ${tigrfamIDBAOutput} ${tigrfamIDBAtblOutput} ${tigrfamMegahitOutput} ${tigrfamMegahitTblOutput} "${outputFolder}/${sampleName}"
	}
}
