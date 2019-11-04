package DeconSeqConfig;

use strict;

use constant DEBUG => 0;
use constant PRINT_STUFF => 1;
use constant VERSION => '0.4.3';
use constant VERSION_INFO => 'DeconSeq version '.VERSION;

use constant ALPHABET => 'ACGTN';

#use constant DB_DIR => '/data/cephfs/punim0256/MGP_ComEnc_011119/db';
use constant DB_DIR => '/data/cephfs/punim0639/databases/deconseq/';
use constant TMP_DIR => '/data/cephfs/punim0256/MGP_ComEnc_011119/db/tmp/';
use constant OUTPUT_DIR => '/data/cephfs/punim0256/MGP_ComEnc_011119/output/';

use constant PROG_NAME => 'bwa64';  # should be either bwa64 or bwaMAC (based on your system architecture)
use constant PROG_DIR => '/data/cephfs/punim0256/MGP_ComEnc_011119/bin/dqc/';      # should be the location of the PROG_NAME file (use './' if in the same location at the perl script)

 #database name used for display and used as input for -dbs and -dbs_retai
use constant DBS => {
		      mm1 => {name => 'mm1',
                              db => 'mm1'},
			 mm2 => {name => 'mm2',
                              db => 'mm2'},
			 mm3 => {name => 'mm3',
                              db => 'mm3'},

			 mm6 => {name => 'mm6',
                              db => 'mm6'},
                         mm5 => {name => 'mm5',
                              db => 'mm5'},
			 mm4 => {name => 'mm4',
                              db => 'mm4'}};


use constant DB_DEFAULT => 'human';

#######################################################################

use base qw(Exporter);

use vars qw(@EXPORT);

@EXPORT = qw(
             DEBUG
             PRINT_STUFF
             VERSION
             VERSION_INFO
             ALPHABET
             PROG_NAME
             PROG_DIR
             DB_DIR
             TMP_DIR
             OUTPUT_DIR
             DBS
             DB_DEFAULT
             );

1;
