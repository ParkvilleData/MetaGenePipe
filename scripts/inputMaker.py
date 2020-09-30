# -*- coding: utf-8 -*-
""" inputMaker.py

05/03/2020 - Bobbie Shaban, Noel Faux

Description:
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
    -b|--debug:         Runs debug functions

Todo:
    * Get paired end option working
    * Add metadata from the data.yml
    * add helpful help message i.e usage
    * You have to also use ``sphinx.ext.todo`` extension
    * Convert to use argparse instead of getopts

"""

import getopt, sys
import glob
import os
import re
import pprint
import textwrap

def main():
    try:
        opts, args = getopt.getopt(sys.argv[1:], "ho:f:p:d:b:v", 
                                  ["help", "outputfile=", "format=", "pairedend=", "directory=", "debug="])
    except getopt.GetoptError as err:
        # print help information and exit:
	print("******************************************************************************************")
        usage()
	print("******************************************************************************************\n")
        print(err) # will print something like "option -a not recognized"
        print("\n")
        sys.exit(2)

    #sets default parameters
    debug = True
    outputfile = False
    inputFormat = False
    pairedend = False
    directory = False
    optsArray = [outputfile, inputFormat, pairedend, directory]

    if len(opts) !=0:
        for o, a in opts:
            if o == "-v":
                verbose = True
            elif o in ("-h", "--help"):
                usage()
                sys.exit()
            elif o in ("-o", "--outputfile"):
                outputfile = a
            elif o in ("-f", "--format"):
                inputFormat = a
            elif o in ("-p", "--pairedend"):
                pairedend = a
            elif o in ("-d", "--directory"):
                directory = a
            elif o in ("-b", "--debug"):
                debug = a
            else:
                assert False, "unhandled option"
        

	#if debug is set to true run verbose
        if debug:
            commandLine = sys.argv
            printArgvs(commandLine, opts)

        #return file list and size from read files function
        fileListRaw = readFiles_glob(directory)

        #if paired end send file list off for PE processing
        if pairedend:
            fileList = paired_end_files(fileListRaw, debug)
        else:
            fileList=convert(fileListRaw)

        if debug:
            printDictionary(fileList)

        #open file for printing
        input_file = open(outputfile, 'w')

        #print files to file in order of large to small
        for files in fileList:
            writing_string = str(files[1])
            sampleName = return_sample_name(writing_string)
            input_file.write(sampleName + '\t' + writing_string + '\n')
        input_file.close()
    else:
        usage()


#not used
def isEmpty(variable, option):
    try:
        if variable != None:
            return variable
        else:
            print(option + "Is empty")
            usage()
            sys.exit(2)

    except ValueError:
        pass


def Convert(lst): 
    res_dct = {lst[i]: lst[i + 1] for i in range(0, len(lst), 2)} 
    return res_dct 

def paired_end_files(fileList, debug):
    """ paired_end_files
    
    Is executed if the paired end parameter is set to true
    Reads in folder, takes basename of files as sample name 

    Args:
        fileList (tuple): The first first parameter: A list of files
        debug: Do you want to debug or not?

    Returns:
        Dictionary: Contains SampleName, file size and forwrd and reverse reads

    """

    sampleNameList = []
    for lines in fileList:
        tempString = return_sample_name(str(lines[1]))
        sampleNameList.append(tempString)

    #remove paired ending of sample name and remove non-unique
    uniqueSampleNames = []
    for sampleNames in sampleNameList:
        uniqueSampleNames.append(sampleNames.split('_')[0])
    #creates a dictionary adding sample names
    #creates list with unique sample names 
    uniqueSampleNames = list(dict.fromkeys(uniqueSampleNames))
    print("The number of unique sample names are " + str(len(uniqueSampleNames)))

    #go through fileList and if match append to dictionary
    sampleDictionary = {}
    for uniqueSamples in uniqueSampleNames:
        #intiate keys
        #print(uniqueSamples)
        sampleDictionary[uniqueSamples] = {}
        for fileLine in fileList:
            if uniqueSamples in fileLine[1]:
                if 'r1' in fileLine[1]:
                    #print(uniqueSamples + '\t' + fileLine[1] + '\t' + str(fileLine[0]))
                    sampleDictionary[uniqueSamples]['forward'] = fileLine[1]
                    sampleDictionary[uniqueSamples]['size'] = str(fileLine[0])
                elif 'r2' in fileLine[1]:
                    #print(uniqueSamples + '\t' + fileLine[1] + '\t' + str(fileLine[0]))
                    sampleDictionary[uniqueSamples]['reverse'] = fileLine[1]
                    sampleDictionary[uniqueSamples]['size'] = str(fileLine[0])

    if debug:
        printDictionary(sampleDictionary)

    return sampleDictionary

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
    for key in dictionary:
        print (key)
        for value in dictionary[key]:
            print(key,':',dictionary[key])

def printArgvs(commandLine, opts):
    """ printArgvs

    Prints out arguments from command line i.e. get opts

    Args:
        sys.argv (list): arguments from command line
        opts (object?): options passed in from command line

    Returns:
        str: Prints the number of arguments and the arguments themselves

    """
    # ... for testing of get options
    print("\nDebugging info START\n")
    print('Number of arguments:', len(commandLine), 'arguments.')
    print('Argument List:', str(sys.argv))
    print('Opts string:', str(opts))
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
