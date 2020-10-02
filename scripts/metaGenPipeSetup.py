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
#group = parser.add_mutually_exclusive_group(required=True)
parser.add_argument('--batch-count', action='store_true', help='Prints the number of batches and then quits.')
parser.add_argument('--batch', type=int, help='The number of the batch to fetch. Default batch is numbered 0 and other batches are numbered 1, 2, 3... Default: 0', default=0)

#parser.add_argument('--paired', action='store_true', help='Only include paired-end reads.')
parser.add_argument('--inputs', type=str, help='The parent location where the script should create the directory with the input files. Default: ./inputs', default="inputs")
parser.add_argument('--outputs', type=str, help='The parent location where the input files should tell metaGenPipe to send the output files. Default: ./outputs', default="outputs" )
parser.add_argument('--scripts', type=str, help='The location of the metaGenPipe scripts. Default: ./scripts', default="./scripts")
parser.add_argument('--mf-config', type=str, help='The location of your Mediaflux config file. Default: ~/.Arcitecta/mflux.cfg', default="~/.Arcitecta/mflux.cfg")
parser.add_argument("--download", type=str2bool, nargs='?', const=True, default=True, help="Flag to download the files from mediaflux. Default: True")
parser.add_argument("--options-json", type=str, help="The location of the template options JSON file to use. Default: ./metaGenPipe.options.json", default="./metaGenPipe.options.json")
parser.add_argument("--input-json", type=str, help="The location of the template input JSON file to use. Default: ./metaGenPipe.json", default="./metaGenPipe.json")


def check_path_for_file( file_path ):
    if not file_path.exists():
        print("Cannot find file:", file_path)
        sys.exit(1)
    return str(file_path.resolve())


def get_options( template, outputs_dir ):
    """ 
    Makes a dictionary for the options for the metaGenPipe run.

    Takes inital values from a template JSON file and adds the outputs directory
    """

    with open(template, 'r') as f:
        data = json.load(f)

    data["final_workflow_outputs_dir"] = check_path_for_file( outputs_dir )

    return data

def get_settings( template, samples_filepath, scripts_path ):
    """ 
    Makes a dictionary for the input settings for the metaGenPipe run.

    Takes values from a template JSON file and adds the location of the metaGenPipe scripts and the input samples file.
    """
    with open(template, 'r') as f:
        data = json.load(f)

    data["metaGenPipe.inputSamplesFile"] = check_path_for_file(samples_filepath)
    data["metaGenPipe.bparser"] = check_path_for_file(scripts_path/"bparser.pl")
    data["metaGenPipe.xml_parser"] = check_path_for_file(scripts_path/"xml_parser.function.pl")
    data["metaGenPipe.orgID_2_name"] = check_path_for_file(scripts_path/"orgID_2_name.pl")
    data["metaGenPipe.interleaveShell"] = check_path_for_file(scripts_path/"interleave_fastq.sh")

    return data



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

max_batch_number = len(batch_set) if batch_set else 0
if args.batch < 0 or args.batch > max_batch_number:
    range = f"a number between 0 and {max_batch_number}" if max_batch_number > 0 else "0"
    print( f"Batch numbered {args.batch} is not allowed. Please choose {range}.")
    sys.exit(1)


batch = study.get('default_batch_runs') if args.batch == 0 else batch_set[args.batch+1]

inputs_dir = Path(args.inputs) / f"{study_accession}_{args.batch}"
inputs_dir.mkdir( parents=True, exist_ok=True )

samples_filepath = inputs_dir/ f"{study_accession}_{args.batch}.i.txt"
settings_filepath = inputs_dir/ f"{study_accession}_{args.batch}.json"
options_filepath  = inputs_dir/ f"{study_accession}_{args.batch}.options.json"

scripts_dir = Path(args.scripts)

outputs_dir = Path(args.outputs) / f"{study_accession}_{args.batch}_outputs"
outputs_dir.mkdir( parents=True, exist_ok=True )



######################################################
### Write the Input File and download the read files
######################################################
with open(samples_filepath, "w") as samples_file:
    for run in batch:
        # For now the workflow only uses paired-end reads, so exclude everything else
        if run['library_layout'] != "PAIRED":
            continue 

        if args.download:
            for file in run['files']:
                # This would be better to use the python mediaflux client: https://gitlab.unimelb.edu.au/resplat-mediaflux/python-mfclient
                os.system("unimelb-mf-download --mf.config %s --csum-check --out %s /projects/proj-6300_metagenomics_repository_verbruggenmdap-1128.4.294/%s" % (
                    args.mf_config,
                    inputs_dir,
                    file['mf_path_str'],
                ))
        
        filenames = [str((inputs_dir/Path(file['mf_path_str']).name).resolve()) for file in run['files']]
        filenames_str = "\t".join(filenames)
        samples_file.write(f"{run['accession']}\t{filenames_str}\n")
print("Created input samples text file with location of run files:", samples_filepath)


######################################################
#### Write the JSON Settings File
######################################################
settings = get_settings(args.input_json, samples_filepath, scripts_dir)
with open(settings_filepath, "w") as settings_file:
    json.dump(settings, settings_file, indent=4, sort_keys=False)
print("Created input JSON settings file:", settings_filepath)

######################################################
#### Write the JSON Options File
######################################################
options = get_options( args.options_json, outputs_dir)
with open(options_filepath, "w") as options_file:
    json.dump(options, options_file, indent=4, sort_keys=False)
print("Created options JSON file:", options_filepath)
print("Outputs of metaGenPipe will be sent to:", outputs_dir)
print()
print("You can use this command from the root directory of metaGenPipe to run this job:")
print("java -DLOG_MODE=pretty -Dconfig.file=./metaGenPipe.config -jar cromwell-52.jar run metaGenPipe.wdl -i %s -o %s" % (
    check_path_for_file(settings_filepath),
    check_path_for_file(options_filepath),
))
