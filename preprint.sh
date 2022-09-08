# https://gist.github.com/maxogden/97190db73ac19fc6c1d9beee1a6e4fc8
pandoc --citeproc --bibliography=./docs/refs.bib --variable papersize=a4paper -s paper.md -o preprint.pdf
