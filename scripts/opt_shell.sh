## Shell for adding total file sizes to the optimisation text files 

grep -m 1 'cd' $1 | sed 's/execution$/inputs/' | \
             sed 's/^cd //' | \
             xargs -I{} du -shL {} | \
             cut -f 1 | xargs -I{} mv $3/$2.txt $3/$2.{}.txt;

# echo "$2 renaming finished"
