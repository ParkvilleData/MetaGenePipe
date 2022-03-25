==================
Usage
==================

Setup input file
==================

Open ``input.txt`` and update with your samples. The file format is as follows ::

  SampleID    Read1FQ Read2FQ

For example, the first two lines of ``input.txt`` could be ::

  mockpos_S50     /data/cephfs/punim0256/gitlab/metaGenePipe/metaGenePipe/fastqFiles/mockpos_S50_100k_R1.fasta    /data/cephfs/punim0256/gitlab/metaGenePipe/metaGenePipe/fastqFiles/mockpos_S50_100k_R2.fasta
  mockpos_S52     /data/cephfs/punim0256/gitlab/metaGenePipe/metaGenePipe/fastqFiles/mockpos_S52_100k_R1.fastq    /data/cephfs/punim0256/gitlab/metaGenePipe/metaGenePipe/fastqFiles/mockpos_S52_100k_R2.fastq

.. note::

  The spaces between the sampleID and reads are tabs. There can be no whitespaces at the end of each line or else the pipeline will fail. Use the complete path to the files to avoid any missed files.**


Copy files
==========

Copy your sample files to the path you used in the input.txt file. There is a folder called "fastqFiles" which can be used.


.. code-block:: bash

  bash:~$ cp *.fastq <metagenepipe_path>/fastqFiles/


Configuration
==============

Edit metaGenePipe.json (config file) and update the workingDir variable to reflect your working directory.

.. code-block:: json

  {

    "##_GLBOAL_VARS#": "global",

    "metaGenPipe.workingDir": "/data/cephfs/punim0256/MGP_ComEnc_011119/",
    
    "metaGenPipe.outputDir": "output",
    
    "metaGenPipe.inputSamplesFile": "input.txt",
    
    "metaGenPipe.outputFileName": "geneCountTable.txt",
    
    "metaGenPipe.kolist": "ko.sorted.txt",
    
  }
  

.. note::

  Change all paths to reflect where you are running the pipeline and change create the output directory you set in the config above **

.. note::
  
  The working directory you set has to be the directory you cloned the repository into**

Java
=====

Ensure that Java is installed. Since this pipeline is made to only be run on the UniMelb cluster, Spartan, Java is already installed. To load Java, you can use:

.. code-block:: bash

  bash:~$ module load Java


Run Pipeline
============

To run the pipeline use the command below in the directory where the cromwell jar file is found.

.. note::
  
  Before running the pipeline change the cromslurm.conf file to reflect the correct partition you have permission to submit to**

### the line you have change is: String rt_queue = "mig-gpu"

.. code-block:: bash

  bash:~$ java -Dconfig.file=./cromslurm.conf -jar cromwell-45.1.jar run metaGenPipe.wdl -i metaGenPipe.json
