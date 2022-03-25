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
  - name: Edoardo Tescari
    orcid: 0000-0003-1157-4897
    affiliation: 1
  - name: Robert Turnbull
    orcid: 0000-0003-1274-6750
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

MetaGenePipe is an efficient, flexible and scalable metagenomics bioinformatics pipeline uses the latest bioinformatics software and databases to create an accurate characterisation of microbiome samples and produces output that is familiar and can be ported to other applications for further downstream analysis. The current software list includes the latest versions Deconseq [@Schmieder2011-jr], IDBA, MegaHIT, Prodigal, Diamond and BLAST and the current databases include KEGG and Swissprot. The “genomic discovery” portion of the pipeline has been used with success to find novel viruses from environmental samples.
 
Not only does MetaGenePipe create an OTU table for known organisms it also creates an estimation of novel organisms found within your samples and to the best our knowledge MetaGenePipe is the only pipeline to do this. Most modern metagenomic software including MG-RAST and Kraken automates taxomonimc classification of bacterial sequences within environmental samples. MetaGenePipe not only performs taxonomic classifications but also discovers potentially novel sequences, assembles them and then reports the results to the user. MetaGenePipe can also be tailored to find viruses, bacteria, plants, archaea, vertebrates, invertebrates or fungi with minimal changes.

# Statement of need

Microorganisms including bacteria, viruses, archaea, fungi are ubiquitous in our environment. The study of microorganisms and their full genomes has been enabled through advances in culture independent techniques and high-throughput sequencing technologies. Whole genome metagenomics shotgun sequencing (WGS) empowers researchers to study biological functions of microorganisms, and how their presence affect human disease or a specific ecosystem. However, advanced and novel bioinformatics techniques are required to process the data into a suitable format. There is no standardised bioinformatics framework a microbiologist can use effectively.


# Workflow

# Use in Metagenomic Research

Versions of MetaGenePipe have been used previously in publications [@Arden2017-as; @Roediger2018-lq]. The current version of the pipeline was used to analyze more than 700 environmental metagenomic datasets which will be published at the Melbourne Metagenomic Archive (MMA).


# Acknowledgements



# References

[@Arden2017-as]
[@Roediger2018-lq]
[@Andrews:2010tn]
[@Magoc2011-gb]
[@Schmieder2011-jr]
[@Hyatt2010-zh]
[@Buchfink2015-rn]
[@Li2010-nl]
[@Camacho2009-hf]
[@Altschul1997-oe]
[@Silva_e_Santos2012-qm]
[@Tosello2012-kp]
[@Corinne2012-tx]
[@Herrera2012-qm]
[@Soares2012-us]
[@Blome2012-dx]
[@Bitencourt2012-vu]
[@Coelho2012-tk]
[@Scariot2012-bl]
[@Zulch2012-ul]
[@Altschul1990-xn]

