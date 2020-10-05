#!/usr/bin/env python3

import subprocess
import itertools
import os

assemblers = {
    'megahit': "../MEGAHIT-1.2.9-Linux-x86_64-static/bin/megahit",
    'metaspades': "../SPAdes-3.14.1-Linux/bin/metaspades.py",
    'idba': "idba_ud"
}

def run_benchmark(assembler, reads, threads):

    print("Running " + assembler + ": " + str(reads) + " reads, " + str(threads) + " threads...")

    if assembler != 'idba':
        output_detail = subprocess.run(["/usr/bin/time", "-v", assemblers[assembler], "-1", str(reads) + "K/R1.fastq", "-2", str(reads) + "K/R2.fastq", "-o", str(reads) + "K/" + assembler + "_" + str(threads) + "t", "-t", str(threads)], capture_output=True)
    elif assembler == 'idba':
        output_detail = subprocess.run(["/usr/bin/time", "-v", assemblers[assembler], "-r", str(reads) + "K/merged.fa", "-o", str(reads) + "K/" + assembler + "_" + str(threads) + "t", "--num_threads", str(threads)], capture_output=True)

    time_detail = 'assembler: ' + assembler + ': reads: ' + str(reads) + ': threads: ' + str(threads) + ': ' + output_detail.stderr.decode().split('ommand being ')[-1].replace('\n\t',': ')

    return time_detail

all_params = list(itertools.product([24, 20, 16, 12, 8, 4, 2, 1], [250, 500, 1000, 2000, 5000, 10000], assemblers))

for (threads, reads, assembler) in all_params:
    filename = "./output/" + assembler + "_" + str(reads) + "K_" + str(threads) + "t.txt"
    # if the output file already exists, then continue
    if os.path.isfile(filename):
        print("File " + filename + " already exists, skipping")
    else:
        time_detail = run_benchmark(assembler, reads, threads)
        text_file = open(filename, "w")
        text_file.write(time_detail)
        text_file.close()
