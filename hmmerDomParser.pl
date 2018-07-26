#!/usr/bin/perl  -I/vlsci/SG0009/bshaban/perl/
#/vlsci/SG0009/bshaban/perl/Bio/FastParsers/Hmmer/DomTable.pm
###############################################################3
##
## 17/07/2018
## hammerParser.pl: Parses hammer output from metagenomics pipeline
## to produce an annotation table
## The annotation table will be used as the basis for the gene count
##
## input: gff and pfam for each hmmer alignment
##
#################################################################

=head1 NAME

   ## hmmerParser.pl

=head1 SYNOPSIS

         Version 1.0
         Example command
         perl hmmerDomParser.pl -domtbl asslember.domtbl.tigrfam -gff assembler.gff -o annotation.txt

         Defaults:
         None

=head1 DESCRIPTION

Takes output from metagenomics pipeline and creates an output table

=cut

use strict;
use Getopt::Long;
use Getopt::Std;
use Pod::Usage;
use Data::Dumper;
use POSIX;
use Cwd;
use Fcntl;
use Bio::SearchIO;
use Bio::SeqIO;
use Bio::FastParsers::Hmmer::DomTable;

#global variables
my $format; my $help; my $gff; my $domtbl; my $output; my $domhandle;


#help
&Getopt::Long::Configure( 'pass_through', 'no_autoabbrev');
GetOptions('gff|g=s' => \$gff,
           'help|?|h' => \$help,
           'output|o=s' => \$output,
	   'domtbl|d=s' => \$domtbl,
)or die("Error in command line arguments\n");;

if(!defined($gff)){ die "Please add a gff file\n"; }
if(!defined($domtbl)) { die "Please name a domtbl  file\n"; }
if(!defined($output)) { die "Please name an output file\n"; }

#display help
pod2usage(1) if $help;

#call main subroutine
&main;

sub main {

	#open alignment output

	#open output for writing
	open(my $fh, ">", $output) or die "CAn't open $output for writing\n";
	print $fh "Query Name\tTarget Name\tAccession\tEvalue\tDescription of target\n";

		# open and parse HMMER domain report in tabular format
		my $infile = $domtbl;
		my $report = Bio::FastParsers::Hmmer::DomTable->new( file => $infile );
 
		# loop through hits
		while (my $hit = $report->next_hit) {
    			my ($query_name, $target_name, $accession, $evalue, $description) = ($hit->query_name, $hit->target_name, $hit->target_accession, $hit->evalue, $hit->target_description);
			print $fh "$query_name\t$target_name\t$accession\t$evalue\t$description\n";
		}
	close ($fh);
}
