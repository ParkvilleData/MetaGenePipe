import sys
import glob
import os
import argparse
import fnmatch

def main():
	parser = argparse.ArgumentParser()
	parser.add_argument('-d', '--directory', type=str, required=True,
			help='The directory containing megahit contig fasta files')
	parser.add_argument('-s', '--sampleName', type=str,  help='Sample name for output')
	args = parser.parse_args()
	
	os.chdir(args.directory)
	#print(args.directory)
	files = glob.glob("k*[0-9].contigs.fa")
	#print(files)
	files.sort(key=lambda f: os.stat(f).st_size, reverse=False)

	for f in (files):
		#print(f)
		kmerSplit = f.split(".")[0]
		old_file_name = f
		new_file_name =  args.sampleName + ".contigs." + kmerSplit + ".fa"
		os.rename(f, new_file_name)

	#redo glob after file rename
	files = glob.glob("*.contigs.*.fa")

	#find largest file size
	for file in (files):
		#print(file + " " + str(os.stat(file).st_size))
		size=os.stat(file).st_size
		if(os.stat(file).st_size != 0):
			#print(file + " " + str(os.stat(file).st_size))
			kmer = file.split(".")[2].replace("k", "")
			fastg =  args.sampleName + '.' + kmer + '.fastg'
			fastg.replace(".contigs", "").replace(".final", "")
			os.system('megahit_core contig2fastg ' + kmer + ' ' + file + ' > ' + fastg)
			print(kmer)
			break

###### Main call ##########
if __name__ == "__main__":
     main()
