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
         perl inputMaker.pl -f bam -o outputfilename.txt -i 1

         Defaults:
	 None
	
	 options
	 -f: File format i.e. fastq, bam
	 -o: Name of output file.
      	 -i: Id location. position of the id. Position is defined by position between '_' i.e. 1_2_3.fastq or ID19091_trimmed_temp.fastq. ID is position 1.
	 -h: This help

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
use File::Basename;

#global variables
my $format; my $help; my $files; my $output; my $id_location;

#help
&Getopt::Long::Configure( 'pass_through', 'no_autoabbrev');
GetOptions('format|f=s' => \$format,
           'help|?|h' => \$help,
	   'output|o=s' => \$output,
	   'id|i=s' => \$id_location,
)or die("Error in command line arguments\n");;

#display help
pod2usage(1) if $help;

if(!defined($format)) { die "Please enter a format i.e. fastq, bam etc\n";}
if(!defined($output)) { die "Please enter an output text file\n";}
if(!defined($id_location)) { die "Enter the position of the id. position is defined by position between '_' i.e. 1_2_3.fastq or ID19091_trimmed_temp.fastq. ID is position 1\n"; }

#get the files for that format 
my $dir = getcwd;
my @files = glob "$dir/*.$format";

open(my $fh, ">", $output) or die "CAn't open $output for writing\n";
my $id = int($id_location) - 1;

my $array_size = scalar(@files);
for (my $count=0; $count <= $array_size; $count++) {
	if($count % 2 == 0){
		my @split = split('_', $files[$count]);
		print $fh basename(@split[$id])."\t".@files[$count]."\t".@files[$count+1]."\n";
	}
}
close $fh;
