#!/usr/local/bin/perl
#use strict;
#use warnings;
# Script to caputre resource usage output
# Takes in run_times.txt or a file that finds
# txt files that are output from /usr/bin/time -v
# which is run for every task
# It then parses the HPGAP-workflow-main.json file to
# make comparisons
#
use Data::Dumper;
use Cwd;
use File::Find;

my $json_file = shift;
my @taskArray;
my $dir = getcwd;
my @fileArray;

#finds optimisation files
find(\&do_something_with_file, $dir);

sub do_something_with_file
{
        if($_ =~ /txt/ && $_ =~ /cromwell_/) {
                push(@fileArray, $File::Find::name);
        }
}

 	#open json file into file handle for search
        my @file_resource_array;
        open(my $json, "<", $json_file) or die "Could not open file $!";
        while(<$json>){
                if( $_ =~ /$search_name/ ) {
                        push(@file_resource_array, $_);
                }
        }

#print header
print "Task Name\tTime Requested\tTime Used\t CPU Requested\t CPU Used \t Memory Requested\t Memory (Gb)\n";

foreach(@fileArray)  {   
	my $time;
	my $cpu;
	my $mem;

	#iterates through list of files extracts the task name
	$line = $_;
	chomp($line);
	#print $line."\n";
 	@taskArray = split('/', $line);	
	my $arrayLength = @taskArray;
	$array_position = int($arrayLength) - 2;

	my $name = @taskArray[$array_position];
	if($name =~ /shard/){
		$array_position = $array_position - 1;
		$name = @taskArray[$array_position];
	}

	#clean up the call name to match json exactly
	my $search_name = $name;
	$search_name =~ s/call-//g;

	#open json file into file handle for search
	#Search the json file only for the mem/threads/minutes settings
	#Place thise settings into a hash
	my %runtime_hash;
        foreach(@file_resource_array){
                if( $_ =~ /$search_name/ && $_ =~/minutes/ && $_ !~ /RG/ || $_ =~ /$search_name/ && $_ =~ /threads/ && $_ !~ /RG/ || $_ =~ /$search_name/ && $_ =~/mem/ && $_ !~ /RG/ ) {
			my @run_string = split(/_/, $_);
			my $lastPos = int(@run_string)-1 ;
			my $lastAttribute = $run_string[$lastPos];
			my @attributes = split(/:/, $lastAttribute);
			my ($attribute, $attribValue) =  ($attributes[0], $attributes[1]);
		
			$attribute =~ s/"//g;
			$attribValue =~ s/,|\n|\s//g;
			$runtime_hash{$attribute} = $attribValue;
                }
        }

	#iterates through each file and extracts optimisation info
	open(my $fh, "<", $line) or die "Could not open file $!";
	while (my $row = <$fh>) {
 	 chomp $row;
	    #get time
  	    if($row =~ /Elapsed/){
		my @rowSplit = split('\):', $row);
		$time = $rowSplit[1];
	    }
	    #get cpu
	    if($row =~ /Percent/) {
		my @rowSplit = split(':', $row);
                $cpu = $rowSplit[1];
	    }
	    #get mem
	    if($row =~ /Maximum/){
                my @rowSplit = split(':', $row);
                $mem = int($rowSplit[1])/1000/1000;
            }

	}
	#set runtime variables
	my $min = $runtime_hash{"minutes"};
	my $threads = $runtime_hash{"threads"};
	my $memory = $runtime_hash{"mem"};
		
	print "$search_name\t$min\t$time\t$threads\t$cpu\t$memory\t$mem\n";
}

