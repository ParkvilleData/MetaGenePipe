# -*- coding: utf-8 -*-
""" inputMaker.py

05/03/2020 - Bobbie Shaban, Noel Faux

Description:
    This script will take in a number of parameters and will create an
    input file that can be used for the HPGAP WDL workflow

Example:

        $  python ./scripts/inputMaker.py -f fasta -d /data/cephfs/punim1165/bshaban/hpgap_dev/fastqFiles/ -o input.txt -p true -pl PL -ph 33

usage: inputArgMaker.py [-h] -o OUTPUTFILE [-f FORMAT] -d DIRECTORY -p
                        PAIREDEND -ph PHRED -pl PL [-debug]

Todo:
    * You have to also use ``sphinx.ext.todo`` extension
    * Throw error if no files in directory or if they are not gzipped or fastq
    * check size order in PE mode
"""

import sys
import glob
import os
import re
import pprint
import textwrap
import argparse
import gzip
from itertools import islice
from collections import OrderedDict

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('-o', '--outputfile', type=str, required=True,
                        help='You must add a name for the output file')
    parser.add_argument('-f', '--format', type=str,
                        help='What format are your files?')
    parser.add_argument('-d', '--directory', type=str, required=True,
                        help='You need to add a path to the sample files')
    parser.add_argument('-p', '--pairedend', required=False, type=str, help='Are your samples paired end? YES/NO')
    parser.add_argument('-ph', '--phred', required=False, type=str, help='Phred score type i.e. 33?')
    parser.add_argument('-ml', '--minlength', required=True, type=str, help='Minimum length of reads after trimming')
    parser.add_argument('-pl', '--platform', required=True, type=str, help='PL flag?')
    parser.add_argument('-lb', '--library', required=True, type=str, help='BAM Header LB')
    parser.add_argument('-sm', '--sample', required=True, type=str, help='BAM Header SM')
    parser.add_argument('--debug', action="store_true", help='Do you want to turn on Debug Mode?')
    args = parser.parse_args()

    #if debug is set to true run 
    if args.debug:
        printArgvs(args, sys)

    #return file list and size from read files function
    fileListRaw = readFiles_glob(args.directory)

    if args.debug:
        print("Raw File List")
        print(fileListRaw)

    input_file = open(args.outputfile, 'w')
    #if paired end send file list off for PE processing
    # better way of doing this?
    # replace with a regular expression to pattern match YES
    if args.pairedend in ('True', 'true', 'TRUE', 'Yes', 'yes', 'y', 'Y', 't', 'T'):
       print("You are running paired end version\n")
       fileList = paired_end_files(fileListRaw, args)
       pairedEndKeys = return_list_base_names(fileListRaw, True)
       for keys in pairedEndKeys:
           input_file.write(keys + "\t" +  fileList[keys]['flag'] + '\t' + args.minlength + '\t' + args.phred + '\t' + args.platform + '\t' +  fileList[keys]['size'] + '\t' + args.library + '\t' + fileList[keys]['id'] + '\t' + args.sample + '\t' + fileList[keys]['id'] + '\t' + fileList[keys]['forward'] + '\t' + fileList[keys]['reverse'] + '\n')

    else:
       fileList=fileListRaw
       for files in fileList:
           sample, size, identity = str(files[1]), str(files[0]), str(files[2])
           baseName = return_sample_name(sample)
           input_file.write(baseName + "\t" + "SE" + '\t' + args.minlength + '\t' + args.phred + '\t' + args.platform + '\t' +  size + '\t' + args.library + '\t' + identity + '\t' + args.sample + '\t' + identity + '\t' + sample  + '\n')
    input_file.close()
    print("Creation of input file complete!")

    if args.debug:
        printDictionary(fileList)


######################### Functions #################################

