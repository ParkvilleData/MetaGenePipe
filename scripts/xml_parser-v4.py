import xml.etree.ElementTree as ET
import sys
import re
import argparse
import pandas as pd
import pickle

parser = argparse.ArgumentParser()
parser.add_argument('lineage', help="The taxonomic lineage file.")
parser.add_argument('xmls', help="The XML files to search for the hits.",  nargs='+')
parser.add_argument('--outfile', help="The name of the output file. Default: OTU.tsv", default="OTU.tsv")

args = parser.parse_args()

#import pdb; pdb.set_trace()

with open(args.lineage, 'rb') as f:
    tax = pickle.load(f)

df = pd.DataFrame()

sample_names = []
for xml in args.xmls:
	sample_name = xml.split("/")[-1].split(".")[0]
	sample_names.append(sample_name)

	root = ET.parse(xml).getroot()
	for hit in root.findall("./BlastOutput_iterations/Iteration/Iteration_hits/Hit"):
		hit_text = hit.find("Hit_id").text
		code = hit_text.split(":")[0]
		df = df.append( {'code':code, "sample_name":sample_name}, ignore_index=True)

print(f"Writing to {args.outfile}")
with open(args.outfile, "w") as f:
	columns = ["Name", "Kegg Code", "Lineage"] + sample_names
	print("\t".join(columns), file=f)

	codes = sorted(df.code.unique())

	for code in codes:
		if code in tax.keys():
			lineage = tax[code]
			name = lineage.split(";")[-1]
			name = name[ len(code)+2:].strip()
		else:
			lineage = "unknown"
			name = "Unknown"

		f.write( "\t".join( [name, code, lineage] )  )
		for sample_name in sample_names:
			filtered = df[ (df.sample_name == sample_name) & (df.code == code) ]
			count = len(filtered.index)
			f.write( f"\t{count}" )

		f.write("\n")
