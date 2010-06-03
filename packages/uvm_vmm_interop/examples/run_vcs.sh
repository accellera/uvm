#!/bin/sh

# Optional clean arg ($1) passed to sub-run_vcs.

. setup_libs.sh 

pushd ./01_adapters;      ./run_vcs.sh $1; popd
pushd ./02_integration;   ./run_vcs.sh $1; popd
#pushd ./03_vmm_env_reuse; ./run_vcs.sh $1; popd

if [ "$1" = clean ] ; then
  \rm -rf *.log *.log.filtered simv* csrc* .vcs* *.vpd DVE* *.vdb *.restart*; exit
fi


