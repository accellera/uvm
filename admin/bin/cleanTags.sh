#!/bin/bash
upstream="sf"
tags=`git tag -l \*RC\* \*TEST\* \*temp\* \*MERGE\*`
for t in $tags; do
git push --delete $upstream refs/tags/$t
git tag -d $t
done
