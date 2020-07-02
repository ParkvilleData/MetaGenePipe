#!/bin/bash

display_usage() { 
	echo "This script downloads ENA read files from the Verbruggen MediaFluxi project. Assumes MediaFlux config file at ~/.Arcitecta/mflux.cfg" 
	echo -e "\nUsage: $0 [PROJECT_ACCESSION_ID]...\n" 
	} 

if [  $# -le 0 ] ; then
	display_usage
	exit 1
fi 
 
if [[ ( $# == "--help") ||  $# == "-h" ]] ; then 
	display_usage
	exit 0
fi 


module load unimelb-mf-clients
for PROJECT in $@; do
	unimelb-mf-download --mf.config ~/.Arcitecta/mflux.cfg --csum-check --out . /projects/proj-6300_metagenomics_repository_verbruggenmdap-1128.4.294/Data/$PROJECT
done
