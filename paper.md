---
title: 'MetaGenePipe: An Automated, Portable Pipeline for Contig-based Functional and Taxonomic Analysis'
tags:
  - metagenomics
authors:
  - name: Babak Shaban
    orcid: 0000-0002-7393-810X
    affiliation: 1
  - name: Maria del Mar Quiroga
    orcid: 0000-0002-8943-2808
    affiliation: 1
  - name: Robert Turnbull
    orcid: 0000-0003-1274-6750
    affiliation: 1
  - name: Edoardo Tescari
    orcid: 0000-0003-1157-4897
    affiliation: 1
  - name: Heroen Verbruggen
    orcid: 0000-0002-6305-4749
    affiliation: 2
  - name: Kim-Anh Lê Cao
    orcid: 0000-0003-3923-1116
    affiliation: 3
affiliations:
 - name: Melbourne Data Analytics Platform, The University of Melbourne
   index: 1
 - name: School of BioSciences, The University of Melbourne
   index: 2
 - name: School of Mathematics and Statistics, Melbourne Integrative Genomics, The University of Melbourne
   index: 3
date: 16 March 2022
bibliography: docs/refs.bib

---

# Summary 

MetaGenePipe is an efficient, flexible, portable and scalable metagenomics pipeline that uses ‘best-in-domain’ bioinformatics software suites, genomic databases to create an accurate taxonomic characterisation of prokaryotic microbiome samples. Written in the Workflow Definition Language (WDL), MetaGenePipe (MGP) produces output that is both useful and can used for further downstream analysis. The current contig based homology searching approaches to taxonomic classification includes such software suites like MG-RAST and MMseqs2 (https://academic.oup.com/bioinformatics/article/37/18/3029/6178277). 

MGP differs from MG-RAST by being a tool which is easily installed on local infrastructure and it differs from MMSeqs2 as it doesn't eliminate fragments which do not bear similarity to existing reference databases and as such low-score homology matches produced by MGP can be used for discovering novel sequences.

The current software list includes the option of two genomic assemblers, IDBA and MegaHIT, allowing for genomic assembly in low-coverage samples while allowing for computational efficiency. The gene prediction tool, Prodigal (PROkaryotic Dynamic programming Gen-finding Algorithm), is used to predict gene coding sequences from raw genomic data. Diamond, HMMER and BLAST are the alignment tools incorporated into the MetaGenePipe workflow and allow for the alignment of predicted Gene Coding Sequences to known databases for classification. Currently the Swiss-Prot database is used for classification purposes.  

Not only does MetaGenePipe create an Operational Taxonomic Unit (OTU) table for known organisms, but it also provides Brite hierarchy classification when using KoalaFam HMMER profiles.  MetaGenePipe's focus can be modified to find viruses, bacteria, plants, archaea, vertebrates, invertebrates or fungi by updating the reference databases to be kingdom specific. 


# Statement of need 

Microorganisms including bacteria, viruses, archaea, and fungi are ubiquitous in our environment. The study of microorganisms and their full genomes has been enabled through advances in culture independent techniques and high-throughput sequencing technologies. Whole genome metagenomics shotgun sequencing (WGS) empowers researchers to study biological functions of microorganisms, and how their presence affect human disease or a specific ecosystem. However, advanced, and novel bioinformatics techniques are required to process the data into a suitable format. There is no universally accepted standardised bioinformatics framework a microbiologist can use effectively. Most modern metagenomic software packages including MG-RAST and Kraken automates taxonomic classification of bacterial sequences within genomic samples. While both MG-RAST and Kraken are well known metagenomic software suites, installation of MG-RAST on local hardware infrastructure is difficult and set up of Kraken custom databases can take up-to 5 hours according to the [Kraken operating manual](https://ccb.jhu.edu/software/kraken/MANUAL.html). 

MetaGenePipe overcomes these obstacles by improving portability and installation via the use of Singularity containers and the Diamond Aligner [@Buchfink2015-rn] which can take minutes to create bespoke databases.  

While MetaGenePipe is focussed on Prokaryotes, it can easily be adapted to eukaryotes or viruses by changing the prokaryotic gene prediction software, Prodigal, to a eukaryote gene prediction software such as GeneMark-EP+ [@10.1093/nargab/lqaa026] or [EuGene](http://eugene.toulouse.inra.fr/) [@Sallet2019].  

Similarly, bespoke databases can easily be created by using the ‘makedb’ function that comes with Diamond Aligner. Once the database has been created an update in the relevant line in the configuration file will allow the workflow to use the new database. 

<!-- Earlier versions of MetaGenePipe have been used previously in publications [@Arden2017-as]. -->

# Workflow 

MetaGenePipe is written in the [Workflow Definition Language (WDL)](https://openwdl.org/) which is renowned for specifying data processing workflows in human-readable and writable syntax. Singularity is used to containerise the required software for MetaGenePipe to run and is stored in [SylabsCloud](https://sylabs.io/) for accessibility.  

MetaGenePipe is broken up into three sub-workflows which contains all the individual components of the workflow: QC Subworkflow, Assembly Sub-workflow and the Gene Prediction Sub-workflow, with separate tasks for Gene alignment, Merge Samples and taxonomic alignment. 

![The MetaGenePipe Workflow](logo/MetaGenePipe.drawio.pdf)

## QC Sub-workflow 

The quality control (QC) sub-worflow contains the portion of the workflow which trims genomic samples for poor quality reads and any adapter sequence which may be present via the use of either Trimmomatic [@pmid24695404] or TrimGalore [@felix_krueger_2021_5127899]. There is also the option of lengthening the reads by connecting any overlapping 5’ and 3’ regions in paired-end reads using FLASH [@Magoc2011-gb]. Lengthening reads can help overcome potential low-coverage regions encountered during the assembly process. Visualisations of the sequence quality is obtained through the use of FastQC [@Andrews:2010tn] and the subsequent FastQC output is merged and analysed as a whole using MultiQC [@10.1093/bioinformatics/btw354].

## Concatenate Samples 

Standalone task, concatenate samples, concatenates samples by merging forward reads and reverse reads into separate files combining all available samples. This step is intended to improve sequence coverage when performing the assembly. 

## Assembly sub-workflow 	 

The Assembly sub-workflow makes use of two genomic assemblers, IDBA and Megahit. IDBA is known for being able to assemble genomic samples with uneven sequencing length [@10.1093/bioinformatics/bts174]. Megahit is “a de novo assembler for assembling large and complex metagenomics samples in a time- and cost – efficient manner” [@10.1093/bioinformatics/btv033]. 

## Gene Prediction sub-workflow 

The gene prediction sub-workflow uses Prodigal for “prokaryotic gene recognition and translation initiation site identification” [@Hyatt2010-zh].  Three types of output files are produced, genbank (.gbk), nucleotide (.fna) and protein (.fna) which are used in the gene alignment portion of the workflow. 

The predicted gene coding sequences are then aligned to the Swiss-Prot database [@pmid18287689] with the Diamond Aligner and to [KoalaFam HMMER profiles](https://www.genome.jp/tools/kofamkoala/) [@pmid31742321]. Custom Python scripts are then used to extract the output of the alignments and match genes to functional hierarchies using the [KEGG Brite Database](https://www.genome.jp/kegg/brite.html) [@pmid10592173; @pmid31441146; @pmid33125081]. 

## Read Mapping and BLAST 

Read Mapping is a post processing quality control stage whose output can be used to indicate the quality of the results produced by MetaGenePipe. The alignment of the raw reads that have passed the QC stage are used at this point by aligning back to the contigs that are the output of the assembly sub-workflow using the Burrows-Wheeler Aligner (BWA) [@Li2010-nl]. A compressed binary file representing the alignment of raw sequences to the assembly output in BAM format is created via BamTools [@10.1093/bioinformatics/btr174] and analysis performed using SAMtools [@10.1093/bioinformatics/btp352] flagstat function to determine the percentage of raw reads that were used for the assembly. The output of this step can be used to evaluate the quality of the output created by the assembly stage. 

The second post processing quality check is the BLAST task. BLAST (Basic Local Alignment Search Tool) [@Camacho2009-hf; @Altschul1990-xn; @Altschul1997-oe] is used to query the assembly created contigs to the NCBI NT/NR database to ascertain which species the assemble contigs belong to. The BLAST output is parsed in such a way that it’s easily searchable and still lists queries which return “no hits”. Doing so allows researchers to extract the results with “no hits” and make a decision on whether these require further investigation into its potential novelty. 

##  Resource Usage and Infrastructure requirements

MetaGenePipe uses unix’s time tool to measure resources each task uses. Resource such as CPU utilisaton, Maximum resident size, Elapsed (wall clock) time and System time. This output can be parsed to create visualisations that can be used in deciding resource requests for the workflow when executing using a job scheduler on high performance computing infrastructure. Table 1 shows the resource usage for processing paired end samples of 25,000 reads each. Table 2 shows the resource usage for running Cromwell on the head node.

MetaGenePipe can be run locally on a laptop or in a high performance computing setting. metaGenePipe requires a minimum of 1 core and 5 gigabytes of RAM to complete the test example that comes in the git repository. 


|   Task            |   User Time (mm:ss)            |   CPU utilisation  |   Max Memory (kbytes)  |
|-------------------|--------------------------------|--------------------|------------------------|
|   fastqc          |   00:04.0                      |   226%             |   233376               |
|   flash           |   00:00.3                      |   129%             |   13140                |
|   trim_galore     |   00:02.3                      |   183%             |   22772                |
|   diamond         |   00:03.2                      |   477%             |   392904               |
|   hmmer           |   03:06.4                      |   104%             |   39296                |
|   prodigal        |   00:00.4                      |   96%              |   49088                |
|   blast           |   01:30.1                      |   188%             |   13308876             |
|   megahit         |   00:08.2                      |   446%             |   66944                |
|   multiqc         |   00:04.5                      |   84%              |   78084                |
|   read alignment  |   00:02.0                      |   117%             |   91952                |

<p align = "center"> Table 1: The resource usage for processing paired end samples of 25,000 reads each in MetaGenePipe.</p>

|   Task            |   User Time (mm:ss)            |   CPU utilisation  |   Max Memory (kbytes)  |
|-------------------|--------------------------------|--------------------|------------------------|
|   fastqc          |   08:50.9                      |   12%              |   572800               |

<p align = "center"> Table 2: The resource usage for running Cromwell on the head node.</p>


<!-- Further discussion is available in the [MetaGenePipe documentation](https://parkvilledata.github.io/MetaGenePipe/). -->


# Acknowledgements

We thank the members of the Verbruggen lab, Kshitij Tandon and Vinicius Salazar in particular, for sharing ideas, feedback and testing the workflow.
This research was supported by The University of Melbourne’s Research Computing Services and the Petascale Campus.
The project benefited from funding by the Australian Research Council (DP200101613 to Heroen Verbruggen).

# References
