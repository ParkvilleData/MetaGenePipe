![Image](../logo/mgp_logo_cut.png?raw=true)

# MetaGenePipe developed by Bobbie shaban from Melbourne Integrative Genomics.

Microorganisms including bacteria, viruses, archaea, fungi are ubiquitous in our environment. The study of microorganisms and their full genomes has been enabled through advances in culture independent techniques and high-throughput sequencing technologies. Whole genome metagenomics shotgun sequencing (WGS) empowers researchers to study biological functions of microorganisms, and how their presence affect human disease or a specific ecosystem. However, advanced and novel bioinformatics techniques are required to process the data into a suitable format. There is no standardised bioinformatics framework a microbiologist can use effectively.
With Dr Kim-Anh Lê Cao (MIG School of Maths and Stats), we are developing MetaGenePipe.,

MetaGenePipe is an efficient, flexible and scalable metagenomics bioinformatics pipeline uses the latest bioinformatics software and databases to create an accurate characterisation of microbiome samples and produces output that is familiar and can be ported to other applications for further downstream analysis. The current software list includes the latest versions Deconseq, IDBA, MegaHIT, Prodigal, Diamond and BLAST and the current databases include KEGG and Swissprot. The “genomic discovery” portion of the pipeline has been used with success to find novel viruses from environmental samples. The method has been used in publications but MetaGenePipe is not yet published. [1] [2]
 
Developed at the University of Melbourne in conjunction with Melbourne Integrative Genomics, not only does MetaGenePipe create an OTU table for known organisms it also creates an estimation of novel organisms found within your samples and to the best our knowledge MetaGenePipe is the only pipeline to do this. Most modern metagenomic software including MG-RAST and Kraken automates taxomonimc classification of bacterial sequences within environmental samples. MetaGenePipe not only performs taxonomic classifications but also discovers potentially novel sequences, assembles them and then reports the results to the user. MetaGenePipe can also be tailored to find viruses, bacteria, plants, archaea, vertebrates, invertebrates or fungi with minimal changes.
 
Different phases of development are proposed for this project. First, benchmarking on mock microbial communities to help choose the best bioinformatics tools in the pipeline, second, a command-line deployment release (beta), third, a user-friendly web interface for data upload and analysis, fourth, hands-on workshops to disseminate such tool.
 

## MetaGenePipe workflow

![Image](../logo/MegaGenePipe.jpeg?raw=true)

## Is MetaGenePipe for you?
** Expected output **

