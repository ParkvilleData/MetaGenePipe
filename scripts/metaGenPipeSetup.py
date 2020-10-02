#!/usr/bin/env python

import requests
from pathlib import Path
import argparse
import sys
import os
import json


def str2bool(v):
    """ https://stackoverflow.com/a/43357954 """
    if isinstance(v, bool):
       return v
    if v.lower() in ('yes', 'true', 't', 'y', '1'):
        return True
    elif v.lower() in ('no', 'false', 'f', 'n', '0'):
        return False
    else:
        raise argparse.ArgumentTypeError('Boolean value expected.')


parser = argparse.ArgumentParser(description='Script to create input files for metaGenPipe workflow on Spartan and to download the run files from Mediaflux.')
parser.add_argument("study_accession", help="The accession for the study to be retreived.")
group = parser.add_mutually_exclusive_group(required=True)
group.add_argument('--batch-count', action='store_true', help='Prints the number of batches and then quits.')
group.add_argument('--batch', type=int, help='The number of the batch to fetch. Default batch is numbered 0 and other batches are numbered 1, 2, 3...')

#parser.add_argument('--paired', action='store_true', help='Only include paired-end reads.')
parser.add_argument('--dest', type=str, help='The destination location where the script should create the directory with the files.', default=".")
parser.add_argument('--scripts', type=str, help='The location of the metaGenPipe scripts.', default="./scripts")
parser.add_argument('--mf-config', type=str, help='The location of your Mediaflux config file.', default="~/.Arcitecta/mflux.cfg")
#parser.add_argument('--no-download', action='store_false', help='Flag to not download the files from mediaflux.')
parser.add_argument("--download", type=str2bool, nargs='?', const=True, default=True, help="Flag to download the files from mediaflux.")


def check_path_for_file( file_path ):
    if not file_path.exists():
        print("Cannot find file:", file_path)
        sys.exit(1)
    return str(file_path)

