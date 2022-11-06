############### download metagenepipe databases ######################
# -*- coding: utf-8 -*-
""" download_databases.py

Description:
	Download hmmer, blast and swissprot databases

Requirements:
        Args:

packages:
        os
        sys
        pathlib

usage:
	python download_databases.py --blast mito --hmmer_kegg prokaryote --swissprot y --singularity y/n

Todo:

Author:
Bobbie Shaban

Date:
27/04/2022
"""

import sys
import os
import argparse
from pathlib import Path
import urllib.request as urllib
import gzip
import shutil
import ftplib
import glob
from datetime import datetime



def main():
    """
    Main(): Parses command line parameters and calls
            download functions function

    Parameters
    ____________
    
    None

    Returns
    ____________

    downloads blast, koalafam or swissprot database
    """

    parser = argparse.ArgumentParser()
    parser.add_argument('-b', '--blast', type=str,
                        help='Download blast nt database: options: nr, nt, pdbaa')
    parser.add_argument('-k', '--hmmer_kegg', type=str,
                        help='Download KoalaFam hmmer profiles')
    parser.add_argument('-s', '--sprott', type=str,
                        help='Download Swissprot db and convert to diamond db')
    parser.add_argument('-c', '--cromwell', type=str,
                        help='Download cromwell jar')
    parser.add_argument('-i', '--singularity', type=str,
                        help='Download Singularity container')
    args = parser.parse_args()


    #Download singularity container
    ###############################
    try:
       if args.singularity:
           print("Ensure singularity is installed and in your path")
           os.system("singularity pull --arch amd64 library://mariadelmarq/metagenepipe/metagenepipe:v2")
           args.singularity = glob.glob('*.sif')[0]
           print(args.singularity) 
    except Exception as err:
       print(err)

    #Download cromwell
    ###############################
    try:
       if args.cromwell:
           print("Download cromwell")
           os.system("LOCATION=$(curl -s https://api.github.com/repos/broadinstitute/cromwell/releases/latest | grep \"browser_download_url\" | grep \"cromwell-\" | awk '{ print $2 }' | sed 's/,$//' | sed 's/\"//g' ) ; curl -L -o cromwell-latest.jar $LOCATION")
    except Exception as err:
       print(err)
    

    ### download blast database
    ###########################
    try:
        if args.blast:
            download_blast(args.blast, args.singularity)
    except Exception as err:
         print(err)

    ### download koala_fam
    ######################
    try:
        if args.hmmer_kegg:
            download_koalafam(args.singularity, args.hmmer_kegg)

    except Exception as err:
         print(err)


    ### download swissprot database
    ###############################
    try:
        if args.sprott:
            download_swissprot(args.singularity)
    except Exception as err:
         print(err)

    """
    download_blast(): Downloads blast database

    Parameters
    ____________

    singularity: location of singularity file
    blast: name of blast database to download database to download

    Actions
    ___________
    downloads blast database
    """

def download_blast(blast, singularity):
    print("downloading blast database")
    FTP_HOST = "ftp.ncbi.nlm.nih.gov"
    FTP_USER = "anonymous"

    ftp = ftplib.FTP(FTP_HOST, FTP_USER)
    ftp.encoding = "utf-8"
    ftp.cwd('blast/db')
    print("{:20} {}".format("File Name", "File Size"))
    for file_name in ftp.nlst():
        if file_name.startswith(blast) and file_name.endswith('.gz'):
            print("https://" + FTP_HOST + "/blast/db/" + file_name)
            download_file("https://" + FTP_HOST + "/blast/db/" + file_name)

            ## Create directory
            Path("blast").mkdir(parents=True, exist_ok=True)
            ## move file to blast directory
            shutil.move(file_name, "blast/"+file_name)
            
            ## unzip file
            os.system("tar -xvf ./blast/* -C ./blast/")

    """
    download_koalafam(): downloads koalafam profiles and
                         merges according to prokaryotes/
                         eukaryotes

    Parameters
    ____________

    singularity: Location of singularity container
    karyote: Either eukaryote or prokaryote

    Returns
    ____________

    merged hmmer profiles in kegg directory
    """
