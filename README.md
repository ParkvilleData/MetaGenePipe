# MetaGenePipe

![pipline](https://github.com/parkvilledata/MetaGenePipe/actions/workflows/testing.yml/badge.svg)
[<img src="https://github.com/parkvilledata/MetaGenePipe/actions/workflows/docs.yml/badge.svg">](<https://parkvilledata.github.io/MetaGenePipe>)
[![Contributor Covenant](https://img.shields.io/badge/Contributor%20Covenant-2.1-4baaaa.svg)](https://www.contributor-covenant.org/version/2/1/code_of_conduct/)
[![status](https://joss.theoj.org/papers/c9c52942084258507eeb1693b83153ba/status.svg)](https://joss.theoj.org/papers/c9c52942084258507eeb1693b83153ba)

MetaGenePipe (MGP) is an efficient, flexible, portable, and scalable metagenomics pipeline that uses performant bioinformatics software suites and genomic databases to create an accurate taxonomic and functional characterization of the prokaryotic fraction of sequenced microbiomes.

Microorganisms such as bacteria, viruses, archaea, and fungi are ubiquitous in our environment. The study of microorganisms and their full genomes has been enabled through advances in culture independent techniques and high-throughput sequencing technologies. Whole genome metagenomics shotgun sequencing (WGS) empowers researchers to study biological functions of microorganisms, and how their presence affects human disease or a specific ecosystem. However, advanced and novel bioinformatics techniques are required to process the data into a suitable format. There is no universally accepted standardized bioinformatics framework that a computational microbiologist can use effectively. 

MGP is written in WDL and thus differs from existing assembly-based workflow pipelines such as Atlas (which uses Snakemake) and Muffin (which is written in Nextflow). MGP is an example of WDL and containerization best practice. Similar to NF-core/Mag, MGP employs co-assembly of multiple metagenome samples as a feature. 

MGP overcomes traditional portability obstacles by using Singularity containers, and increases flexibility of research focus by using the DIAMOND aligner — able to create bespoke databases in a matter of minutes. Researchers often have institutional datasets resulting from previous research, which can be incorporated into MGP in place of the default DIAMOND and BLAST databases. Once these databases have been created, an update in the relevant line in the configuration file will allow the workflow to use the new database. While MGP is focussed on prokaryotes, it can easily be adapted to eukaryotes or viruses by changing the prokaryotic gene prediction software, Prodigal, to eukaryotic gene prediction software such as GeneMark-EP+  or [EuGene](http://eugene.toulouse.inra.fr/), or a gene finding tool for viruses. 

MGP is an efficient, flexible, portable, and scalable metagenomics pipeline that uses performant bioinformatics software suites and genomic databases to create an accurate taxonomic and functional characterization of the prokaryotic fraction of sequenced microbiomes.

A Microbiome is a collection of all microbes, such as bacteria, from a given environment. The environment can be human related, i.e. the human gut or can be from environments such as soil or water. The composition of the microbiome, in terms of the percentages of bacterial species present in the environment can be beneficial in determining the effect bacteria has on the environment.

Microbial communities which make up microbiomes have the potential to be major regulators in biogeochemical processes and can determine ecosystem function. Understanding the composition, both in terms of diversity and taxnomic profiles, is useful for determining potential effects of changes in environmental conditions. For example, taxonomic composition of soil samples can be taken in base line (regular conditions) conditions and then compared to areas which may be experiencing distress in the form of physical ecological changes such as mining operations.

MGP is a WDL workflow created using existing bioinformatics tools with the view of allowing the user to incorporate extra flexibility in creating taxonomic profiles of their microbiome samples. Through the use of Kegg's Brite Heirarchy,  MGP is able to process raw microbiome (metagenomic) samples, perform quality checks to remove poor quality sequences, assemble the samples to create longer length sequences, i.e. contigs which are then processed for open reading frames. These open reading frames are potential protein sequences which are then aligned to major protein databases. The matches from the alignment are parsed and using in house scripts, are assigned taxonomic ID's using the brite heirarchy. Example output from MGP can be seen in the table below.

| Pathway | Count |
| ------- | ----- |
| 09121 Transcription | 0 |
| 09182 Protein families: genetic information processing  | 0 |
| 09183 Protein families: signaling and cellular processes | 0 |
| 09192 Unclassified: genetic information processing | 0 |
| 09194 Poorly characterized | 0 |
| Brite Hierarchies | 6 |
| DNA repair and recombination proteins [BR:ko03400] | 0 |
| DNA replication proteins [BR:ko03032] | 0 |
| Function unknown | 0 |
| Genetic Information Processing | 1 |
| Not Included in Pathway or Brite | 3 |
| Prokaryotic defense system [BR:ko02048] | 0 |
| RNA polymerase [PATH:ko03020] | 0 |
| Replication and repair  | 0 |
| Transcription machinery [BR:ko03021] | 0 |
| Transporters [BR:ko02000] | 0 |

Please refer to the [documentation](https://parkvilledata.github.io/MetaGenePipe/) for how to run.

## Citation and Attribution

MetaGenePipe was developed at the Melbourne Data Analytics Platform (MDAP).

We are in the process of authoring a paper for the Journal of Open Source Software about this software package. Citation details will be added upon publication.

If you create a derivative work from this software package, attribution should be included as follows:

> This is a derivative work of MetaGenePipe, originally released under the Apache 2.0 license, developed by Bobbie Shaban, Mar Quiroga, Robert Turnbull and Edoardo Tescari at Melbourne Data Analytics Platform (MDAP) at the University of Melbourne.

## Troubleshooting tips:
` The pipeline has been set up to run against the swissprot database. We have supplied sample fastq files consisting of 100,000 reads so the pipeline can be tested.`