def get_settings( input_file_path, scripts_path ):
    """ 
    Makes a dictionary for the settings for the metaGenPipe run.

    Values taken from defaults for Spartan in the metaGenPipe repository.
    """

    # Set up variables so that we can easily put JSON syntax into Python
    true = True
    false = False

    # Get Absolute Paths
    input_file_path = input_file_path.resolve()
    scripts_path = scripts_path.resolve()

    return {
        "## Boolean list": "True or false for setting optional tasks",
        "metaGenPipe.flashBoolean": false,
        "metaGenPipe.hostRemovalBoolean": false,
        "metaGenPipe.blastBoolean": true,
        "metaGenPipe.mergeBoolean": true,
        "metaGenPipe.taxonBoolean": false,
        "## assembly parameters": "metaspades/idba/megahit",
        "metaGenPipe.metaspadesBoolean": false,
        "metaGenPipe.idbaBoolean": false,
        "metaGenPipe.megahitBoolean": true,

        "##_GLBOAL_VARS#": "files",
        "metaGenPipe.inputSamplesFile": check_path_for_file(input_file_path),
        "metaGenPipe.bparser": check_path_for_file(scripts_path/"bparser.pl"),
        "metaGenPipe.xml_parser": check_path_for_file(scripts_path/"xml_parser.function.pl"),
        "metaGenPipe.orgID_2_name": check_path_for_file(scripts_path/"orgID_2_name.pl"),
        "metaGenPipe.interleaveShell": check_path_for_file(scripts_path/"interleave_fastq.sh"),
        
        "## required reference files on shared project ##": "Don't need to change",
        "metaGenPipe.database": "/data/gpfs/datasets/BLAST/db/nt",
        "metaGenPipe.taxRankFile": "/data/gpfs/projects/punim0639/metaGenPipe/tax_rank",
        "metaGenPipe.fullLineageFile": "/data/gpfs/projects/punim0639/metaGenPipe/fullnamelineage.dmp",
        "metaGenPipe.keggSpeciesFile": "/data/gpfs/projects/punim0639/metaGenPipe/eukaryotes.dat",
        "metaGenPipe.DB": "/data/gpfs/projects/punim0639/databases/metaGenePipe/kegg/kegg-eukaryotes.dmnd",
        "metaGenPipe.kolist": "/data/gpfs/projects/punim0639/metaGenPipe/ko.sorted.txt",
        "metaGenPipe.koFormattedFile": "/data/gpfs/projects/punim0639/metaGenPipe/formatted.xml.out",

        "## output prefixes": "Multiqc/merged",
        "metaGenPipe.multiQCoutput": "multiQC",
        "## output prefix ##": "If running nonMerged mode leave blank: mergeBoolean variable needs to be true",
        "metaGenPipe.mergedOutput": "MergeDataset",

        "## assembly parameters ###": "megahit",
        "metaGenPipe.qc_subworkflow.trimmomatic_task.trimmomatic": "java -jar /local_build/bin/trimmomatic-0.39.jar",

        "## software calls": "trimmomatic etc",
            "metaGenPipe.preset": "meta-sensitive",
        
        "## trimmomatic adapters and parameters": "",
        "metaGenPipe.qc_subworkflow.trimmomatic_task.truseq_pe_adapter":"./adapters/TruSeq3-PE.fa",
        "metaGenPipe.qc_subworkflow.trimmomatic_task.truseq_se_adapter":"./adapters/TruSeq3-SE.fa",
        "metaGenPipe.qc_subworkflow.trimmomatic_task.Phred": "33",
        "metaGenPipe.qc_subworkflow.trimmomatic_task.EndType": "PE",
        "metaGenPipe.qc_subworkflow.trimmomatic_task.minLength": "50",

        "##host removal parameters": "deconseq",
        "metaGenPipe.identityPercentage": 70,
        "metaGenPipe.coverage": 70,
        "metaGenPipe.removalSequence": "mm1,mm2,mm3,mm4,mm5,mm6",
        "metaGenPipe.hostremoval_subworkflow.removalSequence": "mm1,mm2,mm3,mm4,mm5,mm6",

        "## geneprediction ##": "##Parameters",
        "metaGenPipe.mode": "meta",
        "metaGenPipe.maxTargetSeqs": 1,
        "metaGenPipe.blastMode": "blastp",
        "metaGenPipe.outputType": 5,

        "metaGenPipe.outputFileName": "geneCountTable.txt",
        "metaGenPipe.numOfHits": 10,

        "##_COMMENT_1#": "fastqc",
        "metaGenPipe.qc_subworkflow.fastqc_task.FQC_threads": 6,
        "metaGenPipe.qc_subworkflow.fastqc_task.FQC_minutes": 15,
        "metaGenPipe.qc_subworkflow.fastqc_task.FQC_mem": 10000,

        "##_COMMENT_2#": "trimmomatic",
        "metaGenPipe.qc_subworkflow.trimmomatic_task.TRIM_threads": 6,
        "metaGenPipe.qc_subworkflow.trimmomatic_task.TRIM_minutes": 15,
        "metaGenPipe.qc_subworkflow.trimmomatic_task.TRIM_mem": 20000,

        "##_COMMENT_3#": "flash",
        "metaGenPipe.qc_subworkflow.flash_task.FLA_threads": 6,
        "metaGenPipe.qc_subworkflow.flash_task.FLA_minutes": 15,
        "metaGenPipe.qc_subworkflow.flash_task.FLA_mem": 20000,

        "##_COMMENT_4#": "multiqc",
        "metaGenPipe.multiqc_task.MQC_threads": 6,
        "metaGenPipe.multiqc_task.MQC_minutes": 15,
        "metaGenPipe.multiqc_task.MQC_mem": 20000,

        "##_COMMENT_4#": "multiqc",
        "metaGenPipe.merge_task.MGS_threads": 6,
        "metaGenPipe.merge_task.MGS_minutes": 15,
        "metaGenPipe.merge_task.MGS_mem": 20000,

        "##_COMMENT_5#": "interleave shell",
        "metaGenPipe.hostremoval_subworkflow.interleave_task.ILE_threads": 6,
        "metaGenPipe.hostremoval_subworkflow.interleave_task.ILE_minutes": 100,
        "metaGenPipe.hostremoval_subworkflow.interleave_task.ILE_mem": 60000,

        "##_COMMENT_6#": "host removal ",
        "metaGenPipe.hostremoval_subworkflow.hostremoval_task.HRM_threads": 6,
        "metaGenPipe.hostremoval_subworkflow.hostremoval_task.HRM_minutes": 6000,
        "metaGenPipe.hostremoval_subworkflow.hostremoval_task.HRM_mem": 60000,

        "##_COMMENT_8#": "IDBA assembly ",
        "metaGenPipe.assembly_subworkflow.idba_task.IDBA_threads": 6,
        "metaGenPipe.assembly_subworkflow.idba_task.IDBA_minutes": 100,
        "metaGenPipe.assembly_subworkflow.idba_task.IDBA_mem": 30000,

        "##_COMMENT_8#": "IDBA assembly ",
        "metaGenPipe.nonMergedAssembly.idba_task.IDBA_threads": 6,
        "metaGenPipe.nonMergedAssembly.idba_task.IDBA_minutes": 100,
        "metaGenPipe.nonMergedAssembly.idba_task.IDBA_mem": 30000,

        "##_COMMENT_9#": "Blast ",
        "metaGenPipe.assembly_subworkflow.blast_task.BLST_threads": 6,
        "metaGenPipe.assembly_subworkflow.blast_task.BLST_minutes": 100,
        "metaGenPipe.assembly_subworkflow.blast_task.BLST_mem": 30000,

        "##_COMMENT_9#": "Blast ",
        "metaGenPipe.nonMergedAssembly.blast_task.BLST_threads": 6,
        "metaGenPipe.nonMergedAssembly.blast_task.BLST_minutes": 100,
        "metaGenPipe.nonMergedAssembly.blast_task.BLST_mem": 30000,

        "##_COMMENT_10#": "Megahit ",
        "metaGenPipe.assembly_subworkflow.megahit_task.MEH_threads": 6,
        "metaGenPipe.assembly_subworkflow.megahit_task.MEH_minutes": 100,
        "metaGenPipe.assembly_subworkflow.megahit_task.MEH_mem": 30000,

        "##_COMMENT_10#": "Megahit ",
        "metaGenPipe.nonMergedAssembly.megahit_task.MEH_threads": 6,
        "metaGenPipe.nonMergedAssembly.megahit_task.MEH_minutes": 100,
        "metaGenPipe.nonMergedAssembly.megahit_task.MEH_mem": 30000,

        "##_COMMENT_10#": "Metaspades assembly ",
        "metaGenPipe.assembly_subworkflow.metaspades_task.MES_threads": 6,
        "metaGenPipe.assembly_subworkflow.metaspades_task.MES_minutes": 100,
        "metaGenPipe.assembly_subworkflow.metaspades_task.MES_mem": 30000,

        "##_COMMENT_10#": "Metaspades assembly ",
        "metaGenPipe.nonMergedAssembly.metaspades_task.MES_threads": 6,
        "metaGenPipe.nonMergedAssembly.metaspades_task.MES_minutes": 100,
        "metaGenPipe.nonMergedAssembly.metaspades_task.MES_mem": 30000,

        "##_COMMENT_11#": "gene prediction ",
        "metaGenPipe.geneprediction_subworkflow.prodigal_task.GEP_threads": 6,
        "metaGenPipe.geneprediction_subworkflow.prodigal_task.GEP_minutes": 100,
        "metaGenPipe.geneprediction_subworkflow.prodigal_task.GEP_mem": 30000,

        "##_COMMENT_11#": "gene prediction ",
        "metaGenPipe.nonMergedGenePrediction.prodigal_task.GEP_threads": 6,
        "metaGenPipe.nonMergedGenePrediction.prodigal_task.GEP_minutes": 100,
        "metaGenPipe.nonMergedGenePrediction.prodigal_task.GEP_mem": 30000,

        "##_COMMENT_12#": "diamond alignment ",
        "metaGenPipe.geneprediction_subworkflow.diamond_task.DIM_threads": 6,
        "metaGenPipe.geneprediction_subworkflow.diamond_task.DIM_minutes": 10000,
        "metaGenPipe.geneprediction_subworkflow.diamond_task.DIM_mem": 60000,

        "##_COMMENT_12#": "diamond alignment ",
        "metaGenPipe.nonMergedGenePrediction.diamond_task.DIM_threads": 6,
        "metaGenPipe.nonMergedGenePrediction.diamond_task.DIM_minutes": 10000,
        "metaGenPipe.nonMergedGenePrediction.diamond_task.DIM_mem": 60000,

        "##_COMMENT_13#": "collation task ",
        "metaGenPipe.geneprediction_subworkflow.collation_task.COL_threads": 2,
        "metaGenPipe.geneprediction_subworkflow.collation_task.COL_minutes": 10000,
        "metaGenPipe.geneprediction_subworkflow.collation_task.COL_mem": 60000,

        "##_COMMENT_13#": "collation task ",
        "metaGenPipe.nonMergedGenePrediction.collation_task.COL_threads": 2,
        "metaGenPipe.nonMergedGenePrediction.collation_task.COL_minutes": 10000,
        "metaGenPipe.nonMergedGenePrediction.collation_task.COL_mem": 60000,

        "##_COMMENT_14#": "XML parsing ",
        "metaGenPipe.taxonclass_task.XMLP_threads": 2,
        "metaGenPipe.taxonclass_task.XMLP_minutes": 10000,
        "metaGenPipe.taxonclass_task.XMLP_mem": 60000

    }


