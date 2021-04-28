import paramiko
import pysftp
from pathlib import Path
from base64 import decodebytes

from .mediaflux import get_asset_content
from .mma import get_upload_success
from .paths import  get_output_dir_name
from .mfclient import mfclient
import xml_parser-v4

parser = argparse.ArgumentParser()
parser.add_argument('xmls', help="The XML files to search for the hits.",  nargs='+')
parser.add_argument('--outfile', help="The name of the output file. Default: OTU.tsv", default="OTU.tsv")

args = parser.parse_args()

def taxon( destination, mma_token, mf_config ):
    """ Downloads the files necessary for the taxonomic classification task, reruns the task and reuploads back to Mediaflux """
    download_taxon()
    rerun_taxon()
    upload_taxon()

def download_taxon(destination, study_accession, mma_token, mf_config):

    upload_success = get_upload_success( mma_token )

    if type(destination) == str:
        destination = Path(destination)
    
    keydata = b"""AAAAB3NzaC1yc2EAAAADAQABAAACAQDATSSk+fPQELMEn8yNcnuuCDOoWxCs/I+USr3zcyUStWn6+loz+FRXBIK+VnxdY8EMk1cJWbjEuaEs5FeeEoZLIekdBWe0I2ra+ES/GEO7oMUYeMqeRe9jnAIIgKervGGvp+S2mb3OSReOKniBEG0AOaQa7DFVUGNgR1FgPinXweQ15D8ts6+u7hlBx5woR9EnjdEY11zVi0QbQ7d0kL3OfZ8grkGL749LrUhY1ZAd5GfWHzK/3DyafNqR+DsfF6w5PjUxWC5m0QeRCJptnfKF1d0tgHb74xL/55IacAbCbCuWjrWNEY+gn39fjWLlOsgrTaJALPIC5mJVz4zWFghDACi5T7Eiw0rvPpfGnyR3e3XdFNsR/2szTco82DXenNck4dk7avomM8KYXBWnRLWWTLEfijA+jMgIpeiOvEioNCsh8imQrTCCJPXIpkxG2CbKkLscqlNVZF++kU+cCbw0HWckzEjIA5yjKg6NGMl95zzR2BVsPm9z1pVe5LJIDvyoNWMQHtlg4t2onTfK0l2VrM5/J/2k0HgFL5ILYtaR6T8GfwljC+Hfk4KQGzqWdyg0GNGmok9n/R57zrLRbm3vlN9tELlcGcYQ57eic8l0Bvjdb6jKqn74JhBNdo1cEqC38EI0Uv5VveBu/AXvaVArCY6FRY3NXYhPFoa3MxTJYw=="""
    key = paramiko.RSAKey(data=decodebytes(keydata))
    cnopts = pysftp.CnOpts()
    cnopts.hostkeys.add('mediaflux.researchsoftware.unimelb.edu.au', 'ssh-rsa', key)

    username = "unimelb:"+mf_config['user']

    with pysftp.Connection('mediaflux.researchsoftware.unimelb.edu.au', username=username, password=mf_config['password'], cnopts=cnopts) as sftp:
        for status in upload_success:
            study_accession = status['study']
            batch = status['batch_index']
            print(study_accession, batch)

            local_path = destination/f"{study_accession}_{batch}"
            local_path = local_path.resolve()

            # Check if folder already exists
            if local_path.is_dir():
                continue
            
            local_path.mkdir(exist_ok=True, parents=True)

            output_dir_name = get_output_dir_name(study_accession, batch)
            remote_path = f'/Volumes/proj-6300_metagenomics_processed_verbruggenmdap-1128.4.295/metaGenPipe_outputs/{output_dir_name}/optimisation'
            print(f"Downloading {remote_path} to {local_path}")
            
            with sftp.cd(remote_path):
                sftp.get_r(".", str(local_path))

                
def rerun_taxon(xml_parser, diamondXML, destination):

    optim_directory = destination/"optimisation"
    singularity = "/data/projects/punim1293/singularity/metaGenPipe.20201119.simg"
    script = f"python3 {xml_parser} --outfile OTU.brite.tsv {diamondXML}"

    os.system(f'sbatch -J "rerunTaxon" -D {destination} -o {destination} -e ${err} -t 5000 -p "adhoc,snowy,physical" -q adhoc --account=punim1293 -n 1 -c 1 --mem=61440 \
            --wrap "module load singularity/3.5.3;
            /usr/bin/time -v --output {optim_directory}/cromwell_xxxxxxxx_OTUtaxon.txt singularity run -B {singularity} /bin/bash ${script}; 
            sh ${head_directory}/scripts/opt_shell.sh ${script} ${job_name} ${optim_directory}


def upload_taxon():

