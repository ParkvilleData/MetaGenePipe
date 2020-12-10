#!/usr/bin/env python

import requests
from pathlib import Path
import argparse
import sys
import os
import json
import re

from mfclient import mfclient

class EnvDefault(argparse.Action):
    """
    Sets a default value for argparse from an environment variable.

    https://stackoverflow.com/a/10551190
    """
    def __init__(self, envvar, required=True, default=None, **kwargs):
        if not default and envvar:
            if envvar in os.environ:
                default = os.environ[envvar]
        if required and default:
            required = False
        super(EnvDefault, self).__init__(default=default, required=required, 
                                         **kwargs)

    def __call__(self, parser, namespace, values, option_string=None):
        setattr(namespace, self.dest, values)


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
parser.add_argument('--mf-user', type=str, help="The user for your Mediaflux account. Optional.", default="")
parser.add_argument('--mf-token', type=str, help="The authentication token for your Mediaflux account. This requires a token with at least a 'participant-a' project role and the IP address you are using needs to be allowed. Optional.", default="")
parser.add_argument(
    '--mma-token', 
    type=str, 
    action=EnvDefault, 
    envvar='MMA_TOKEN', 
    help="The authentication token for logging in to the Melbourne Metagenomic Archive. Can be set with the MMA_TOKEN environment variable.", 
    default="",
)
parser.add_argument("--download", type=str2bool, nargs='?', const=True, default=True, help="Flag to download the files from mediaflux. Default: True")
parser.add_argument("--options-json", type=str, help="The location of the template options JSON file to use. Default: ./metaGenPipe.options.json", default="./metaGenPipe.options.json")
parser.add_argument("--input-json", type=str, help="The location of the template input JSON file to use. Default: ./metaGenPipe.json", default="./metaGenPipe.json")
parser.add_argument("--config", type=str, help="The location of the template config file to use. Default: ./metaGenPipe.config", default="./metaGenPipe.config")

def get_asset_metadata(connection, asset_id):
    """ Gets asset metadata.

    :param connection: Mediaflux server connection object
    :type connection: mfclient.MFConnection
    :param asset_id: Asset id
    :type asset_id: int or str
    :return: asset metadata XmlElement object
    :rtype: mfclient.XmlElement
    """
    # compose service arguments
    w = mfclient.XmlStringWriter('args')
    w.add('id', asset_id)

    # run asset.get service
    result = connection.execute('asset.get', w.doc_text())

    asset_metadata = result.element('asset')
    return asset_metadata



def get_asset_content(connection, asset_id, output_file_path):
    """ Gets asset metadata.

    :param connection: Mediaflux server connection object
    :type connection: mfclient.MFConnection
    :param asset_id: Asset id
    :type asset_id: int or str
    :return:

    See https://gitlab.unimelb.edu.au/resplat-mediaflux/python-mfclient/blob/master/examples/manage_asset_with_content.py
    """
    # compose service arguments
    w = mfclient.XmlStringWriter('args')
    w.add('id', asset_id)

    output = mfclient.MFOutput(path=output_file_path)
    #print(output, 'output')

    # run asset.get service
    result = connection.execute('asset.get', w.doc_text(), outputs=[output])
    #print(result, 'result')


    asset_metadata = result.element('asset')
    return asset_metadata



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

    return data

def write_config( template, outputs_dir, config_filepath ):
    """ 
    Adjusts the ouput directory for the optimisation scripts
    """
    # Read in the file
    with open(template, 'r') as file :
        filedata = file.read()

    # Replace the optim output directory
    filedata = filedata.replace('optim_directory = "$PWD/outputs', f'optim_directory = "{check_path_for_file(outputs_dir)}')

    # Write the file out again
    with open(config_filepath, 'w') as file:
        file.write(filedata)

    print("Created config file:", config_filepath)


args = parser.parse_args()

if args.mma_token == "":
    print("Please give an authentication token for the Melbourne Metagenomic Archive either through a command line argument or the MMA_TOKEN environment variable.")
    sys.exit(1)


######################################################
#### Connect to Mediaflux
######################################################

# Read config file
mf_config = dict(user=None, password=None, token=None)

