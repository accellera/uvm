#!/bin/sh
#
# assumes we are in base-dir and state is clean 
#
commit=$1
tool=$2

rm -fr *.patch
git checkout $commit^
git reset --hard

# clean the tree
git clean -dfx distrib tests

git format-patch $commit^..$commit


# now get the test and run it
files=`diffstat *.patch -l | egrep ^tests | xargs -I '{}' dirname '{}' | sort | uniq` 
git apply --include tests/\* *.patch --apply 
echo "applicable tests are: $files"

# run it - should fail
admin/bin/run_tests $tool $files

# now get the patch
git apply *.patch --exclude tests/\* --apply

# run it - should pass
admin/bin/run_tests $tool $files