args = parser.parse_args()

token = "65781117cf4a4dbfebc172a8e6c8c18bee1c98aa"

######################################################
#### Get info for study from website API
#### https://mma.robturnbull.com/mma/api/study/
######################################################
study_accession = args.study_accession
study = requests.get(f"https://mma.robturnbull.com/mma/api/study/{study_accession}/" , headers={"Authorization": f"Token {token}" }).json()
batch_set = study.get('batch_set')

if args.batch_count:
    print(len(batch_set)+1) # The additional one is for the default batch
    sys.exit()

max_batch_number = len(batch_set)
if args.batch < 0 or args.batch > max_batch_number:
    range = f"a number between 0 and {max_batch_number}" if max_batch_number > 0 else "0"
    print( f"Batch numbered {args.batch} is not allowed. Please choose {range}.")
    sys.exit(1)


batch = study.get('default_batch_runs') if args.batch == 0 else batch_set[args.batch+1]

dest = Path(args.dest)
directory = dest / f"{study_accession}_{args.batch}"
directory.mkdir( parents=True, exist_ok=True )
input_filepath = directory/ f"{study_accession}_{args.batch}.input.txt"
settings_filepath = directory/ f"{study_accession}_{args.batch}.settings.json"

scripts_dir = Path(args.scripts)


######################################################
### Write the Input File and download the read files
######################################################
with open(input_filepath, "w") as input_file:
    for run in batch:
        # For now the workflow only uses paired-end reads, so exclude everything else
        if run['library_layout'] != "PAIRED":
            continue 

        if args.download:
            for file in run['files']:
                # This would be better to use the python mediaflux client: https://gitlab.unimelb.edu.au/resplat-mediaflux/python-mfclient
                os.system("unimelb-mf-download --mf.config %s --csum-check --out %s /projects/proj-6300_metagenomics_repository_verbruggenmdap-1128.4.294/%s" % (
                    args.mf_config,
                    directory,
                    file['mf_path_str'],
                ))
        
        filenames = [Path(file['mf_path_str']).name for file in run['files']]
        filenames_str = "\t".join(filenames)
        input_file.write(f"{run['accession']}\t{filenames_str}\n")



######################################################
#### Write the JSON Settings File
######################################################
settings = get_settings(input_filepath, scripts_dir)
with open(settings_filepath, "w") as settings_file:
    json.dump(settings, settings_file, indent=4, sort_keys=False)