mf_config_path = Path(args.mf_config).expanduser()
if mf_config_path.exists():
    with open( mf_config_path, 'r' ) as f:
        for line in f:
            components = line.split("=")
            if len(components) == 2:
                mf_config[components[0]] = components[1].strip()
else:
    print("Cannot find mediaflux config file:", mf_config_path)

# Read command line arguments
if len( args.mf_token ) > 0:
    mf_config['token'] = args.mf_token

if len( args.mf_user ) > 0:
    mf_config['user'] = args.mf_user

# Prompt for values if necessary
if not mf_config['token']:
    if not mf_config['user']:
        mf_config['user'] = input("Enter your Mediaflux user: ") 

    if not mf_config['password']:
        import getpass
        mf_config['password'] = getpass.getpass("Enter your Mediaflux password: ")


######################################################
#### Get info for study from website API
#### https://mma.robturnbull.com/mma/api/study/ # TODO: update to new website
######################################################

study_accession = args.study_accession
study = requests.get(f"https://mma.robturnbull.com/mma/api/study/{study_accession}/" , headers={"Authorization": f"Token {args.mma_token}" }).json() # TODO: update to new website
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
config_filepath = inputs_dir/ f"{study_accession}_{args.batch}.config"

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
        
        # Check if the run has a pair of read files. Otherwise metaGenPipe will not be able to process it at this stage
        files = run['files']
        if len(files) == 1:
            continue
        elif len(files) > 2:
            # If there are more than two files, then only include files with _1 or _2 in the filenames
            files = [file for file in files if re.search(r"_[1,2]\.", Path(file['mf_path_str']).name)]
            if len(files) != 2:
                continue

        if args.download:
            for file in files:
                asset_id = "path=/projects/proj-6300_metagenomics_repository_verbruggenmdap-1128.4.294/%s" % file['mf_path_str'] 
                local_path = inputs_dir/Path(file['mf_path_str']).name
                print(f"Downloading {asset_id} to {local_path}")
                try:
                    with mfclient.MFConnection(
                        host='mediaflux.researchsoftware.unimelb.edu.au', 
                        port=443, 
                        transport='https', 
                        domain='unimelb',
                        user=mf_config['user'], 
                        password=mf_config['password'],
                        token=mf_config['token'],
                    ) as cxn:
                        # print(type(get_asset_metadata(cxn, asset_id)))
                        # print('token', cxn.token)
                        get_asset_content( cxn, asset_id, local_path)
                except mfclient.ExHttpResponse:
                    print("Cannot access Mediaflux. Please check your Mediaflux settings.")
                    print("NB. If you use a Mediaflux token, it needs to have at least a 'participant-a' project role and the IP address you are using needs to be allowed.")
                    sys.exit(1)

        
        filenames = [str((inputs_dir/Path(file['mf_path_str']).name).resolve()) for file in files]
        filenames_str = "\t".join(filenames)
        samples_file.write(f"{run['accession']}\t{filenames_str}\n")


print("Created input samples text file with location of run files:", samples_filepath)


######################################################
#### Write the JSON Settings File
######################################################
settings = get_settings(args.input_json, samples_filepath, scripts_dir)
with open(settings_filepath, "w") as settings_file:
    json.dump(settings, settings_file, indent=2, sort_keys=False)
print("Created input JSON settings file:", settings_filepath)

######################################################
#### Write the JSON Options File
######################################################
options = get_options( args.options_json, outputs_dir)
with open(options_filepath, "w") as options_file:
    json.dump(options, options_file, indent=4, sort_keys=False)
print("Created options JSON file:", options_filepath)

######################################################
#### Write the config File
######################################################
write_config(args.config, outputs_dir, config_filepath)

print("Outputs of metaGenPipe will be sent to:", outputs_dir)
print()
print("You can use this command from the root directory of metaGenPipe to run this job:")
print("java -DLOG_MODE=pretty -Dconfig.file=%s -jar cromwell-52.jar run metaGenPipe.wdl -i %s -o %s" % (
    check_path_for_file(config_filepath),
    check_path_for_file(settings_filepath),
    check_path_for_file(options_filepath),
))
