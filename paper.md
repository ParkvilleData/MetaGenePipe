---
title: 'MetaGenePipe: An Automated, Portable Pipeline for Contig-based Functional and Taxonomic Analysis'
tags:
  - metagenomics
  - WDL
  - Singularity
  - Containerization
authors:
  - name: Babak Shaban
    orcid: 0000-0002-7393-810X
    affiliation: 1
  - name: Maria del Mar Quiroga
    orcid: 0000-0002-8943-2808
    corresponding: true # (This is how to denote the corresponding author)
    affiliation: 1
  - name: Robert Turnbull
    orcid: 0000-0003-1274-6750
    affiliation: 1
  - name: Edoardo Tescari
    orcid: 0000-0003-1157-4897
    affiliation: 1
  - name: Kim-Anh Lê Cao^[equal contribution]
    orcid: 0000-0003-3923-1116
    affiliation: 2
  - name: Heroen Verbruggen^[equal contribution]
    orcid: 0000-0002-6305-4749
    affiliation: 3
affiliations:
 - name: Melbourne Data Analytics Platform, The University of Melbourne
   index: 1
 - name: School of Mathematics and Statistics, Melbourne Integrative Genomics, The University of Melbourne
   index: 2
 - name: School of BioSciences, The University of Melbourne
   index: 3
date: 16 March 2022
bibliography: docs/refs.bib

---

# Summary

