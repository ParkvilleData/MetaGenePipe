==================
Usage
==================

Setup input file
==================

Open ``input_file.txt`` and update with your samples. The file format is as follows ::

  SampleID    Read1FQ Read2FQ

For example, the first two lines of ``input_file.txt`` could be ::

  mockpos_S50     /data/cephfs/punim0256/gitlab/metaGenePipe/metaGenePipe/fastqFiles/mockpos_S50_100k_R1.fasta    /data/cephfs/punim0256/gitlab/metaGenePipe/metaGenePipe/fastqFiles/mockpos_S50_100k_R2.fasta
  mockpos_S52     /data/cephfs/punim0256/gitlab/metaGenePipe/metaGenePipe/fastqFiles/mockpos_S52_100k_R1.fastq    /data/cephfs/punim0256/gitlab/metaGenePipe/metaGenePipe/fastqFiles/mockpos_S52_100k_R2.fastq

.. note::

  The paths need to be the full paths on your file system.
  The spaces between the sampleID and reads are tabs. 
  There can be no whitespaces at the end of each line or else the pipeline will fail. 
  Use the complete path to the files to avoid any missed files.**

Output Directory
================

By default the workflow with write output to the ``./outputs`` directory. To change this, edit line 2 in ``metaGenPipe.options.json``:

.. code-block:: json

  "final_workflow_outputs_dir": "/path/to/output/",  

Blast (Optional)
================

To use blast, download your preferred database from here:
https://ftp.ncbi.nlm.nih.gov/blast/db/

Tell the worklow to use Blast by changing the ``metaGenPipe.blastBoolean`` variable to ``true`` on line 5 of ``metaGenePipe.json``
  
.. code-block:: json

  "metaGenPipe.blastBoolean": true,

Add the path to the Blast database on line 25 of ``metaGenePipe.json``

.. code-block:: json

  "metaGenPipe.database": "/path/to/BLAST/db/"

Additionally, set the ``database_directory`` in ``metaGenPipe.config`` on lines 34 and 104::

  String database_directory = "/path/to/BLAST/db/"

High Performance Computing (HPC) instructions
=============================================

To run in a High Performance Computing (HPC) environment, change the ``metaGenPipe.config`` file 
and change the default provider on line 17 from ``local`` to ``Slurm``. e.g. ::

  default = "Slurm"

Change the account string to the appropriate account on your HPC system on line 45 of ``metaGenPipe.config`` ::

  String account = "--account=ACCOUNT_NAME" 

Change the ``rt_queue`` string on line 39 of ``metaGenPipe.config`` to the partition name(s) in your job scheduler :: 

  String rt_queue = "PARTITION_NAME_1,PARTITION_NAME_2"

Run Pipeline
============

To run the pipeline use the command:

.. code-block:: bash

  java -Dconfig.file=./metaGenePipe.config -jar cromwell-latest.jar run metaGenePipe.wdl -i metaGenePipe.json -o metaGenePipe.options.json
