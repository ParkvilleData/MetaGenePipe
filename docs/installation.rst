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


Cromwell
====================

Download the latest Cromwell release .jar file from here: https://github.com/broadinstitute/cromwell/releases 
Place this jar file in the root directory of MetaGenePipe.

Singularity
====================

Follow the instructions for installing Singularity: https://sylabs.io/guides/3.0/user-guide/installation.html

Then get the Singularity image for MetaGenePipe:

.. code-block:: bash

    singularity pull --arch amd64 library://bshaban/metagenepipe/metagenepipe.simg:v1
  
Test the workflow with the following command:
  
.. code-block:: bash

    singularity run metagenepipe.simg_v1.sif megahit