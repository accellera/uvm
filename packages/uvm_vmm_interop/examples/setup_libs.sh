#!/bin/sh 

VMM_HOME=`pwd`/../../../../vmm
UVM_HOME=`pwd`/../../../../uvm/distrib
INTEROP_HOME=`pwd`/../../uvm_vmm_interop

export VMM_HOME
VMM_DIR="+incdir+$VMM_HOME/sv"
#VMM_DIR="-ntb_opts rvm"
export VMM_DIR
export UVM_HOME
export INTEROP_HOME
