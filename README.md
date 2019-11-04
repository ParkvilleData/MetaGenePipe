MetaGenePipe developed by Bobbie shaban from Melbourne Integrative Genomics.

Microorganisms including bacteria, viruses, archaea, fungi are ubiquitous in our environment. The study of microorganisms and their full genomes has been enabled through advances in culture independent techniques and high-throughput sequencing technologies. Whole genome metagenomics shotgun sequencing (WGS) empowers researchers to study biological functions of microorganisms, and how their presence affect human disease or a specific ecosystem. However, advanced and novel bioinformatics techniques are required to process the data into a suitable format. There is no standardised bioinformatics framework a microbiologist can use effectively.
With Dr Kim-Anh Lê Cao (MIG School of Maths and Stats), we are developing MetaGenePipe, an efficient and flexible metagenomics bioinformatics pipeline. We have implemented new features to identify novel genes to enable the microbiology community to fully capitalize on these costly data and extract relevant biological knowledge. MetaGenePipe was developed in consultation with various researchers - e.g. Environmental Microbiology Research Initiative EMRI Prof Blackhall, Doherty Institute Prof Stinear School of Dentistry Prof Dashper at UoM, the Australian Centre for Ecogenomics (University of Queensland Prof Phil Hugenholtz) and Deakin University (Prof Vuilermin), to ensure our pipeline can answer various biological questions.
Different phases of development are proposed for this project. First, benchmarking on mock microbial communities to help choose the best bioinformatics tools in the pipeline, second, a command-line deployment release (beta), third, a user-friendly web interface for data upload and analysis, fourth, hands-on workshops to disseminate such tool.

How to Use:

Step 1:
Clone the git repository to a directory on your cluster

Step 2: 
Open input.txt and update with your samples. The file format is as follows.
`
SampleID    Read1FQ Read2FQ
`
e.g.
`
head input.txt
mockpos_S50     /data/cephfs/punim0256/gitlab/metaGenePipe/metaGenePipe/fastqFiles/mockpos_S50_100k_R1.fasta    /data/cephfs/punim0256/gitlab/metaGenePipe/metaGenePipe/fastqFiles/mockpos_S50_100k_R2.fasta
mockpos_S52     /data/cephfs/punim0256/gitlab/metaGenePipe/metaGenePipe/fastqFiles/mockpos_S52_100k_R1.fastq    /data/cephfs/punim0256/gitlab/metaGenePipe/metaGenePipe/fastqFiles/mockpos_S52_100k_R2.fastq

`

NOTE: The spaces between the sampleID and reads are tabs. There can be no whitespaces at the end of each line or else the pipeline will fail.
Use the complete path to the files to avoid any missed files.

Step 3:
Copy your sample files to the path you used in the input.txt file. There is a folder called "fastqFiles" which can be used. 

Step 4: 
Edit metaGenePipe.json (config file) and update the workingDir variable to reflect your working directory.

`
{
"##_GLBOAL_VARS#": \"global",
  "metaGenPipe.workingDir": "/data/cephfs/punim0256/MGP_ComEnc_011119/",
  "metaGenPipe.outputDir": "output",
  "metaGenPipe.inputSamplesFile": "input.txt",
  "metaGenPipe.outputFileName": "geneCountTable.txt",
  "metaGenPipe.kolist": "ko.sorted.txt",

`
metaGenePipe.workingDir should be the only variable you will have to edit to run the pipeline. You may edit the job submission resource requests further down the json config file to fine tune the pipeline to your needs.

Step 5:
Ensure that Java is installed. Since this pipeline is made to only be run on the UniMelb cluster, Spartan, Java is already installed. To load Java, you can use

`
module load Java
`

Step 6:
To run the pipeline use this command

`
java -Dconfig.file=./cromslurm.conf -jar cromwell-45.1.jar run metaGenPipe.wdl -i metaGenPipe.json
`

Creating your own database
You may create your own database by obtaining a protein dataset in fasta format. You will need to create a diamond database, and this can be done using the following commands.

1) module load diamond

2) diamond makedb --in nr.faa -d nr

3) Copy the resultant .dmnd file to the kegg/ directory.

4) Update the json config file and update the .DB variable to be the database you wish to align against

`
"metaGenPipe.DB": "kegg/kegg.dmnd",
`

Troubleshooting tips:
1) The pipeline has been set up to run against the swissprot database. We have supplied sample fastq files consisting of 100,000 reads so the pipeline can be tested.

2) If you would like access to the kegg database, send an email to bshaban@unimelb.edu.au and he may be able to see if you're eligble to use it.

*** NOTE ****

Some reference files have not been added due to be kegg reference files. These must be obtained separately with authorisation
