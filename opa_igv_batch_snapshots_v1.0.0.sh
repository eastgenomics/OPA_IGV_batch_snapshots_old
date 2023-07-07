#!/bin/bash

# remove ,,, lines, replace space in last field with a comma, and replace commas with tabs
sed '/,,,/d; s/\s\+/,/g; s/,/\t/g' OPA_GeneList.csv > OPA_GeneList.bed

for FILE in SP-*/*.bam
do
    basename=$(basename $FILE .bam)
# begtoIgv takes bed file and outputs generic IGV batch file
    bedToIgv -path ./snapshots/$basename -slop 100 -i OPA_GeneList.bed > ${basename}_OPA_GeneList.batch
# include batch command lines to IGV batch file in the beginning and end of the file
# can also do the batch_beginning step as a separate file, whatever is easier for the scientists and depending on how often it needs to be changed
    batch_beginning="new\ngenome hg19\nload $FILE\nsort position\nsquish\ncolorBy READ_STRAND\ngroup PAIR_ORIENTATION"
    echo "$(echo -e $batch_beginning | cat - ${basename}_OPA_GeneList.batch)" > ${basename}_OPA_IGV.batch
    echo "exit" >> ${basename}_OPA_IGV.batch
# run IGV batch script
    sh igv_batch.sh -b ${basename}_OPA_IGV.batch
# remove temporary file that has been appended to in {basename}_OPA_IGV.batch
    rm ${basename}_OPA_GeneList.batch
done