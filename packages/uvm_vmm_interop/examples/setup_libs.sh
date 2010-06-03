#!/bin/sh 

VMM_HOME=`pwd`/../../../vmm
OVM_HOME=`pwd`/../../../ovm
INTEROP_HOME=`pwd`/../../ovm_vmm_interop

export VMM_HOME
VMM_DIR="+incdir+$VMM_HOME/sv"
#VMM_DIR="-ntb_opts rvm"
export VMM_DIR
export OVM_HOME
export INTEROP_HOME
