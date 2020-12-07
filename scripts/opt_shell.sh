## Shell for creating the optmisation sizes 

grep -m 1 'cd' $1 | sed 's/execution$/inputs/' | \
             sed 's/^cd //' | \
             xargs -I{} du -shL {} | \
             cut -f 1 | xargs -I{} mv $3/optimisation/$2.txt $3/optimisation/$2.{}.txt;

echo "$2 renaming finished"

