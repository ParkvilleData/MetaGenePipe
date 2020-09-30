#!/usr/bin/env perl
#
# inputMaker,pl
# this file will create a perfectly valid inputBAM/FASTQ.txt file for input into the GATK pipeline
# run: perl inputMaker.pl in the directory with the fastq or bam files
#
#
#


=head1 NAME

   ## inputMaker.pl

=head1 SYNOPSIS

         Version 1.0
         Example command
         perl inputMaker.pl -f bam -o outputfilename.txt

         Defaults:
	 None

=head1 DESCRIPTION

Script to convert a bam and bed file to input for centipede

=cut

use strict;
use Getopt::Long;
use Getopt::Std;
use Pod::Usage;
use Data::Dumper;
use POSIX;
use Cwd;
use Fcntl;

#global variables
my $format; my $help; my $files; my $output;


#help
&Getopt::Long::Configure( 'pass_through', 'no_autoabbrev');
GetOptions('format|f=s' => \$format,
           'help|?|h' => \$help,
	   'output|o=s' => \$output,
)or die("Error in command line arguments\n");;

#display help
pod2usage(1) if $help;
if(!defined($format)){ print "Please choose the file format for the files you wish to process. i.e. bam, fastq"; }
if(!defined($output)){ print "Please choose a name for the output file you wish to write to\n";}

#get the files for that format 
my $dir = getcwd;
my @files = glob "$dir/*.$format";

open(my $fh, ">", $output) or die "Can't open $output for writing\n";

my $array_size = scalar(@files);
for (my $count=0; $count <= $array_size; $count++) {
	if($count % 2 == 0){
		my @split = split('_', $files[$count]);
		print $fh @split[2]."\t".@files[$count]."\t".@files[$count+1];
	}else{
		if($count < $array_size-1) {
			print $fh "\n";
		}
	}
}

close $fh;
