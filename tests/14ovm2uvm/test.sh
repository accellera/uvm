#!/bin/sh

rm -fr some_ve *.patch *.tar.gz *.diff
cp -fr ovm_sources  some_ve


../../distrib/bin/ovm2uvm.pl --top_dir ./some_ve --marker "XX-REVIEW-XX" --write --backup --all_text_files

diff some_ve uvm_sources.golden > test.diff

