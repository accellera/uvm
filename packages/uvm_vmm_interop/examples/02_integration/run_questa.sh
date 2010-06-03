#!/bin/sh

if [ -z $1 ] ; then
LIST=*.sv
else
LIST=$1
fi

if [ "$1" = clean ] ; then
  rm -rf *.log ref/*.log.filtered *.log.filtered *.wlf transcript* *.diff work sc_dpi*.h; exit
fi

# for internal use only
check () {
  if [ -n "$INTEROP_REGRESS" ] ; then
    if [ $EXAMPLE != "05_mixed_hierarchy.sv" ] ; then
      perl ../regress/regress_compare_gold.pl ref/$TOP_LEVEL.log $TOP_LEVEL.log 02_integration " " ../results.log
    else
      perl ../regress/regress_passfail.pl $TOP_LEVEL.log 02_integration ../results.log
    fi
  fi
}

#---------------------------------------------------------------------------

${INTEROP_HOME:=../..}
${VMM_DPI_DIR=$VMM_HOME/shared/lib/linux_x86_64}

VLOG_ARGS="-mfcu -sv \
           +incdir+$OVM_HOME/src \
           +incdir+$VMM_HOME/sv \
           +incdir+$INTEROP_HOME/src \
           +incdir+../src \
           +incdir+../src/hfpb \
           +incdir+../src/hfpb_components"

vlib work

for EXAMPLE in $LIST; do 

  if [ $EXAMPLE != "04_IP_integration.sv" ] ; then

    TOP_LEVEL=`echo example_$EXAMPLE | sed -e "s/.sv//"`

    vlog $VLOG_ARGS $EXAMPLE | tee  $TOP_LEVEL.log
    if [ $? -eq 0 ]
    then
    vsim -sv_lib $VMM_DPI_DIR/vmm_str_dpi -c -do "run -all; quit" $TOP_LEVEL -l $TOP_LEVEL.log
    fi 
    check


  ## FOR RUNNING THE 04_IP_INTEGRATION EXAMPLE ONLY
  else

    TOP_LEVEL=example_04_IP_integration

    vlog $VLOG_ARGS +define+VMM_ON_TOP 04_IP_integration.sv | tee $TOP_LEVEL.vmm.log
    if [ $? -eq 0 ]
    then
    vsim -sv_lib $VMM_DPI_DIR/vmm_str_dpi -c -do "run -all; quit" example_04_IP_integration -l $TOP_LEVEL.vmm.log
    fi
  
    if [ -n "$INTEROP_REGRESS" ] ; then
      perl ../regress/regress_compare_gold.pl ref/$TOP_LEVEL.vmm.log $TOP_LEVEL.vmm.log 02_integration " " ../results.log
    fi

    vlog $VLOG_ARGS +define+OVM_ON_TOP 04_IP_integration.sv | tee $TOP_LEVEL.ovm.log
    if [ $? -eq 0 ]
    then
    vsim -sv_lib $VMM_DPI_DIR/vmm_str_dpi -c -do "run -all; quit" example_04_IP_integration -l $TOP_LEVEL.ovm.log
    fi
  
    if [ -n "$INTEROP_REGRESS" ] ; then
      perl ../regress/regress_compare_gold.pl ref/$TOP_LEVEL.ovm.log $TOP_LEVEL.ovm.log 02_integration " " ../results.log
    fi

  fi

done


