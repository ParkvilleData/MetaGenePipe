=====================
Installation
=====================

Uses these steps to install MetaGenePipe:


Clone the repository
====================

.. code-block:: bash

    git clone https://github.com/ParkvilleData/MetaGenePipe.git
    cd MetaGenePipe

MetaGenePipe requires Java, Singularity, and other dependencies to run. See below for instructions.

Java
======

Ensure you have Java installed (at least version 1.8 or higher). If not, follow the instructions for the relevant operating system here: 
https://www.java.com/en/download/help/download_options.html

If running on Spartan (the University of Melbourne HPC cluster), Java is already installed. To load Java, you can use:

.. code-block:: bash

  module load java

Singularity
===========

Ensure you have Singularity installed (version 3.6.3 or higher). If not, follow the instructions for the relevant operating system here: 
https://docs.sylabs.io/guides/3.0/user-guide/installation.html

If running on Spartan (the University of Melbourne HPC cluster), Singularity is already installed. To load Singularity, you can use:

.. code-block:: bash

  module load singularity/3.6.3

Other Dependencies
====================

Other necessary dependencies and databases can be downloaded using the setup script in the project directory. It requires that python (>=3.5) is available:

.. code-block:: bash

    python3 setup.py --hmmer_kegg prokaryote --singularity y --sprott y --blast mito --cromwell y

This takes about half an hour (due to bandwidth limitations for the KEGG FTP server).
  
Test that the Singularity container is working with the following command:
  
.. code-block:: bash

    singularity run metagenepipe.simg_v2.sif megahit --help

If the help description for megahit displays then the Singularity container can be used with MetaGenePipe.