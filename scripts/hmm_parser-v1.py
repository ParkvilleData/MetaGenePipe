#!/usr/bin/env python

from collections import defaultdict
import pandas as pd
import numpy as np
import sys
import pprint
from Bio import SearchIO
import argparse

def hmmer_to_df(hmmTbl, only_top_hit=False):
	""" 
	Takes a table from HMMER 3 and converts it to a Pandas Dataframe

	Adapted from https://stackoverflow.com/a/62021471 
	"""
	attribs = [ 'id', 'evalue'] # can add in more columns
	hits = defaultdict(list)
	prev_hit_id = None
	## open hmmTbl and extract hits
	with open(hmmTbl) as handle:
		for queryresult in SearchIO.parse(handle, 'hmmer3-tab'):
			for hit in queryresult.hits:
				# Only record the top hit
				if only_top_hit and hit.id == prev_hit_id:
					continue

				for attrib in attribs:
					hits[attrib].append(getattr(hit, attrib))
			
				hits['KO'].append(queryresult.id)
				prev_hit_id = hit.id

	return pd.DataFrame.from_dict(hits)


def main():
	parser = argparse.ArgumentParser()      
	parser.add_argument('brite', type=argparse.FileType('r'), help="The brite hierachy level file.")
	parser.add_argument('hmm_tbls', nargs='+', help='A list of tables from HMMER 3.')
	parser.add_argument('--consistent-pathways', action='store_true', help='Outputs all the pathways consistently across each output file even if they do not exist at that level.')
	parser.add_argument('--outprefix', help="The samplename prefix")

	args = parser.parse_args()

	levels = ["Level1", "Level2", "Level3"]

	# load brite database
	brite_df = pd.read_csv(args.brite, sep='\t')

	# Loop over the HMMER tables
	counts_df = []
	for hmm_tbl in args.hmm_tbls:
		hmmer_df = hmmer_to_df( hmm_tbl, only_top_hit=False )

		# Select ids for rows with minimum e value
		idx_evalue_min = hmmer_df.groupby('id')['evalue'].idxmin()

		# Filter hmmer dataframe with these indexes
		hmmer_min_e_df = hmmer_df.loc[idx_evalue_min]
		brite_filtered = brite_df[brite_df['KO'].isin(hmmer_min_e_df.KO)]

		for level in levels:
			my_counts_df = brite_filtered[level].value_counts().rename_axis('pathway').reset_index(name='counts')
			my_counts_df['level'] = level
			my_counts_df['hmm_tbl'] = hmm_tbl

			# Store in single dataframe
			counts_df = my_counts_df if len(counts_df)  == 0 else pd.concat( [counts_df, my_counts_df ], ignore_index=True)

	# Output the counts into text files
	for level in levels:
		output_filepath = f"{level}.{args.outprefix}.counts.tsv"

		print(f"Writing to file {output_filepath}")
		with open(output_filepath, 'w') as f:
			# Get pathways for this level so that we can have consistency in the output files even when the counts are zero

			df_for_pathways = counts_df if args.consistent_pathways else counts_df[ counts_df.level == level ]
			pathways_for_level = sorted(df_for_pathways.pathway.unique())

			headers = ["Pathway"] + args.hmm_tbls
			f.write( "\t".join(headers) )
			f.write( "\n" )

			for pathway in pathways_for_level:
				f.write(f"{pathway}")

				for hmm_tbl in args.hmm_tbls:
						filtered = counts_df[ (counts_df.pathway == pathway) & (counts_df.level == level) & (counts_df.hmm_tbl == hmm_tbl) ]
						count = filtered.counts.sum()
						f.write( f"\t{count}" )
				f.write( "\n" )


if __name__ == "__main__":
	main()

