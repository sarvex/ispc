#!/bin/bash -xe
patches_dir=`realpath $1`

patch_script=`dirname "$(readlink -f "$0")"`/apply-single-patch.sh
for patch_file in $patches_dir/*.diff ;
do
    file_to_patch_org=`sed 's/[^[:print:]]//g' $patch_file | grep "^---" | cut -d" " -f2 | sed 's/^.\{2\}//'`
    if [ -z "$file_to_patch_org" ]
    then
        echo "Nothing to patch with $patch_file, skipping..."
        continue
    fi

    file_to_patch_org=`realpath $file_to_patch_org`
    echo "Patching file $file_to_patch_org with patch $patch_file"

    # extract starting comment block
    cat $file_to_patch_org | grep "%" > comment.block.tmp

    # disable early exit just for this line
    # it's needed in case of empty fail_db.txt file
    set +e
    # extract non comment lines
    cat $file_to_patch_org | sed 's/[^[:print:]]//g' | grep -v "%" > file.to.patch.tmp
    set -e

    file_to_patch=`realpath file.to.patch.tmp`

    $patch_script $file_to_patch $patch_file

    cat comment.block.tmp > $file_to_patch_org

    # sort lines and put to org file
    cat $file_to_patch | sort -u -k 6 -k 4 -k 5 -k 10 -k 1 | sed '/^$/d' >> $file_to_patch_org

    # cleanup
    rm comment.block.tmp file.to.patch.tmp
done
