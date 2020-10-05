#!/bin/bash
# Partition for the job:
#SBATCH --job-name="PRJNA219368"
#SBATCH --partition=physical
#SBATCH --account="punim1293"
#SBATCH -p adhoc
#SBATCH -q adhoc
# Requirements
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=24
#SBATCH --time=10-0:0:00
#SBATCH --mem=510000
# Memory is in megabytes per process
# Send yourself an email when the job:
#SBATCH --mail-user=mar.quiroga@unimelb.edu.au
#SBATCH --mail-type=FAIL
#SBATCH --mail-type=BEGIN
#SBATCH --mail-type=END
# check that the script is launched with sbatch
if [ "x$SLURM_JOB_ID" == "x" ]; then
   echo "You need to submit your job to the queuing system with sbatch"
   exit 1
fi
# The modules to load:
module load trimmomatic
module load fastqc
module load multiqc/1.9-python-3.7.4
module load perl

# The job command(s):

# mode files into better folder structure
#mkdir -p data/untrimmed
#mv */*/*.fastq.gz data/untrimmed/
#rm -r SAM*
mkdir -p data/trimmed/orphaned
mkdir -p results/fastqc_trimmed
mkdir assembly
mkdir assembly/megahit
mkdir assembly/spades1
mkdir assembly/spades2
mkdir assembly/spades3

# Trim
for infile in data/untrimmed/*_1.fastq.gz
do
        base=$(basename ${infile} _1.fastq.gz)
        java -jar $EBROOTTRIMMOMATIC/trimmomatic-0.39.jar PE -threads 24 -phred33 ${infile} data/untrimmed/${base}_2.fastq.gz \
             data/trimmed/${base}_1.trim.fastq.gz \
             data/trimmed/orphaned/${base}_1un.trim.fastq.gz \
             data/trimmed/${base}_2.trim.fastq.gz \
             data/trimmed/orphaned/${base}_2un.trim.fastq.gz \
             SLIDINGWINDOW:4:20 MINLEN:50
done

# Quality control
fastqc -o results/fastqc_trimmed/ data/trimmed/*.fastq.gz

# Summarise all fastqc reports (helpful when there are many files):
multiqc -o results/fastqc_trimmed/ results/fastqc_trimmed/*

## Combine samples to mimic one paired-end read
cat data/trimmed/*1.trim.fastq.gz > data/trimmed/combined1.fastq.gz
cat data/trimmed/*2.trim.fastq.gz > data/trimmed/combined2.fastq.gz

# Megahit assembly
module load megahit
/usr/bin/time -v -o assembly/megahit.txt megahit -1 data/trimmed/combined1.fastq.gz -2 data/trimmed/combined2.fastq.gz -o results/megahit -t 24

# Metaspades assembly
module load spades
/usr/bin/time -v -o assembly/spades1.txt metaspades.py -1 data/trimmed/combined1.fastq.gz -2 data/trimmed/combined2.fastq.gz -o results/spades1 -t 24 -k 21,29,39,59,79,119 -m 450
/usr/bin/time -v -o assembly/spades2.txt metaspades.py -1 data/trimmed/combined1.fastq.gz -2 data/trimmed/combined2.fastq.gz -o results/spades2 -t 24 -k 29,39,59 -m 450
/usr/bin/time -v -o assembly/spades3.txt metaspades.py -1 data/trimmed/combined1.fastq.gz -2 data/trimmed/combined2.fastq.gz -o results/spades3 -t 24 -k 59,79,119 -m 450

# Copy assembled file to assembly folder and rename to .fa
cp ../results/megahit/final.contigs.fa megahit
cp ../results/spades1/scaffolds.fasta spades1/scaffolds.fa
cp ../results/spades2/scaffolds.fasta spades2/scaffolds.fa
cp ../results/spades3/scaffolds.fasta spades3/scaffolds.fa

# Trim metaspades to keep only contigs with >200bp
perl ../prinseq-lite.pl -fasta spades1/scaffolds.fa -out_good spades1/reduced.scaffolds.fa -min_len 200
perl ../prinseq-lite.pl -fasta spades2/scaffolds.fa -out_good spades2/reduced.scaffolds.fa -min_len 200
perl ../prinseq-lite.pl -fasta spades3/scaffolds.fa -out_good spades3/reduced.scaffolds.fa -min_len 200

# Rename to .fa format
mv spades1/reduced.scaffolds.fa.fasta spades1/reduced.scaffolds.fa
mv spades2/reduced.scaffolds.fa.fasta spades2/reduced.scaffolds.fa
mv spades3/reduced.scaffolds.fa.fasta spades3/reduced.scaffolds.fa