*  OTU Table
*  Taxanomic Profile
*  Level A, B, C Brite Hierarchy Counts:  (https://www.genome.jp/kegg/kegg3b.html)
*  Gene count table (raw)
*  Fastqc sequence output
*  Function counts (raw)
*  Fasta file of potentially novel sequences and blast of the sequences (tsv)

## How to Use:

### Prestep: Sign up for University of Melbourne Gitlab account. If you are unable to clone the repository email bobbie: bshaban@unimelb.edu.au

### Step 1: `Clone the git repository to a directory on your cluster`
```
bash:~$ git clone https://gitlab.unimelb.edu.au/bshaban/metaGenePipe.git .
```

** Ensure you have the correct permissions to run the pipeline. If you are unsure you can send an email to your HPC System Administrator

### Step 2: `Open input.txt and update with your samples. The file format is as follows.`

```
SampleID    Read1FQ Read2FQ

e.g.

head input.txt
mockpos_S50     /data/cephfs/punim0256/gitlab/metaGenePipe/metaGenePipe/fastqFiles/mockpos_S50_100k_R1.fasta    /data/cephfs/punim0256/gitlab/metaGenePipe/metaGenePipe/fastqFiles/mockpos_S50_100k_R2.fasta
mockpos_S52     /data/cephfs/punim0256/gitlab/metaGenePipe/metaGenePipe/fastqFiles/mockpos_S52_100k_R1.fastq    /data/cephfs/punim0256/gitlab/metaGenePipe/metaGenePipe/fastqFiles/mockpos_S52_100k_R2.fastq

```

**NOTE: The spaces between the sampleID and reads are tabs. There can be no whitespaces at the end of each line or else the pipeline will fail. Use the complete path to the files to avoid any missed files.**

### Step 3: `Copy your sample files to the path you used in the input.txt file. There is a folder called "fastqFiles" which can be used.` 
```
bash:~$ cp *.fastq <metagenepipe_path>/fastqFiles/
```

### Step 4: `Edit metaGenePipe.json (config file) and update the workingDir variable to reflect your working directory.`
```

{

"##_GLBOAL_VARS#": "global",

  "metaGenPipe.workingDir": "/data/cephfs/punim0256/MGP_ComEnc_011119/",
  
  "metaGenPipe.outputDir": "output",
  
  "metaGenPipe.inputSamplesFile": "input.txt",
  
  "metaGenPipe.outputFileName": "geneCountTable.txt",
  
  "metaGenPipe.kolist": "ko.sorted.txt",
  
  }
  
```

**NOTE: Change all paths to reflect where you are running the pipeline and change create the output directory you set in the config above **
**NOTE: The working directory you set has to be the directory you cloned the repository into**

### Step 5: `Load java module`
**Ensure that Java is installed. Since this pipeline is made to only be run on the UniMelb cluster, Spartan, Java is already installed. To load Java, you can use**

```
bash:~$ module load Java
```

### Step 6: `To run the pipeline use the command below in the directory where the cromwell jar file is found`

**NOTE: Before running the pipeline change the cromslurm.conf file to reflect the correct partition you have permission to submit to**

#### the line you have change is: String rt_queue = "mig-gpu"

```
bash:~$ java -Dconfig.file=./cromslurm.conf -jar cromwell-45.1.jar run metaGenPipe.wdl -i metaGenPipe.json
```

## Creating your own database
You may create your own database by obtaining a protein dataset in fasta format. You will need to create a diamond database, and this can be done using the following commands.

```
bash:~$ module load diamond

bash:~$ diamond makedb --in nr.faa -d nr
```

**NOTE: nr.faa is a protein fasta file**

`Copy the resultant .dmnd file to the kegg/ directory.`

`Update the json config file and update the .DB variable to be the database you wish to align against`

```
"metaGenPipe.DB": "kegg/kegg.dmnd",
```


## Troubleshooting tips:
` The pipeline has been set up to run against the swissprot database. We have supplied sample fastq files consisting of 100,000 reads so the pipeline can be tested.`

` If you would like access to the kegg database, send an email to bshaban@unimelb.edu.au and he may be able to see if you're eligble to use it. `

**NOTE: Some reference files have not been added due to be kegg reference files. These must be obtained separately with authorisation**

## References for software used

* [1]: Detection of Toscana virus from an adult traveler returning to Australia with encephalitis. Katherine E. Arden  Claire Heney  Babak Shaban  Graeme R. Nimmo  Michael D. Nissen  Theo P. Sloots  Ian M. Mackay.https://doi.org/10.1002/jmv.24839

* [2]: An atypical parvovirus drives chronic tubulointerstitial nephropathy and kidney fibrosis. B Roediger, Q Lee, S Tikoo, JCA Cobbin, JM Henderson, M Jormakka, Babak Shaban. Cell 175 (2), 530-543. e24

* Andrews S. (2010). FastQC: a quality control tool for high throughput sequence data. Available online at: http://www.bioinformatics.babraham.ac.uk/projects/fastqc

* FLASH: Fast length adjustment of short reads to improve genome assemblies. T. Magoc and S. Salzberg. Bioinformatics 27:21 (2011), 2957-63.

* Deconseq: Schmieder R and Edwards R: Fast identification and removal of sequence contamination from genomic and metagenomic datasets. PLoS ONE 2011, 6:e17288. [PMID: 21408061]

* Prodigal: prokaryotic gene recognition and translation initiation site identification: Doug Hyatt, Gwo-Liang Chen,1 Philip F LoCascio,1 Miriam L Land,1,3 Frank W Larimer,1,2 and Loren J Hauser1,3

* Buchfink B, Xie C, Huson DH, "Fast and sensitive protein alignment using DIAMOND", Nature Methods 12, 59-60 (2015). doi:10.1038/nmeth.3176

* Li H. and Durbin R. (2010) Fast and accurate long-read alignment with Burrows-Wheeler transform. Bioinformatics, 26, 589-595. [PMID: 20080505]

*  Camacho C. et al. (2009) "BLAST+: architecture and applications"
*  Altschul S.F. et al. (1997) "Gapped BLAST and PSI-BLAST: a new generation of protein database search programs"
*  Altschul S.F. et al. (1990) "Basic local alignment search tool"



