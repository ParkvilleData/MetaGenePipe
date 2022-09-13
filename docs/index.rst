.. MetaGenePipe documentation master file, created by
   sphinx-quickstart on Wed Mar 16 13:59:23 2022.
   You can adapt this file completely to your liking, but it should at least
   contain the root `toctree` directive.

Welcome to MetaGenePipe's documentation!
========================================

.. image:: ../logo/mgp_logo_cut.png
  :width: 400
  :alt: MetaGenePipe Logo

MetaGenePipe (MGP) is an efficient, flexible, portable, and scalable metagenomics pipeline that uses performant bioinformatics software suites and genomic databases to create an accurate taxonomic and functional characterization of the prokaryotic fraction of sequenced microbiomes.

A Microbiome is a collection of all microbes, such as bacteria, from a given environment. The environment can be human related, i.e. the human gut or can be from environments such as soil or water. The composition of the microbiome, in terms of the percentages of bacterial species present in the environment can be beneficial in determining the effect bacteria has on the environment. 

Microbial communities which make up microbiomes have the potential to be major regulators in biogeochemical processes and can determine ecosystem function. Understanding the composition, both in terms of diversity and taxnomic profiles, is useful for determining potential effects of changes in environmental conditions. For example, taxonomic composition of soil samples can be taken in base line (regular conditions) conditions and then compared to areas which may be experiencing distress in the form of physical ecological changes such as mining operations.

MetaGenePipe is a WDL workflow created using existing bioinformatics tools with the view of allowing the user to incorporate extra flexibility in creating taxonomic profiles of their microbiome samples. Through the use of Kegg's Brite Heirarchy, MetaGenePipe is able to process raw microbiome (metagenomic) samples, perform quality checks to remove poor quality sequences, assemble the samples to create longer length sequences, i.e. contigs which are then processed for open reading frames. These open reading frames are potential protein sequences which are then aligned to major protein databases. The matches from the alignment are parsed and using in house scripts, are assigned taxonomic ID's using the brite heirarchy. Example output from MetaGenePipe can be seen in the table below.  

+-----------------------------------------------------------+-----------+
|                         Pathway                           |   Count   |
+===========================================================+===========+ 
| 09121 Transcription                                       |     0     | 
+-----------------------------------------------------------+-----------+
| 09182 Protein families: genetic information processing    |     0     |
+-----------------------------------------------------------+-----------+
| 09183 Protein families: signaling and cellular processes  |     0     |
+-----------------------------------------------------------+-----------+
| 09192 Unclassified: genetic information processing        |     0     |
+-----------------------------------------------------------+-----------+
| 09192 Unclassified: genetic information processing        |     0     |
+-----------------------------------------------------------+-----------+
| 09194 Poorly characterized                                |     0     |
+-----------------------------------------------------------+-----------+
| Brite Hierarchies                                         |     6     |
+-----------------------------------------------------------+-----------+
| DNA repair and recombination proteins [BR:ko03400]        |     0     |
+-----------------------------------------------------------+-----------+
| DNA replication proteins [BR:ko03032]                     |     0     |
+-----------------------------------------------------------+-----------+
| Function unknown                                          |     0     |
+-----------------------------------------------------------+-----------+
| Genetic Information Processing                            |     1     | 
+-----------------------------------------------------------+-----------+
| Not Included in Pathway or Brite                          |     3     |
+-----------------------------------------------------------+-----------+
| Prokaryotic defense system [BR:ko02048]                   |     0     |
+-----------------------------------------------------------+-----------+
| RNA polymerase [PATH:ko03020]                             |     0     |
+-----------------------------------------------------------+-----------+
| Replication and repair                                    |     0     |
+-----------------------------------------------------------+-----------+
| Transcription machinery [BR:ko03021]                      |     0     |
+-----------------------------------------------------------+-----------+
| Transporters [BR:ko02000]                                 |     0     |
+-----------------------------------------------------------+-----------+

.. toctree::
   :maxdepth: 2
   :caption: Contents:

   installation
   usage
   workflow
   extension
   citation
   bibliography
   contributing

Indices and tables
==================

* :ref:`genindex`
* :ref:`modindex`
* :ref:`search`
