MetaGenePipe
============

|pipline| ` <https://parkvilledata.github.io/MetaGenePipe>`__
|Contributor Covenant| |status|

MetaGenePipe (MGP) is an efficient, flexible, portable, and scalable
metagenomics pipeline that uses performant bioinformatics software
suites and genomic databases to create an accurate taxonomic and
functional characterization of the prokaryotic fraction of sequenced
microbiomes.

Microorganisms such as bacteria, viruses, archaea, and fungi are
ubiquitous in our environment. The study of microorganisms and their
full genomes has been enabled through advances in culture independent
techniques and high-throughput sequencing technologies. Whole genome
metagenomics shotgun sequencing (WGS) empowers researchers to study
biological functions of microorganisms, and how their presence affects
human disease or a specific ecosystem. However, advanced and novel
bioinformatics techniques are required to process the data into a
suitable format. There is no universally accepted standardized
bioinformatics framework that a computational microbiologist can use
effectively.

MGP is written in WDL and thus differs from existing assembly-based
workflow pipelines such as Atlas (which uses Snakemake) and Muffin
(which is written in Nextflow). MGP is an example of WDL and
containerization best practice. Similar to NF-core/Mag, MGP employs
co-assembly of multiple metagenome samples as a feature.

MGP overcomes traditional portability obstacles by using Singularity
containers, and increases flexibility of research focus by using the
DIAMOND aligner — able to create bespoke databases in a matter of
minutes. Researchers often have institutional datasets resulting from
previous research, which can be incorporated into MGP in place of the
default DIAMOND and BLAST databases. Once these databases have been
created, an update in the relevant line in the configuration file will
allow the workflow to use the new database. While MGP is focussed on
prokaryotes, it can easily be adapted to eukaryotes or viruses by
changing the prokaryotic gene prediction software, Prodigal, to
eukaryotic gene prediction software such as GeneMark-EP+ or
`EuGene <http://eugene.toulouse.inra.fr/>`__, or a gene finding tool for
viruses.

A Microbiome is a collection of all microbes, such as bacteria, from a
given environment. The environment can be human related, i.e. the human
gut or can be from environments such as soil or water. The composition
of the microbiome, in terms of the percentages of bacterial species
present in the environment can be beneficial in determining the effect
bacteria has on the environment.

Microbial communities which make up microbiomes have the potential to be
major regulators in biogeochemical processes and can determine ecosystem
function. Understanding the composition, both in terms of diversity and
taxnomic profiles, is useful for determining potential effects of
changes in environmental conditions. For example, taxonomic composition
of soil samples can be taken in base line (regular conditions)
conditions and then compared to areas which may be experiencing distress
in the form of physical ecological changes such as mining operations.

MGP is a WDL workflow created using existing bioinformatics tools with
the view of allowing the user to incorporate extra flexibility in
creating taxonomic profiles of their microbiome samples. Through the use
of Kegg’s Brite Heirarchy, MGP is able to process raw microbiome
(metagenomic) samples, perform quality checks to remove poor quality
sequences, assemble the samples to create longer length sequences,
i.e. contigs which are then processed for open reading frames. These
open reading frames are potential protein sequences which are then
aligned to major protein databases. The matches from the alignment are
parsed and using in house scripts, are assigned taxonomic ID’s using the
brite heirarchy. Example output from MGP can be seen in the table below.

======================================================== =====
Pathway                                                  Count
======================================================== =====
09121 Transcription                                      0
09182 Protein families: genetic information processing   0
09183 Protein families: signaling and cellular processes 0
09192 Unclassified: genetic information processing       0
09194 Poorly characterized                               0
Brite Hierarchies                                        6
DNA repair and recombination proteins [BR:ko03400]       0
DNA replication proteins [BR:ko03032]                    0
Function unknown                                         0
Genetic Information Processing                           1
Not Included in Pathway or Brite                         3
Prokaryotic defense system [BR:ko02048]                  0
RNA polymerase [PATH:ko03020]                            0
Replication and repair                                   0
Transcription machinery [BR:ko03021]                     0
Transporters [BR:ko02000]                                0
======================================================== =====

More details can be found in the `documentation <https://parkvilledata.github.io/MetaGenePipe>`_.

Installation
====================

To install MetaGenePipe, clone the repository:

.. code-block:: bash

    git clone https://github.com/ParkvilleData/MetaGenePipe.git
    cd MetaGenePipe

MetaGenePipe requires Java, Singularity, and other dependencies to run. 
See the `installation instructions in the documentation <https://parkvilledata.github.io/MetaGenePipe/installation.html>`_ for further information.

Usage
======

To run MetaGenePipe, modify the input files to reflect your sample files and required configuration settings. Then you can start the workflow with the following command:

.. code-block:: bash

   java -Dconfig.file=./metaGenePipe.config -jar cromwell-latest.jar run metaGenePipe.wdl -i metaGenePipe.json -o metaGenePipe.options.json

More information about running MetaGenePipe is found in the `documentation <https://parkvilledata.github.io/MetaGenePipe/usage.html>`_

Output
======

There are five main folders of output (Assembly, Gene Prediction, Read Alignment, QC and Taxon) and one intermediary (data) which contains the merging of raw samples and the output from Trim Galore. 

An example tree of the the output directory and the associated output definitions are below:

The Assembly directory contains the following
* merged.contigs.k27.fa: Kmer assembled contigs: assembled contigs for the kmer values, represented in the "intermediate_contigs" folder
* merged.megahit.contigs.fa: Final assembled contigs
* merged.37.fastg: A fastg file. Fastg is the assembly graph produced by the assembler.
* merged.megahit.blast.out: Raw blast results for the contigs
* merged.megahit.blast.parsed: Blast results parsed to be easily viewed in tsv format

