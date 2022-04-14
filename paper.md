---
title: 'MetaGenePipe: A pipeline for metagenomics'
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

MetaGenePipe is an efficient, flexible, portable and scalable metagenomics pipeline that uses ‘best-in-domain’ bioinformatics software suites, genomic databases to create an accurate taxonomic characterisation of prokaryotic microbiome samples. Written in the Workflow Definition Language (WDL), MetaGenePipe (MGP) produces output that is both useful and can used for further downstream analysis.  

The current software list includes the option of two genomic assemblers, IDBA and MegaHIT, allowing for genomic assembly in low-coverage samples while allowing for computational efficiency. The gene prediction tool, Prodigal (PROkaryotic Dynamic programming Gen-finding Algorithm), is used to predict gene coding sequences from raw genomic data. Diamond, HMMER and BLAST are the alignment tools incorporated into the MetaGenePipe workflow and allow for the alignment of predicted Gene Coding Sequences to known databases for classification. Currently the Swiss-Prot database is used for classification purposes.  

Not only does MetaGenePipe create an OTU table for known organisms, but it also provides Brite hierarchy classification when using KoalaFam HMMER profiles.  MetaGenePipe can easily be tailored to find viruses, bacteria, plants, archaea, vertebrates, invertebrates or fungi with minimal changes. 


# Statement of need 

