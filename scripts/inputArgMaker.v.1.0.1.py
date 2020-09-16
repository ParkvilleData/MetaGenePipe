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
"""

import sys
import glob
import os
import re
import pprint
import textwrap
import argparse
from collections import OrderedDict

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('-o', '--outputfile', type=str, required=True,
                        help='You must add a name for the output file')
    parser.add_argument('-f', '--format', type=str,
                        help='What format are your files?')
    parser.add_argument('-d', '--directory', type=str, required=True,
                        help='You need to add a path to the sample files')
    parser.add_argument('-p', '--pairedend', required=True, type=str, help='Are your samples paired end?')
    parser.add_argument('-ph', '--phred', required=True, type=str, help='Phred score type i.e. 33?')
    parser.add_argument('-pl', '--pl', required=True, type=str, help='PL flag?')
    parser.add_argument('-debug', action="store_true", help='Do you want to turn on Debug Mode?')
    args = parser.parse_args()

    #if debug is set to true run 
    if args.debug:
        printArgvs(args, sys)

    #return file list and size from read files function
    fileListRaw = readFiles_glob(args.directory)

    if args.debug:
        print("Raw File List")
        printDictionary(fileListRaw)

    #if paired end send file list off for PE processing
    # better way of doing this?
    if args.pairedend in ('True', 'true', 'TRUE', 'Yes', 'yes', 'y', 'Y', 't', 'T'):
       print("You are running paired end version\n")
       fileList = paired_end_files(fileListRaw, args)
       pairedEndKeys = []
       pairedEndKeys = return_sample_names(fileListRaw, True)
       input_file = open(args.outputfile, 'w')
       for keys in pairedEndKeys:
           input_file.write(keys + '\t' + fileList[keys]['forward'] + '\t' + fileList[keys]['reverse'] + '\t' + fileList[keys]['flag'] + '\t' + args.phred + '\t' + args.pl + '\t' +  fileList[keys]['size'] + '\n')
       input_file.close()
    else:
       print("You are running non-paired end version\n")
       fileList=fileListRaw
       input_file = open(args.outputfile, 'w')
       for files in fileList:
           sample = str(files[1])
           size = str(files[0])
           baseName = return_sample_name(sample)
           input_file.write(baseName + '\t' + sample + '\t' + "SE" + '\t' + args.phred + '\t' + args.pl + '\t' + size + '\n')
       input_file.close()

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
    uniqueSampleNames = []
    uniqueSampleNames = return_sample_names(fileList, True)

    #go through fileList and if match append to dictionary
    sampleDictionary = {}
    for uniqueSamples in uniqueSampleNames:
        #intiate keys
         sampleDictionary[uniqueSamples] = {}
         for fileLine in fileList:
             if uniqueSamples in fileLine[1]:
                if 'r1' in fileLine[1]:
                    sampleDictionary[uniqueSamples]['forward'] = fileLine[1]
                    sampleDictionary[uniqueSamples]['size'] = str(fileLine[0])
                    sampleDictionary[uniqueSamples]['flag'] = "PE"
                elif 'r2' in fileLine[1]:
                    sampleDictionary[uniqueSamples]['reverse'] = fileLine[1]
                    sampleDictionary[uniqueSamples]['size'] = str(fileLine[0])
                    sampleDictionary[uniqueSamples]['flag'] = "PE"

    #sort by file size
    result = OrderedDict(sorted(sampleDictionary.items(), key=lambda i: i[1]['size']))    
    return result

def return_sample_names(fileList, uniq):
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

def get_file_size(file_path):
    """ get_file_size

    Returns file size

    Args:
        param1 (string): Path of the sample file

    Returns:
        int: returns the size of the file in bytes

    """
    size = os.path.getsize(file_path)
    return size

def readFiles_glob(directory):
    """ readFiles_glob

    Returns list of files

    Args:
        param1 (string): Path of the directory which contains the fasta files

    Returns:
        list: returns list of files

    """
    if os.path.isdir(directory):
        pairs = []
        for name in sorted(glob.glob(os.path.join(directory + '*.gz'))):
            file_size = get_file_size(name)
            pairs.append((file_size, name))

        #sort files by size then reverse - probably better way to do this
        pairs.sort(key=lambda s: s[0])
        pairs.reverse()
        return pairs
    else:
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

    print(len(dictionary))

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

def usage():
    print textwrap.dedent("""Description:
        This script will take in a number of parameters and will create an
        input file that can be used for the HPGAP WDL workflow

        Example:

        $  python ./scripts/inputMaker.py -f fasta -d /data/cephfs/punim1165/bshaban/hpgap_dev/fastqFiles/ -o input.txt -p true

        Help:
            -h|--help:          Prints help message
            -o|--outputfile:    Name of the output (input) file
            -f|--format:        Format of sample files e.g. fasta
            -p|--pairedend:     Paired end samples e.g. true or false
            -d|--directory:     Directory of sample files
            -b|--debug:         Runs debug functions""")

###### Main call ##########
if __name__ == "__main__":
     main()
