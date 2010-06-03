#!/bin/sh

# Set default value of interop home
if [ -z "$INTEROP_HOME" ] ; then
INTEROP_HOME=../..
fi

if [ -z "$VMM_DPI_DIR" ] ; then
VMM_DPI_DIR=$VMM_HOME/shared/lib/linux_x86_64
fi

if [ "$1" = clean ] ; then
 \rm -rf *.log *.log.filtered simv* csrc* .vcs* *.vpd DVE* *.vdb vc_hdrs.h; exit
fi


VLOG_ARGS=" +warn=noUNK_COMP_ARG +warn=noSV-LCM-PPWI -R \
           +vmm_log_default=trace  -timescale=100ns/100ns \
           -V -sverilog +plusarg_save \
           +define+VMM_UVM_INTEROP \
           +define+VMM_PARAM_CHANNEL \
           +define+VMM_LOG_FORMAT_FILE_LINE \
           +incdir+$UVM_HOME/src \
           $VMM_DIR \
           +incdir+$INTEROP_HOME/src \
           +incdir+../src \
           +incdir+../src/hfpb \
           +incdir+../src/hfpb_components"

for EXAMPLE in *.sv; do 

  TOP_LEVEL=`echo example_$EXAMPLE | sed -e "s/.sv//"`
  rm -rf simv* csrc* 
  vcs +define+VMM_ON_TOP -cm_dir $EXAMPLE $VLOG_ARGS `pwd`/$EXAMPLE -l $TOP_LEVEL.vmm.log 

  rm -rf simv* csrc* 
  vcs +define+UVM_ON_TOP -cm_dir $EXAMPLE $VLOG_ARGS `pwd`/$EXAMPLE -l $TOP_LEVEL.uvm.log 

  if [ -n "$INTEROP_REGRESS" ] ; then
    perl ../regress/regress_passfail.pl $TOP_LEVEL.log 01_adapters ../results.log
  fi

done

