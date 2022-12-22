MetaGenePipe
============

|pipline| |docs| |Contributor Covenant| |joss|

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

you can start the workflow with the following command:

.. code-block:: bash

   java -Dconfig.file=./metaGenePipe.config -jar cromwell-latest.jar run metaGenePipe.wdl -i metaGenePipe.json -o metaGenePipe.options.json

The pipeline has been set up to run against the swissprot database. We have supplied sample fastq files consisting of 100,000 reads so the pipeline can be tested.
You can modify the input file ``input_file.txt`` to reflect your sample files. 

Read the `documentation <https://parkvilledata.github.io/MetaGenePipe/usage.html>`_ for more information about usage and modifying the configuration files.

Output
======

There are four main output folders: qc (quality control), assembly, readalignment, and geneprediction and one intermediary, data, which contains the samples for assembly after running through TrimGalore and concatenating the samples for co-assembly if specified. 

An example tree of the the output directory and the associated output definitions are below:

Quality Control
* trimmed
  * {sampleName}.T{G|T}_R{1|2}.fq.gz: Trimmed output for each of the individual sample files, TG if the chosen trimmer is TrimGalore, and TT if it is Trimmomatic
* fastqc
  * {sampleName}.T{G|T}_R{1|2}_fastqc.zip: Fastqc output for each of the individual sample files
* multiqc_report.html: Combined report of all fastqc files
* flash
  * {sampleName}.extendedFrags.fastq: [ADD HERE]

Data
* {sampleName}_R{1|2}.fq.gz Sample files after trimming and/or concatenating for co-assembly. If files are concatenated for co-assembly, the sample name is set to be `combined`

Assembly
* {sampleName}.megahit.contigs.fa: Final assembled contigs
* {sampleName}.{kmer}.fastg: Assembly graph for {kmer} assembled contigs, where {kmer} produces the largest assembled contig file size in the `intermediate_contigs` folder
* intermediate_contigs: a folder containing all intermediate assembled contigs {sampleName}.contigs.k{kmer}.fastg
* {sampleName}.megahit.blast.out: Raw blast results for the contigs
* {sampleName}.megahit.blast.parsed: Blast results parsed to be easily viewed in tsv format

Read alignment
* {sampleName}.T{G|T}.flagstat.txt: Samtools flagstat output. Reports statistics on alignment of reads back to assembled contigs
* {sampleName}.T{G|T}.sam: Alignment of reads back to contigs in SAM format
* {sampleName}.T{G|T}.sorted.bam: Alignment of reads back to contigs in BAM format

Gene prediction
* {sampleName}.megahit.proteins.fa.xml.out.xml: XML output of alignment of predicted Amino Acids to NCBI database (We chose swissprot, but any blast database can be substituted)
* diamond
  * {sampleName}.megahit.proteins.fa.xml.out:
* hmmer
  * combined.megahit.proteins.hmmer.out: Raw hmmer output aligned to Koalafam profiles
  * combined.megahit.proteins.hmmer.tblout: Parsed hmmer output aligned to Koalafam profiles
* prodigal
  * combined.megahit.gene_coordinates.gbk: Gene coordinates file (Genbank like file)
  * combined.megahit.nucl_genes.fa: Predicted gene nucleotide sequences
  * combined.megahit.proteins.fa: Predicted gene amino acid sequences
  * combined.megahit.starts.txt: Prodigal starts file
* taxon
  * LevelA.brite.counts.tsv: Level A Kegg Brite Hierarchical count
  * LevelB.brite.counts.tsv: Level B Kegg Brite Hierarchical count
  * LevelC.brite.counts.tsv: Level C Kegg Brite Hierarchical count
  * OTU.brite.tsv: [DESCRIBE HERE]

Output Tree
~~~~~~~~~~~

::

   .
   ├── assembly
   │   ├── combined.57.fastg
   │   ├── combined.megahit.blast.out
   │   ├── combined.megahit.blast.parsed
   │   ├── combined.megahit.contigs.fa
   │   └── intermediate_contigs
   │       ├── combined.contigs.k27.fa
   │       ├── combined.contigs.k37.fa
   │       ├── combined.contigs.k47.fa
   │       ├── combined.contigs.k57.fa
   │       ├── combined.contigs.k67.fa
   │       ├── combined.contigs.k77.fa
   │       ├── combined.contigs.k87.fa
   │       └── combined.contigs.k97.fa
   ├── data
   │   ├── combined_R1.fq.gz
   │   └── combined_R2.fq.gz
   ├── geneprediction
   │   ├── combined.megahit.proteins.fa.xml.out.xml
   │   ├── diamond
   │   │   └── combined.megahit.proteins.fa.xml.out
   │   ├── hmmer
   │   │   ├── combined.megahit.proteins.hmmer.out
   │   │   └── combined.megahit.proteins.hmmer.tblout
   │   ├── prodigal
   │   │   ├── combined.megahit.gene_coordinates.gbk
   │   │   ├── combined.megahit.nucl_genes.fa
   │   │   ├── combined.megahit.proteins.fa
   │   │   └── combined.megahit.starts.txt
   │   └── taxon
   │       ├── Level1.brite.counts.tsv
   │       ├── Level2.brite.counts.tsv
   │       ├── Level3.brite.counts.tsv
   │       └── OTU.brite.tsv
   ├── qc
   │   ├── fastqc
   │   │   ├── SRR5808831.TG_R1_fastqc.zip
   │   │   ├── SRR5808831.TG_R2_fastqc.zip
   │   │   ├── SRR5808882.TG_R1_fastqc.zip
   │   │   └── SRR5808882.TG_R2_fastqc.zip
   │   ├── flash
   │   │   ├── SRR5808831.extendedFrags.fastq
   │   │   └── SRR5808882.extendedFrags.fastq
   │   ├── multiqc_report.html
   │   └── trimmed
   │       ├── SRR5808831.TG_R1.fq.gz
   │       ├── SRR5808831.TG_R2.fq.gz
   │       ├── SRR5808882.TG_R1.fq.gz
   │       └── SRR5808882.TG_R2.fq.gz
   └── readalignment
      ├── SRR5808831.TG.flagstat.txt
      ├── SRR5808831.TG.sam
      ├── SRR5808831.TG.sorted.bam
      ├── SRR5808882.TG.flagstat.txt
      ├── SRR5808882.TG.sam
      └── SRR5808882.TG.sorted.bam

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


.. |pipline| image:: https://github.com/parkvilledata/MetaGenePipe/actions/workflows/testing.yml/badge.svg
.. |docs| image:: https://github.com/parkvilledata/MetaGenePipe/actions/workflows/docs.yml/badge.svg
   :target: https://parkvilledata.github.io/MetaGenePipe
.. |Contributor Covenant| image:: https://img.shields.io/badge/Contributor%20Covenant-2.1-4baaaa.svg
   :target: https://www.contributor-covenant.org/version/2/1/code_of_conduct/
.. |joss| image:: https://joss.theoj.org/papers/c9c52942084258507eeb1693b83153ba/status.svg
   :target: https://joss.theoj.org/papers/c9c52942084258507eeb1693b83153ba
