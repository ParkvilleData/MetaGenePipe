=====================
Installation
=====================

Uses these steps to install MetaGenePipe:


Clone the repository
====================

.. code-block:: bash

    git clone https://github.com/ParkvilleData/MetaGenePipe.git
    cd MetaGenePipe

MetaGenePipe requires Java, Cromwell and Singularity to run.

Java
======

Ensure you have Java installed. If not, follow the instructions for the relevant operating system here: 
https://www.java.com/en/download/help/download_options.html

If running on Spartan (the University of Melbourne HPC cluster) Java is already installed. To load Java, you can use:

.. code-block:: bash

  module load Java

Other Dependencies
====================

Other necessary depenencies and databases can be downloaded using the setup script in the project directory. It requires that python (>=3.5) is available::

.. code-block:: bash

    python3 setup.py --hmmer_kegg prokaryote --singularity y -s y --blast mito --cromwell y

This takes about half an hour (due to bandwidth limitations for the KEGG FTP server).
  
Test that the Singularity container is working with the following command:
  
.. code-block:: bash

    singularity run metagenepipe.simg_v2.sif megahit --help

If the help description for megahit displays then the Singularity container can be used with MetaGenePipe.