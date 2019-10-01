MetaGenePipe developed by Bobbie shaban from Melbourne Integrative Genomics.

How to Use:

Download the required files into your directory by running git clone.

Place your fastq files in the same directory as your git clone

Run inputMaker.pl with the following command

module load Perl
perl inputMaker.pl -f fastq -o fastqList.txt -i 1

This will create a file called "fastqList.txt" with your sample files ready to be used as input into the pipeline.

Open metaGenePipe.json and adjust the config parameters as necessary

Run the pipeline using the following commands from SG1

module load Java

java -Dconfig.file=./cromslurm.conf -jar cromwell-30.1.jar run metaGenePipe.wdl -i metaGenePipe.json


*** NOTE ****

Some reference files have not been added due to be kegg reference files. These must be obtained separately with authorisation