def download_koalafam(singularity, karyote):
    print("download KoalaFam hmmer profiles")
    print("8 Gb of Storage required")
    koalafam_download = "https://www.genome.jp/ftp/db/kofam/profiles.tar.gz"

    pwd = os.getcwd()
    existing_file = os.path.exists(pwd + "/profiles.tar.gz")
  
    ## if file exsts switch
    if existing_file:
        print("File already exists")
        zipped_koalafam = "profiles.tar.gz"
    else:
        zipped_koalafam = download_file(koalafam_download)

    ## unzipfile
    zip_command = "tar -xvf " + zipped_koalafam
    os.system(zip_command)

    ## remove zipped file
    print("Removing zipped file")
    os.remove("profiles.tar.gz")

    ## sed start of hal file
    print("update hal file to correct location of hmmer profiles")
    os.system("sed 's/K/profiles\/K/' " + "profiles/" + karyote + ".hal > profiles/prok.hal")

    ##cat hmmer files together
    ## Create directory
    Path("kegg").mkdir(parents=True, exist_ok=True)
    print("Merging " + str(karyote) + ".hal hmmer profiles")
    os.system("xargs cat < profiles/prok.hal > kegg/kegg_all.hmm") 

    """
    download_swissprot(): downloads swissprot database and
                          creates diamond database

    Parameters
    ____________

    singularity: location of singularity image

    Returns
    ____________

    Swissprot database in diamond format
    """
def download_swissprot(singularity):
    print("downloading swissprot database")
    swissprot_location = "ftp://ftp.ebi.ac.uk/pub/databases/uniprot/knowledgebase/uniprot_sprot.fasta.gz"
    ## download file
    zipped_swiss = download_file(swissprot_location)
    ## unzipfile
    with gzip.open(zipped_swiss, 'rb') as f_in:
        with open("uniprot_sprot.fasta", 'wb') as f_out:
            shutil.copyfileobj(f_in, f_out)

    ## remove zipped file
    print("Removing zipped file")
    os.remove(zipped_swiss)

    ## use singularity to create diamond database
    singularity_string = "singularity run -B $PWD:$PWD " + singularity + " diamond makedb --in uniprot_sprot.fasta -d swissprot"
    os.system(singularity_string)
   
    ## remove fasta file
    os.remove("uniprot_sprot.fasta")

    ## Create directory
    Path("kegg").mkdir(parents=True, exist_ok=True)
    ## move file to kegg directory
    shutil.move("swissprot.dmnd", "kegg/swissprot.dmnd")

    """
    download_file(): Downloads file and provides status bar

    Parameters
    ____________

    url: url for file to download

    Returns
    ____________

    Downloaded file
    """
def download_file(url):
    file_name = url.split('/')[-1]
    u = urllib.urlopen(url)
    f = open(file_name, 'wb')
    meta = u.info()

    ## Koalafam doesn't have the file size in the file header
    ## Figure out a better way to do this
    if u.headers['Content-length']:
        file_size = int(u.headers['Content-length'])
        print("Downloading: %s Bytes: %s" % (file_name, file_size))
    else:
        file_size = int("1395864371")

    file_size_dl = 0
    block_sz = 8192
    while True:
        buffer = u.read(block_sz)
        if not buffer:
            break

        file_size_dl += len(buffer)
        f.write(buffer)
        status = r"%10d  [%3.2f%%]" % (file_size_dl, file_size_dl * 100. / file_size)
        status = status + chr(8)*(len(status)+1)
        print(status)
    f.close()
    return(file_name)


# some utility functions that we gonna need
def get_size_format(n, suffix="B"):
    # converts bytes to scaled format (e.g KB, MB, etc.)
    for unit in ["", "K", "M", "G", "T", "P"]:
        if n < 1024:
            return f"{n:.2f}{unit}{suffix}"
        n /= 1024

def get_datetime_format(date_time):
    # convert to datetime object
    date_time = datetime.strptime(date_time, "%Y%m%d%H%M%S")
    # convert to human readable date time string
    return date_time.strftime("%Y/%m/%d %H:%M:%S")

###### Main call ##########
if __name__ == "__main__":
     main()

