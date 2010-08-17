#!/bin/sh 

VMM_HOME=`pwd`/../../../../vmm
UVM_HOME=`pwd`/../../../../uvm/distrib
INTEROP_HOME=`pwd`/../../uvm_vmm_interop/src
#INTEROP_HOME=${VMM_HOME}/sv/uvm_vmm_interop/src

export VMM_HOME
export UVM_HOME
export INTEROP_HOME

VMM_DIR="+incdir+$VMM_HOME/sv"
UVM_DIR="+incdir+$UVM_HOME/src"
INTEROP_DIR="+incdir+$INTEROP_HOME" 
#INTEROP_DIR="+incdir+$INTEROP_HOME/src"
#VMM_DIR="-ntb_opts rvm"
#UVM_DIR="-ntb_opts uvm"
export VMM_DIR
export UVM_DIR
export INTEROP_DIR