Gene prediction contains the output from prodigal
* Merge.hmmer.out: Raw hmmer output aligned to Koalafam profiles
* Merge.hmmer.tblout: Parsed hmmer output aligned to Koalafam profiles
* Merge.prodigal.genes.fa: Gene coordinates file (Genbank like file)
* Merge.prodigal.nucl.genes.fa: Predicted gene nucleotide sequences
* Merge.prodigal.potential_genes.fa: Prodigal starts file
* Merge.prodigal.proteins.fa: Predicted gene amino acid sequences
* Merge.xml: XML output of alignment of predicted Amino Acids to NCBI database (We chose swissprot, but any blast database can be substituted)

Quality Control
* SRR5808831.TG_R1_fastqc.zip: Fastqc output for each of the individual sample files
* multiqc_report.html: Combined report of all fastqc files

Read Alignment
* SRR5808831.TG.flagstat.txt: Samtools flagstat output. Reports statistics on alignment of reads back to assembled contigs
* SRR5808831.TG.sam: Alignment of reads back to contigs in SAM format
* SRR5808831.TG.sorted.bam: Alignment of reads back to contigs in BAM format

Taxon output
* Level1.brite.counts.tsv: Level 1 Kegg Brite Heirarchical count
* Level2.brite.counts.tsv: Level 2 Kegg Brite Heirarchical count
* Level3.brite.counts.tsv: Level 3 Kegg Brite Heirarchical count

Output Tree
~~~~~~~~~~~

::

   .
   ├── assembly
   │   ├── intermediate_contigs
   │   │   ├── merged.contigs.k27.fa
   │   │   ├── merged.contigs.k37.fa
   │   │   ├── merged.contigs.k47.fa
   │   │   ├── merged.contigs.k57.fa
   │   │   ├── merged.contigs.k67.fa
   │   │   ├── merged.contigs.k77.fa
   │   │   ├── merged.contigs.k87.fa
   │   │   └── merged.contigs.k97.fa
   │   ├── merged.37.fastg
   │   ├── merged.megahit.blast.out
   │   ├── merged.megahit.blast.parsed
   │   └── merged.megahit.contigs.fa
   ├── data
   │   ├── merged
   │   │   ├── merged_R1.fq.gz
   │   │   └── merged_R2.fq.gz
   │   └── trimmed
   │       ├── SRR5808831.TG_R1.fq.gz
   │       ├── SRR5808831.TG_R2.fq.gz
   │       ├── SRR5808882.TG_R1.fq.gz
   │       └── SRR5808882.TG_R2.fq.gz
   ├── geneprediction
   │   ├── Merge.hmmer.out
   │   ├── Merge.hmmer.tblout
   │   ├── Merge.prodigal.genes.fa
   │   ├── Merge.prodigal.nucl.genes.fa
   │   ├── Merge.prodigal.potential_genes.fa
   │   ├── Merge.prodigal.proteins.fa
   │   ├── Merge.xml
   │   └── Merge.xml.out
   ├── qc
   │   ├── fastqc_zip
   │   │   ├── SRR5808831.TG_R1_fastqc.zip
   │   │   ├── SRR5808831.TG_R2_fastqc.zip
   │   │   ├── SRR5808882.TG_R1_fastqc.zip
   │   │   └── SRR5808882.TG_R2_fastqc.zip
   │   └── multiqc_report.html
   ├── readalignment
   │   ├── SRR5808831.TG.flagstat.txt
   │   ├── SRR5808831.TG.sam
   │   ├── SRR5808831.TG.sorted.bam
   │   ├── SRR5808882.TG.flagstat.txt
   │   ├── SRR5808882.TG.sam
   │   └── SRR5808882.TG.sorted.bam
   ├── SRR5808831.extendedFrags.fastq
   ├── SRR5808882.extendedFrags.fastq
   └── taxon
       ├── Level1.brite.counts.tsv
       ├── Level2.brite.counts.tsv
       └── Level3.brite.counts.tsv

Please refer to the
`documentation <https://parkvilledata.github.io/MetaGenePipe/>`__ for
how to run.

Citation and Attribution
========================

MetaGenePipe was developed at the Melbourne Data Analytics Platform
(MDAP).

We are in the process of authoring a paper for the Journal of Open
Source Software about this software package. Citation details will be
added upon publication.

If you create a derivative work from this software package, attribution
should be included as follows:

   This is a derivative work of MetaGenePipe, originally released under
   the Apache 2.0 license, developed by Bobbie Shaban, Mar Quiroga,
   Robert Turnbull and Edoardo Tescari at Melbourne Data Analytics
   Platform (MDAP) at the University of Melbourne.

Contributing
========================

If you would like to contribute to this software package, please make sure you follow the `code of conduct <https://parkvilledata.github.io/MetaGenePipe/contributing.html>`_.

Troubleshooting tips:
========================

The pipeline has been set up to run against the swissprot database. We have supplied sample fastq files consisting of 100,000 reads so the pipeline can be tested.

.. |pipline| image:: https://github.com/parkvilledata/MetaGenePipe/actions/workflows/testing.yml/badge.svg
.. |Contributor Covenant| image:: https://img.shields.io/badge/Contributor%20Covenant-2.1-4baaaa.svg
   :target: https://www.contributor-covenant.org/version/2/1/code_of_conduct/
.. |status| image:: https://joss.theoj.org/papers/c9c52942084258507eeb1693b83153ba/status.svg
   :target: https://joss.theoj.org/papers/c9c52942084258507eeb1693b83153ba
