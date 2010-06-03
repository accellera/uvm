#!/bin/sh

# Optional clean arg ($1) passed to sub-run_questas.

pushd ./01_adapters;      ./run_questa.sh $1; popd
pushd ./02_integration;   ./run_questa.sh $1; popd
#pushd ./03_vmm_env_reuse; ./run_questa.sh $1; popd

if [ "$1" = clean ] ; then
  rm -rf *.log *.log.filtered *.wlf transcript* work; exit
fi


