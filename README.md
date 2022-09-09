# MetaGenePipe

![pipline](https://github.com/parkvilledata/MetaGenePipe/actions/workflows/testing.yml/badge.svg)
[<img src="https://github.com/parkvilledata/MetaGenePipe/actions/workflows/docs.yml/badge.svg">](<https://parkvilledata.github.io/MetaGenePipe>)
[![Contributor Covenant](https://img.shields.io/badge/Contributor%20Covenant-2.1-4baaaa.svg)](https://www.contributor-covenant.org/version/2/1/code_of_conduct/)
[![status](https://joss.theoj.org/papers/c9c52942084258507eeb1693b83153ba/status.svg)](https://joss.theoj.org/papers/c9c52942084258507eeb1693b83153ba)

MetaGenePipe (MGP) is an efficient, flexible, portable, and scalable metagenomics pipeline that uses performant bioinformatics software suites and genomic databases to create an accurate taxonomic and functional characterization of the prokaryotic fraction of sequenced microbiomes.

Microorganisms such as bacteria, viruses, archaea, and fungi are ubiquitous in our environment. The study of microorganisms and their full genomes has been enabled through advances in culture independent techniques and high-throughput sequencing technologies. Whole genome metagenomics shotgun sequencing (WGS) empowers researchers to study biological functions of microorganisms, and how their presence affects human disease or a specific ecosystem. However, advanced and novel bioinformatics techniques are required to process the data into a suitable format. There is no universally accepted standardized bioinformatics framework that a computational microbiologist can use effectively. 

MGP is written in WDL and thus differs from existing assembly-based workflow pipelines such as Atlas (which uses Snakemake) and Muffin (which is written in Nextflow). MGP is an example of WDL and containerization best practice. Similar to NF-core/Mag, MGP employs co-assembly of multiple metagenome samples as a feature. 

MGP overcomes traditional portability obstacles by using Singularity containers, and increases flexibility of research focus by using the DIAMOND aligner — able to create bespoke databases in a matter of minutes. Researchers often have institutional datasets resulting from previous research, which can be incorporated into MGP in place of the default DIAMOND and BLAST databases. Once these databases have been created, an update in the relevant line in the configuration file will allow the workflow to use the new database. While MGP is focussed on prokaryotes, it can easily be adapted to eukaryotes or viruses by changing the prokaryotic gene prediction software, Prodigal, to eukaryotic gene prediction software such as GeneMark-EP+  or [EuGene](http://eugene.toulouse.inra.fr/), or a gene finding tool for viruses. 

Please refer to the [documentation](https://parkvilledata.github.io/MetaGenePipe/) for how to run.

## Citation and Attribution

MetaGenePipe was developed at the Melbourne Data Analytics Platform (MDAP).

We are in the process of authoring a paper for the Journal of Open Source Software about this software package. Citation details will be added upon publication.

If you create a derivative work from this software package, attribution should be included as follows:

> This is a derivative work of MetaGenePipe, originally released under the Apache 2.0 license, developed by Bobbie Shaban, Mar Quiroga, Robert Turnbull and Edoardo Tescari at Melbourne Data Analytics Platform (MDAP) at the University of Melbourne.

## Troubleshooting tips:
` The pipeline has been set up to run against the swissprot database. We have supplied sample fastq files consisting of 100,000 reads so the pipeline can be tested.`




