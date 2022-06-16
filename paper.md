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

 

MetaGenePipe is an efficient, flexible, portable, and scalable metagenomics pipeline that uses ‘best-in-domain’ bioinformatics software suites and genomic databases to create an accurate taxonomic characterization of prokaryotic microbiome samples. Written in the Workflow Definition Language (WDL), MetaGenePipe (MGP) produces output that is both useful in its default form and that can be used for further downstream analysis. There are currently several contig-based taxonomic software suites such as MG-RAST [@keegan_glass_meyer_2016] and MMseqs2 [@10.1093/bioinformatics/btab184] with only a few which make use of a workflow language such as nf-core [@krakau_straub_gourlé_gabernet_nahnsen_2021] which is written in Nextflow [@di_tommaso_chatzou_floden_barja_palumbo_notredame_2017], Muffin [@van_damme_hölzer_viehweger_müller_bongcam-rudloff_brandt_2021] and Atlas [@kieser_brown_zdobnov_trajkovski_mccue_2020] which makes use of Snakemake [@mölder_jablonski_letcher_hall_tomkins-tinch_sochat_forster_lee_twardziok_kanitz_et_al._2021] and Nextflow respectively. MGP is a pipeline-development best practice which uses singularity [@kurtzer_sochat_bauer_2017] for containerization and includes a setup script which downloads the necessary databases for setup. The source code for MGP is freely available and is distributed under the [Apache 2.0 license](https://www.apache.org/licenses/LICENSE-2.0).

 

The main advantage of MGP over MG-RAST is how easily it can be installed on local infrastructure, requiring only the running of a supplied Singularity image which is downloaded from SylabsCloud via the running of the setup script which also downloads the latest version of cromwell [@voss_van_der_auwera_gentry_2022], Koalafam HMMER profiles [@aramaki_blanc-mathieu_endo_ohkubo_kanehisa_goto_ogata_2019], and the Swiss-Prot database [@uniprot_consortium_2018] which is converted to DIAMOND aligner [@Buchfink2015-rn] format. This setup allows MGP to be used across infrastructure across institutions. 

 

The current software list includes the option of two genomic assemblers, IDBA [@peng_leung_yiu_chin_2012] and MegaHIT [@li_liu_luo_sadakane_lam_2015], allowing for genomic assembly in low-coverage samples while allowing for computational efficiency. The included gene prediction tool, Prodigal (PROkaryotic Dynamic programming Gen-finding Algorithm) [@hyatt_chen_locascio_land_larimer_hauser_2010], is used to predict gene coding sequences from raw genomic data. DIAMOND, [HMMER](http://hmmer.org/) and BLAST [Basic Local Alignment Search Tool, @Camacho2009-hf; @Altschul1990-xn; @Altschul1997-oe] are the alignment tools incorporated into the workflow and allow for the alignment of predicted gene-coding sequences to known databases for classification. Currently the Swiss-Prot database is used for classifying genes to obtain protein descriptions and function. 

 

MetaGenePipe creates a taxonomic hierarchy classification using Kegg’s Brite hierarchy and KoalaFam HMMER profiles. MetaGenePipe’s focus can be modified to find viruses, bacteria, plants, archaea, vertebrates, invertebrates, or fungi by updating the reference databases to be kingdom specific. 

 

# Statement of need 

 

Microorganisms including bacteria, viruses, archaea, and fungi are ubiquitous in our environment. The study of microorganisms and their full genomes has been enabled through advances in culture independent techniques and high-throughput sequencing technologies. Whole genome metagenomics shotgun sequencing (WGS) empowers researchers to study biological functions of microorganisms, and how their presence affects human disease or a specific ecosystem. However, advanced, and novel bioinformatics techniques are required to process the data into a suitable format. There is no universally accepted standardized bioinformatics framework a microbiologist can use effectively. 

MGP is written in WDL and thus differs from existing assembly-based workflow pipelines such as Atlas (which uses Snakemake) and Muffin (which is written in Nextflow). MGP is an example of WDL and containerization best practice. Similar to NF-core/Mag, MGP employs co-assembly as a feature. MGP differs from NF-Core as it has the option to use IDBA-Assembler which is capable of assembling genomes of assembling reads of uneven sequencing coverage. 

 

MetaGenePipe overcomes traditional portability obstacles through the use of Singularity containers and increases flexibility of research focus by using the DIAMOND Aligner which allows the ability to create bespoke databases in a matter of minutes. Researchers often have institutional datasets which are a result of previous research. These datasets can be incorporated into MGP in the place of the default DIAMOND and BLAST databases. Once these databases have been created, an update in the relevant line in the configuration file will allow the workflow to use the new database. While MetaGenePipe is focussed on prokaryotes, it can easily be adapted to eukaryotes or viruses by changing the prokaryotic gene prediction software, Prodigal, to a eukaryote gene prediction software such as GeneMark-EP+ [@10.1093/nargab/lqaa026] or [EuGene](http://eugene.toulouse.inra.fr/) [@Sallet2019]. 


![The MetaGenePipe Workflow](logo/MetaGenePipe.drawio.pdf) 

 
# Workflow 


MetaGenePipe is written in the [Workflow Definition Language (WDL)](https://openwdl.org/) which is renowned for specifying data processing workflows in human-readable and writable syntax. Singularity is used to containerize the required software for MetaGenePipe to run and is stored in [SylabsCloud](https://sylabs.io/) for accessibility.  



MetaGenePipe is broken up into three sub-workflows: Quality Control (QC), Assembly, and Gene Prediction. Each subworkflow contains related tasks that are necessary for that portion of the workflow.  




## QC Sub-workflow 

 

The quality control (QC) sub-workflow contains the portion of the workflow which trims genomic samples for poor quality reads and any adapter sequence which may be present via the use of either Trimmomatic [@pmid24695404] or TrimGalore [@felix_krueger_2021_5127899]. There is also the option of merging the reads by merging overlapping reads paired-end reads using FLASH [@Magoc2011-gb]. Lengthening reads can help overcome potential low-coverage regions encountered during the assembly process. Visualizations of the sequence quality are obtained using FastQC [@Andrews:2010tn] and the subsequent FastQC output is merged and analyzed as a whole using MultiQC [@10.1093/bioinformatics/btw354]. 


## Concatenate Samples 



This is a standalone task that allows for the option of concatenating samples by merging forward reads and reverse reads into files combining all available samples. This step is intended to facilitate co-assembly of the available sequences. Co-assembly has shown to provide more complete genomes, with lower error rates when compared to multiassembly [@hofmeyr2020]. 



## Assembly sub-workflow 



The Assembly sub-workflow makes use of two genomic assemblers: IDBA and MegaHIT. IDBA is known for being able to assemble genomic samples with uneven sequencing length [@10.1093/bioinformatics/bts174].

While MegaHIT performs de novo assembly of large and complex metagenomics samples in a time and cost-efficient manner [@10.1093/bioinformatics/btv033]. 


## Gene Prediction sub-workflow 



The gene prediction sub-workflow uses Prodigal for prediction prokaryotic gene coding sequences and identifying the sites of translation initiation [@Hyatt2010-zh]. Prodigal produces an `fna` file with the resulting protein prediction. The predicted gene coding sequences are then aligned to the Swiss-Prot database [@pmid18287689] with the \mbox{DIAMOND} Aligner and to [KoalaFam HMMER profiles](https://www.genome.jp/tools/kofamkoala/) [@pmid31742321]. Custom Python scripts are then used to extract the output of the alignments and match genes to functional hierarchies using the [KEGG Brite Database](https://www.genome.jp/kegg/brite.html) [@pmid10592173; @pmid31441146; @pmid33125081].  


## Read Mapping and BLAST 


Alignment of raw reads back to the assembled contigs has the advantage of discerning the relative abundance of contigs in a metagenomics dataset. This is an important step in downstream genomic binning and metagenome statistics. The alignment of the raw reads that have passed the QC stage are used at this point by aligning back to the contigs that are the output of the assembly sub-workflow using the Burrows-Wheeler Aligner (BWA) [@Li2010-nl]. A compressed binary file representing the alignment of raw sequences to the assembly output in BAM format is created via BamTools [@10.1093/bioinformatics/btr174] and analysis performed using SAMtools [@10.1093/bioinformatics/btp352] flagstat function to determine the percentage of raw reads that were used for the assembly.  

BLAST is used to query the assembly created contigs to the NCBI NT/NR database to determine which species the assemble contigs belong to. The BLAST output is parsed in such a way that it is easily searchable and still lists queries which return “no hits”. This allows researchers to extract the results with “no hits” and decide on whether these require further investigation into their potential novelty. Additionally, the BLAST results can be used to filter contigs that belong to a taxon of interest which do not provide a match during the Swiss-Prot alignment stage for the purposes of genomic binning or targeted investigation for regions of interest. 


## Resource Usage and Infrastructure requirements 


MetaGenePipe relies on Unix’s `time` tool to measure the resources that each task uses, such as CPU usage, file size, elapsed time, and system time. This output can be parsed to create visualizations that can be used in deciding resource requests for the workflow when executing it using a job scheduler on high-performance computing infrastructure. Table 1 shows the resource usage for processing paired-end samples of 25,000 reads each. Table 2 shows the resource usage for running Cromwell on the head node. 


MetaGenePipe can be run locally on a laptop, a virtual machine, or in a high-performance computing setting.  


| Task | User Time (mm:ss) | CPU utilization | Max Memory (kbytes) | 
|-------------------|--------------------------------|--------------------|------------------------| 
| fastqc | 00:04.0 | 226% | 233376 | 
| flash | 00:00.3 | 129% | 13140 | 
| trim_galore | 00:02.30 | 183% | 22772 | 
| diamond | 00:03.2 | 477% | 392904 | 
| hmmer | 03:06.4 | 104% | 39296 | 
| prodigal | 00:00.4 | 96% | 49088 | 
| blast | 01:30.1 | 188% | 13308876 | 
| megahit | 00:08.2 | 446% | 66944 |
| multiqc | 00:04.5 | 84% | 78084 | 
| read alignment | 00:02.0 | 117% | 91952 | 

<p align = "center"> Table 1: The resource usage for processing paired end samples of 25,000 reads each in MetaGenePipe.</p> 

| Task | User Time (mm:ss) | CPU utilization | Max Memory (kbytes) | 
|-------------------|--------------------------------|--------------------|------------------------| 
| fastqc | 08:50.9 | 12% | 57280 | 


<p align = "center"> Table 2: The resource usage for running Cromwell on the head node.</p> 


# Acknowledgements 


We thank the members of the Verbruggen lab, Kshitij Tandon and Vinicius Salazar in particular, for sharing ideas, feedback and testing the workflow. This research was supported by The University of Melbourne’s Research Computing Services and the Petascale Campus. The project benefited from funding by the Australian Research Council (DP200101613 to Heroen Verbruggen). 

 
# References 