def paired_end_files(fileList, args):
    """ paired_end_files
    
    Is executed if the paired end parameter is set to true
    Reads in folder, takes basename of files as sample name 

    Args:
        fileList (tuple): The first first parameter: A list of files
        debug: Do you want to debug or not?

    Returns:
        Dictionary: Contains SampleName, file size and forwrd and reverse reads

    """

    #remove paired ending of sample name and remove non-unique
    uniqueSampleNames = return_list_base_names(fileList, True)

    #go through fileList and if match append to dictionary
    sampleDictionary = {}
    for uniqueSamples in uniqueSampleNames:
        #intiate keys
         sampleDictionary[uniqueSamples] = {}
         pairedEndExtArrayR1 = ['_r1', '_R1']
         pairedEndExtArrayR2 = ['_r2', '_R2']
         for fileLine in fileList:
             if uniqueSamples in fileLine[1]:
                if any(r in fileLine[1] for r in pairedEndExtArrayR1):
                    sampleDictionary[uniqueSamples]['forward'], sampleDictionary[uniqueSamples]['size'], sampleDictionary[uniqueSamples]['flag'], sampleDictionary[uniqueSamples]['id'] = fileLine[1], str(fileLine[0]), "PE", str(fileLine[2])
                elif any(r in fileLine[1] for r in pairedEndExtArrayR2):
                    sampleDictionary[uniqueSamples]['reverse'] = fileLine[1]

    #sort by file size
    result = OrderedDict(sorted(sampleDictionary.items(), key=lambda i: int(i[1]['size'])))
    return result

def return_list_base_names(fileList, uniq):
    """ return_list_of_base_names

    Returns a list of base names from raw list of files

    Args:
        fileList: raw list of files and paths
        uniq: If you want the files to be unique

    Returns:
        string: returns list of basenames without _r1 or _r2

    """

    sampleNames = []
    for lines in fileList:
        tempString = return_sample_name(str(lines[1]))
        sampleNames.append(tempString)

    samples = []
    for s in sampleNames:
        samples.append(s.split('_')[0]) 

    if uniq:
        result =  list(dict.fromkeys(samples))
    else:
        result = uniqueSampleNames

    return result

def return_sample_name(path):
    """ return_sample_name

    Returns sample names from a path

    Args:
        param1 (string): Path of the sample file

    Returns:
        string: returns the sample name? with or without _r1 or _r2

    """

    basename = os.path.basename(path)
    samplename = basename.split('.')
    return samplename[0]

def readFiles_glob(directory):
    """ readFiles_glob

    Returns list of files

    Args:
        param1 (string): Path of the directory which contains the fasta files

    Returns:
        list: returns list of files

    """
    try:
        try:
            os.path.isdir(directory)
        except:
            print (directory + " Doesn't exist")

        os.path.isdir(directory)
        pairs = []
        types = ('*.gz', '*.fastq', '*.fq')
        for fs in types:
            for name in sorted(glob.glob(os.path.join(directory + fs ))):
                print(name)
                file_size = os.path.getsize(name)
                #get id from first line in forward read
                if 'gz' in name:
                    with gzip.open(name, 'rb') as f:
                        for l in islice(f, 0, None):
                            try:
                                first_line = re.search("@(.+?)C001", "l {}".format(l)).group(1)
                                f.close()
                            except AttributeError:
                                print("not found\n")
                            break
                elif 'fastq' in name:
                    with open(name, 'r') as inf:
                        fline = inf.readline()
                        first_line = re.search("@(.+?)C001", "fline {}".format(fline)).group(1)
                elif 'fq' in name:
                    first_line = "first_line"
                pairs.append((file_size, name, first_line))

        #sort files by size then reverse - probably better way to do this
        pairs.sort(key=lambda s: s[0], reverse=True)
        return pairs
    except:
        print(directory + ' does not exist\n')

def printDictionary(dictionary):
    """ print Dictionary

    Prints contents of dictionary for debug purposes

    Args:
        param1 (Dictionary): Dictionary of questionable content

    Returns:
        NA: print out dictionary contents

    """
    
    print("\nDictionary contents below")
    pp = pprint.PrettyPrinter(indent=4)
    pp.pprint(dictionary)

def printArgvs(args, sys):
    """ printArgvs

    Prints out arguments from command line i.e. get opts

    Args:
        args (list): arguments from command line
        sys (object?): options passed in from command line

    Returns:
        str: Prints the number of arguments and the arguments themselves

    """
    # ... for testing of get options
    print("\nDebugging info START\n")
    print('Number of arguments:', len(sys.argv), 'arguments.')
    print('Argument List:', str(sys.argv))
    print('Opts string:', str(args))
    print("\nDebugging info END\n")


###### Main call ##########
if __name__ == "__main__":
     main()