Microorganisms including bacteria, viruses, archaea, and fungi are ubiquitous in our environment. The study of microorganisms and their full genomes has been enabled through advances in culture independent techniques and high-throughput sequencing technologies. Whole genome metagenomics shotgun sequencing (WGS) empowers researchers to study biological functions of microorganisms, and how their presence affect human disease or a specific ecosystem. However, advanced, and novel bioinformatics techniques are required to process the data into a suitable format. There is no universally accepted standardised bioinformatics framework a microbiologist can use effectively. Most modern metagenomic software packages including MG-RAST and Kraken automates taxonomic classification of bacterial sequences within genomic samples. While both MG-RAST and Kraken are well known metagenomic software suites, installation of MG-RAST on local hardware infrastructure is difficult and set up of Kraken custom databases can take up-to 5 hours according to the [Kraken operating manual](https://ccb.jhu.edu/software/kraken/MANUAL.html). 

MetaGenePipe overcomes these obstacles by improving portability and installation via the use of Singularity containers and the Diamond Aligner [@Buchfink2015-rn] which can take minutes to create bespoke databases.  

While MetaGenePipe is focussed on Prokaryotes, it can easily be adapted to eukaryotes or viruses by changing the prokaryotic gene prediction software, Prodigal, to a eukaryote gene prediction software such as GeneMark-EP+ [@10.1093/nargab/lqaa026] or [EuGene](http://eugene.toulouse.inra.fr/) [@Sallet2019].  

Similarly, bespoke databases can easily be created by using the ‘makedb’ function that comes with Diamond Aligner. Once the database has been created an update in the relevant line in the configuration file will allow the workflow to use the new database. 

Earlier versions of MetaGenePipe have been used previously in publications [@Arden2017-as].

# Infrastructure requirements 

MetaGenePipe can be run locally on a laptop or in a high performance computing setting. metaGenePipe requires a minimum of 1 core and 5 gigabytes of RAM to complete the test example that comes in the git repository. Further discussion is available in the [MetaGenePipe documentation](https://parkvilledata.github.io/MetaGenePipe/).

# Workflow 

MetaGenePipe is written in the [Workflow Definition Language (WDL)](https://openwdl.org/) which is renowned for specifying data processing workflows in human-readable and writable syntax. Singularity is used to containerise the required software for MetaGenePipe to run and is stored in [SylabsCloud](https://sylabs.io/) for accessibility.  

MetaGenePipe is broken up into three sub-workflows which contains all the individual components of the workflow: QC Subworkflow, Assembly Sub-workflow and the Gene Prediction Sub-workflow, with separate tasks for Gene alignment, Merge Samples and taxonomic alignment. 

![The MetaGenePipe Workflow](logo/MetaGenePipe.drawio.pdf)

## QC Sub-workflow 

The quality control (QC) sub-worflow contains the portion of the workflow which trims genomic samples for poor quality reads and any adapter sequence which may be present via the use of either Trimmomatic [@pmid24695404] or TrimGalore [@felix_krueger_2021_5127899]. There is also the option of lengthening the reads by connecting any overlapping 5’ and 3’ regions in paired-end reads. Lengthening reads can help overcome potential low-coverage regions encountered during the assembly process. 

## Concatenate Samples 

Standalone task, concatenate samples, concatenates samples by merging forward reads and reverse reads into separate files combining all available samples. This step is intended to improve sequence coverage when performing the assembly. 

## Assembly sub-workflow 	 

The Assembly sub-workflow makes use of two genomic assemblers, IDBA and Megahit. IDBA is known for being able to assemble genomic samples with uneven sequencing length [@10.1093/bioinformatics/bts174]. Megahit is “a de novo assembler for assembling large and complex metagenomics samples in a time- and cost – efficient manner” [@10.1093/bioinformatics/btv033]. 

## Gene Prediction sub-workflow 

The gene prediction sub-workflow uses Prodigal for “prokaryotic gene recognition and translation initiation site identification” [@Hyatt2010-zh].  Three types of output files are produced, genbank (.gbk), nucleotide (.fna) and protein (.fna) which are used in the gene alignment portion of the workflow. 

The predicted gene coding sequences are then aligned to the Swiss-Prot database [@pmid18287689] with the Diamond Aligner and to [KoalaFam HMMER profiles](https://www.genome.jp/tools/kofamkoala/) [@pmid31742321]. Custom Python scripts are then used to extract the output of the alignments and match genes to functional hierarchies using the [KEGG Brite Database](https://www.genome.jp/kegg/brite.html) [@pmid10592173; @pmid31441146; @pmid33125081]. 

## Read Mapping and BLAST 

Read Mapping is a post processing quality control stage whose output can be used to indicate the quality of the results produced by MetaGenePipe. The alignment of the raw reads that have passed the QC stage are used at this point by aligning back to the contigs that are the output of the assembly sub-workflow. A compressed binary file representing the alignment of raw sequences to the assembly output in BAM format is created via BamTools [@10.1093/bioinformatics/btr174] and analysis performed using SAMtools [@10.1093/bioinformatics/btp352] flagstat function to determine the percentage of raw reads that were used for the assembly. The output of this step can be used to evaluate the quality of the output created by the assembly stage. 

The second post processing quality check is the BLAST task. BLAST (Basic Local Alignment Search Tool) [@Camacho2009-hf; @Altschul1990-xn; @Altschul1997-oe] is used to query the assembly created contigs to the NCBI NT/NR database to ascertain which species the assemble contigs belong to. The BLAST output is parsed in such a way that it’s easily searchable and still lists queries which return “no hits”. Doing so allows researchers to extract the results with “no hits” and make a decision on whether these require further investigation into its potential novelty. 

##  Optimization 

MetaGenePipe uses unix’s time tool to measure resources each task uses. Resource such as CPU utilisaton, Maximum resident size, Elapsed (wall clock) time and System time. This output can be parsed to create visualisations that can be used in deciding resource requests for the workflow when executing using a job scheduler on high performance computing infrastructure. 
 
# Acknowledgements



# References

<!-- An atypical Parvovirus drives chronic tubulointerstitial
               nephropathy and kidney fibrosis -->

[@Roediger2018-lq] 

  <!-- title = {{FASTQC. A quality control tool for high throughput sequence data}}, -->
[@Andrews:2010tn]

<!--   title     = "{FLASH}: fast length adjustment of short reads to improve genome -->
[@Magoc2011-gb]
<!-- DeconSeq -->
[@Schmieder2011-jr]

  <!-- title     = "Fast and accurate long-read alignment with {Burrows-Wheeler}
               transform",
 -->
[@Li2010-nl]