MetaGenePipe (MGP) is an efficient, flexible, portable, and scalable metagenomics pipeline that uses performant bioinformatics software suites and genomic databases to create an accurate taxonomic and functional characterization of the prokaryotic fraction of sequenced microbiomes. Written in the Workflow Definition Language (WDL), MGP produces output that can be explored and interpreted directly, or can be used for downstream analysis. MGP is a pipeline-development best practice tool that uses Singularity for containerization and includes a setup script that downloads the necessary databases for setup. The source code for MGP is freely available and distributed under the [Apache 2.0 license](https://www.apache.org/licenses/LICENSE-2.0).

The workflow uses MegaHIT for read assembly and the user can specify whether to co-assemble multiple samples or do sample-by-sample assembly. A BLAST search is carried out against a user-specified BLAST database.

Coding regions are predicted in contigs with Prodigal and taxonomic annotation of the predicted protein-coding genes is done using DIAMOND alignment against the Swiss-Prot database. Functional annotation uses HMMER searches against the KoalaFam HMM profiles. The main outputs of the workflow are tables with counts of taxonomic (organism) and functional hits against the reference databases, which can be easily employed for downstream statistical analysis. MGP's focus can be easily modified to find viruses, bacteria, plants, archaea, vertebrates, invertebrates, or fungi by choosing suitable reference databases.


# Statement of need 

MetaGenePipe (`MGP`) is a pipeline for characterizing the prokaryotic fraction of whole genome metagenomics shotgun sequencing data functionally and taxonomically.

`MGP` was designed to be used by computational microbiologists, written in WDL to make further customization accessible to researchers. `MGP` uses a Singularity container to overcome traditional portability obstacles and caters to a flexible research focus. For example, the default DIAMOND and BLAST databases can be replaced with any relevant databases owned by the researcher via an update in the configuration file. While `MGP` is focussed on prokaryotes, it can easily be adapted to eukaryotes or viruses by changing the prokaryotic gene prediction software, Prodigal, to eukaryotic gene prediction software such as GeneMark-EP+ [@10.1093/nargab/lqaa026] or [EuGene](http://eugene.toulouse.inra.fr/) [@Sallet2019], or a gene finding tool for viruses [insert link here].


![The MetaGenePipe Workflow](logo/MetaGenePipe.drawio.pdf) 

 
# Workflow 

MGP is written in the [Workflow Definition Language (WDL)](https://openwdl.org/), renowned for its human readable and writable syntax. Singularity [@kurtzer_sochat_bauer_2017] is used to containerize the software required for MGP, and is stored in [SylabsCloud](https://sylabs.io/) for universal accessibility.

MGP is broken up into four sub-workflows: Quality Control (QC), Assembly, Map Sequence Reads, and Gene Prediction.

There are currently several assembly-based taxonomic software suites such as MG-RAST [@keegan_glass_meyer_2016], MMseqs2 [@10.1093/bioinformatics/btab184], and a few that make use of a workflow language, including nf-core and Muffin written in Nextflow, and Atlas written in Snakemake [@krakau_straub_gourle_gabernet_nahnsen_2022; @di_tommaso_chatzou_floden_barja_palumbo_notredame_2017; @van_damme_hölzer_viehweger_müller_bongcam-rudloff_brandt_2021;  @kieser_brown_zdobnov_trajkovski_mccue_2020; @mölder_jablonski_letcher_hall_tomkins-tinch_sochat_forster_lee_twardziok_kanitz_et_al._2021]. The main advantage of MGP over MG-RAST is its ease of installation on local infrastructure, as it only requires running a setup script that downloads a supplied Singularity image from SylabsCloud, the latest version of Cromwell [@voss_van_der_auwera_gentry_2022], Koalafam HMMER profiles [@aramaki_blanc-mathieu_endo_ohkubo_kanehisa_goto_ogata_2019], and the Swiss-Prot database [@uniprot_consortium_2018] which is converted to the DIAMOND aligner [@Buchfink2015-rn] format. This setup allows MGP to be used on a range of computing infrastructures across institutions. 

## QC sub-workflow 

The quality control (QC) sub-workflow trims poor quality reads and any potential adapter sequence from the genomic samples using either Trimmomatic [@pmid24695404] or TrimGalore [@felix_krueger_2021_5127899]. There is also the option of lengthening the reads by merging overlapping paired-end reads using FLASH. This option can help overcome potential low-coverage regions encountered during the assembly process [@Magoc2011-gb]. Visualizations of the sequence quality are obtained using FastQC [@Andrews:2010tn].

There is an optional extra standalone task to merge and analyze the FastQC outputs from each of the samples using MultiQC [@10.1093/bioinformatics/btw354]. 


## Concatenate samples 

This standalone and optional task can consolidate all forward and all reverse reads into single forward and reverse files. This step is intended to facilitate the co-assembly of the available sequences, which has been shown to provide more complete genomes with lower error rates when compared to multiassembly [@hofmeyr2020].


## Assembly sub-workflow 

For assembling contigs we chose MegaHIT [@li_liu_luo_sadakane_lam_2015], which performs de-novo assembly of large and complex metagenomic samples in a time and cost-efficient manner [@10.1093/bioinformatics/btv033].

BLAST [@Camacho2009-hf; @Altschul1990-xn; @Altschul1997-oe] is used to query the contigs created during assembly against a user-specified BLAST database (e.g., mito, nt, nr), downloaded from the NCBI ftp server ([https://ftp.ncbi.nlm.nih.gov/blast/db/]). The BLAST output is parsed to be easily searchable and also lists queries returning no hits. This informs researchers to further investigate potentially novel sequences. Additionally, the BLAST results can be used to filter contigs that belong to a taxon of interest that was not matched during the Swiss-Prot alignment stage. This can be useful for genomic binning or investigation of regions of interest. 

## Map reads sub-workflow

Mapping the raw reads back to the assembled contigs allows for the quantification of the relative abundance of contigs in a metagenomics dataset. This task is important for downstream genomic binning and metagenome statistics. The raw reads that have passed the QC stage are at this point aligned back to the contigs resulting from the assembly sub-workflow using the Bowtie2 Aligner [@langmead2012]. A compressed binary file representing the alignment of sorted raw sequences to the assembly output in BAM format is created via SAMtools [@10.1093/bioinformatics/btp352]. Mapping statistics for the alignment are created using the SAMtools flagstat function, which can be used to quantify relative abundance.

## Gene prediction sub-workflow 

The gene prediction sub-workflow uses Prodigal (PROkaryotic Dynamic programming Gen-finding Algorithm) [@hyatt_chen_locascio_land_larimer_hauser_2010] for predicting prokaryotic gene coding sequences and identifying the sites of translation initiation [@Hyatt2010-zh]. Prodigal produces a Fasta file with the predicted amino acid (protein) coding sequences. These are then aligned to the Swiss-Prot database [@pmid18287689] with the DIAMOND aligner, and the output is parsed to generate a table of taxonomic (organism) identifications. The reference database can be easily exchanged if Swiss-Prot is not suitable for the user's application.

The protein coding sequences are also aligned to the [KoalaFam HMM profiles](https://www.genome.jp/tools/kofamkoala/) with [HMMER](http://hmmer.org/) [@pmid31742321], allowing assigning KEGG pathways and EC numbers to the proteins. Custom Python scripts are used to output counts at the A, B and C levels of the [KEGG Brite hierarchical function classification](https://www.genome.jp/kegg/kegg3b.html) [@pmid10592173; @pmid31441146; @pmid33125081]. 

## Outputs and interpretation

[ADD SECTION HERE]


## Resource usage and infrastructure requirements 

MGP uses Unix’s `time` tool to measure the resources used by each task, such as CPU usage, file size, elapsed time, and system time. This output can be visualized and used to inform resource requests when using a job scheduler on high-performance computing infrastructure. Table 1 shows indicative resource usage for processing paired-end samples of 25,000 reads each run on the University of Melbourne SPARTAN high-performance computing system consisting of Intel Xeon Gold 6154 3GHz CPUs. Running Cromwell on the head node took 2 minutes and 22.6 seconds (excluding time spent on the queue) and required a maximum memory of 837168 kbytes.

MGP can be run locally on a laptop, a virtual machine, or in a high-performance computing setting. 


| Task | User time (mm:ss) | Threads | CPU utilization | Max memory (kbytes) | 
|-------------------|--------------------------------|--------------------|--------------------|------------------------| 
| trimgalore | 00:02.5| 4 | 103% | 23144 | 
| fastqc | 00:05.78 | 2 | 120% | 305268 | 
| multiqc | 00:01.24 | 1 | 38% | 84960 |
| flash | 00:00.17 | 2 | 46% | 20388 | 
| concatenate | 00:00.3 | 1 | 54% | 20372 |
| megahit | 07:25.19 | 24 | 1770% | 70928 |
| blast | 00:00.13 | 6 | 43% | 22560 | 
| map reads | 00:01.19 | 4 | 107% | 92144 | 
| prodigal | 00:00.07 | 1 | 39% | 56796 | 
| diamond | 00:10.23 | 18 | 535% | 433768 | 
| hmmer | 00:47.9 | 8 | 106% | 59428 | 
| taxonomic classification | 00:00.56 | 1 | 46% | 74532 |
<p align = "center"> Table 1: The resource usage for processing two paired end samples of 25,000 reads each in MetaGenePipe.</p> 


# Acknowledgements 

We thank the members of the Verbruggen lab, Kshitij Tandon and Vinícius Salazar in particular, for sharing ideas, feedback, and testing the workflow. This research was supported by The University of Melbourne’s Research Computing Services and the Petascale Campus Initiative. The project benefited from funding by the Australian Research Council (DP200101613 to Heroen Verbruggen). 

 
# References 
