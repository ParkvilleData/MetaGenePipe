#!/usr/bin/env python3

import pandas as pd
import argparse
from pathlib import Path
import hashlib
import os
import numpy as np
import multiprocessing

def str2bool(v):
    """
    Converts a string to a boolean value for parsing in argparse.

    From https://stackoverflow.com/a/43357954
    """
    if isinstance(v, bool):
       return v
    if v.lower() in ('yes', 'true', 't', 'y', '1'):
        return True
    elif v.lower() in ('no', 'false', 'f', 'n', '0'):
        return False
    else:
        raise argparse.ArgumentTypeError('Boolean value expected.')


parser = argparse.ArgumentParser(description="Downloads in parallel the read files in a CSV file using Aspear Connect.")
parser.add_argument("csv", help="The CSV file for the read files (created through query_ena.py). \
    It expects fields named: project_accession, sample_accession, file_index, fastq_bytes, fastq_bytes_human_readable, and fastq_aspera.")
parser.add_argument("key", help="The SSH key to use with Aspera Connect.")
parser.add_argument("--validate", type=str2bool, nargs='?',
                        const=True, default=True,
                        help="If true, then the script validates the MD5 checksum of the file if it is already downloaded. If there is a mismatch then the file is downloaded again.")

args = parser.parse_args()




def process_row(row):
    aspera = Path(row['fastq_aspera'])
    print(f"Processing: {row['project_accession']}, {row['sample_accession']}, {row['file_index']}, {aspera}")
    
    local_dir = Path(f"{row['project_accession']}/{row['sample_accession']}/{row['file_index']}")
    local_dir.mkdir(parents=True, exist_ok=True)

    local_path = local_dir / aspera.name

    # Check to see if the file need to be downloaded
    if local_path.is_file():
        print(f"{local_path} already downloaded.")

        if args.validate_checksum:
            md5 = hashlib.md5(local_path).hexdigest()
            if md5 == row['fastq_md5']:
                return
            else:
                print("MD5 checksum is incorrect. Downloading again.")
        else:
            return
    
    print(f"Downloading {aspera} ({row['fastq_bytes_human_readable']})")
    cmd = f"ascp -QT -l 1000m -P33001 -i {args.key} era-fasp@{aspera} {local_path}"
    print(cmd)
    os.system(cmd)
    

def process_dataframe(df):
    for index, row in df.iterrows():
        process_row(row)

df = pd.read_csv(args.csv)
n_cores = multiprocessing.cpu_count()

# Arrange dataframe into even partitions
df = df.sort_values(by=['fastq_bytes']).reset_index(drop=True)
df['partition'] = df.index % n_cores
df = df.sort_values(by=['partition']).reset_index(drop=True)
df_split = np.array_split(df, n_cores)

# Process on multiple processors
pool = multiprocessing.Pool(n_cores)
pool.map(process_dataframe, df_split) # This is a hack to just run the process_dataframe in parallel on all the partitions.
