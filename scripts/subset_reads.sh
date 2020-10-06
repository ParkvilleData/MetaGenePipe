# Create subset of files with certain number of reads for benchmarking
# Usage: bash subset_reads.sh TTB000062_full
# Need to be in directory where original files are

set -e
nreads=( 250 500 1000 2000 5000 ) # in thousands

for i in "${nreads[@]}"
    do
    mkdir -p "${i}K"

    reads=$(expr 4*1000*$i | bc)
    head -n $reads ${1}1.fastq > "${i}K"/R1.fastq
    head -n $reads ${1}2.fastq > "${i}K"/R2.fastq

    fq2fa --merge "${i}K"/R1.fastq "${i}K"/R2.fastq "${i}K"/merged.fa
done


