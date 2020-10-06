import json
import pandas as pd
import os
import urllib.request
from bs4 import BeautifulSoup
import argparse
import sys
import logging


parser = argparse.ArgumentParser(description='A script to query the European Nucleotide Archive (ENA) website to create a CSV file with information for each read sequence file.')
parser.add_argument("csv", help="The input CSV file. It requires a column for the ENA_PROJECT with the project accesion numbers. \
    It also expects columns for METAGENOMICS_ANALYSES and METAGENOMICS_SAMPLES if the ENA_PROJECT is missing.")
parser.add_argument("cache", help="The path to a directory to cache the downloads of the ENA report files.")
parser.add_argument("-o","--output", help="The output CSV file for the individual read files. Each read file is a separate row in the table.")
args = parser.parse_args()

def human_readable_file_size(size):
    """
    Returns a human readable file size string for a size in bytes. 
    
    Adapted from https://stackoverflow.com/a/25613067)
    """

    from math import log2    
    _suffixes = ['bytes', 'KB', 'MB', 'GB', 'TB', 'PB']

    # determine binary order in steps of size 10 
    # (coerce to int, // still returns a float)
    order = int(log2(size) / 10) if size else 0
    # format file size
    # (.4g results in rounded numbers for exact matches and max 3 decimals, 
    # should never resort to exponent values)
    return '{:.4g} {}'.format(size / (1 << (order * 10)), _suffixes[order])


def cached_download( url, local_path ):
    """
    Downloads a file if a local file does not already exist.

    Args:
        url: The url of the file to download.
        local_path: The local path of where the file should be. If this file isn't there or the file size is zero then this function downloads it to this location.

    Raises:
        Exception: Raises an exception if it cannot download the file.

    """
    if not os.path.isfile( local_path ) or os.path.getsize(local_path) == 0:
        try:
            print(f"Downloading {url} to {local_path}")
            urllib.request.urlretrieve(url, local_path)
        except:
            raise Exception(f"Error downloading {url}")

    if not os.path.isfile( local_path ):
        raise Exception(f"Error reading {local_path}")

def download_ena_report( accession, result_type, cache_dir ):
    """
    Downloads a TSV file report from the European Nucleotide Archive (ENA) website if it is not already cached.

    If the file already is cached then it is not downloaded again.
    Args:
        accession:   The accession id for the query. It can be a project accession id or a sample accession id.
        result_type: The type of report we are seeking (e.g. 'analysis' or 'read_run').
        cache_dir:   The path to the directory where the downloaded files are stored.
    
    Returns:
        The local path to the ENA file report.

    Raises:
        Exception: Raises an exception if it cannot download the file.
    """    
    path = f"{cache_dir}/{accession}.{result_type}.tsv"
    tsv_url = f"https://www.ebi.ac.uk/ena/data/warehouse/filereport?accession={accession}&result={result_type}"
    cached_download( tsv_url, path )
    return path

def ena_report_df( accession, result_type, cache_dir ):
    """ Same as 'download_ena_report' but this function opens the TSV file as a Pandas dataframe. """

    path = download_ena_report( accession, result_type, cache_dir )
    return pd.read_csv( path, sep='\t' )



df = pd.read_csv(args.csv, encoding="ISO-8859-1")

data = []

projects_count = len(df.index)
for index,row in df.iterrows():
    project_accession = row['ENA_PROJECT']
    print(f"Project {index} of {projects_count}: {project_accession}")

    # Download 'analysis' data for project to get the sample accession ids
    print(project_accession, "analysis" )
    try:
        analysis_df = ena_report_df( project_accession, "analysis", args.cache )
    except:
        # Sometimes the ENA_PROJECT element in the CSV files for this project for some reason.
        # If this is the case, we can try the METAGENOMICS_SAMPLES element instead.
        # However, since the first column (i.e. ENA_PROJECT) is missing, we get the 'METAGENOMICS_SAMPLES' value from the 'METAGENOMICS_ANALYSES' column.
        project_accession = row['METAGENOMICS_ANALYSES']
        try:
            analysis_df = ena_report_df( project_accession, "analysis", args.cache )
        except:
            logging.warning(f"WARNING: Cannot read row: {row}")
            continue


    sample_accessions = analysis_df['sample_accession'].unique()

    # Occasionally the 'analysls' table for the ENA project accession number is empty. 
    # Usually when this happens, the project accession ID can be used as the 'sample' accession id to download the 'read_run' table
    if len(sample_accessions) == 0 or str(sample_accessions) == "[nan]":
        sample_accessions = [project_accession]

    print('sample_accessions:', sample_accessions)
    for sample_accession in sample_accessions:
        read_run_df = ena_report_df( sample_accession, "read_run", args.cache )
        print(read_run_df)
        #assert len(read_run_df.index) > 0
        if len(read_run_df.index) == 0:
            logging.warning(f"WARNING: No reads found for {project_accession}")

        for _, sample_row in read_run_df.iterrows():
            if pd.isna(sample_row)['fastq_ftp']:
                logging.warning(f"WARNING: No FASTQ files found for {project_accession}")
                continue

            fastq_bytes_list = str(sample_row['fastq_bytes']).split(";")
            fastq_md5_list = str(sample_row['fastq_md5']).split(";")
            fastq_ftp_list = str(sample_row['fastq_ftp']).split(";")
            fastq_aspera_list = str(sample_row['fastq_aspera']).split(";")
            #fastq_galaxy_list = str(sample_row['fastq_galaxy']).split(";")

            for file_index, (fastq_bytes, fastq_md5, fastq_ftp, fastq_aspera) in enumerate(zip(fastq_bytes_list, fastq_md5_list, fastq_ftp_list, fastq_aspera_list)):
                #Cast to float first in case there are decimal points in the string for bytes. See https://stackoverflow.com/a/8948303
                fastq_bytes = int(float(fastq_bytes))
                data.append( [project_accession, sample_row['sample_accession'], file_index, fastq_bytes, human_readable_file_size(fastq_bytes), fastq_md5, fastq_ftp, fastq_aspera] )

ftp_df = pd.DataFrame( data, columns=["project_accession", "sample_accession", "file_index", "fastq_bytes", "fastq_bytes_human_readable", "fastq_md5", "fastq_ftp", "fastq_aspera"])
print(ftp_df)

output_path = args.output

if not output_path:
    csv_filename, _ = os.path.splitext(args.csv)
    output_path = csv_filename + "-FASTQ.csv"

ftp_df.to_csv( output_path )
total_bytes = ftp_df['fastq_bytes'].sum()
print(human_readable_file_size(total_bytes))