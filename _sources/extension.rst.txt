==================
Extension
==================

You may create your own database by obtaining a protein dataset in fasta format. You will need to create a diamond database, and this can be done using the following commands.

.. code-block:: bash

  bash:~$ module load diamond
  bash:~$ diamond makedb --in nr.faa -d nr


where ``nr.faa`` here is a protein fasta file.

Copy the resultant ``.dmnd`` file to the ``kegg/`` directory.

Update the json config file and update the .DB variable to be the database you wish to align against

.. code-block:: 

  "metaGenPipe.DB": "kegg/kegg.dmnd",
