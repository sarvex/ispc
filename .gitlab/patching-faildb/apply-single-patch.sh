#!/bin/bash -xe
file_to_patch=$1
patch_file=$2

tmp_file=$file_to_patch.tmp
tmp_patch_file=$patch_file.tmp

# remove all non-ASCII characters for grep
sed 's/[^[:print:]]//g' $patch_file > $tmp_patch_file

cp $file_to_patch $tmp_file

#find lines to remove
echo "" > lines_to_remove.tmp
cat $tmp_patch_file | grep "^-\." | cut -c2- >> lines_to_remove.tmp

awk 'NR==FNR{a[$0];next} !($0 in a)' lines_to_remove.tmp $file_to_patch > $tmp_file

#add new line to output file
echo "" >> $tmp_file

#add lines
cat $tmp_patch_file | grep "^+\." | cut -c2- >> $tmp_file

mv $tmp_file $file_to_patch

#cleanup
rm $tmp_patch_file lines_to_remove.tmp
