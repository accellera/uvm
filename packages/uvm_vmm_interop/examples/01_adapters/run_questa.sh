#!/bin/sh

if [ -z "$1" ] ; then
LIST=*.sv
else
LIST=$1
fi

if [ "$1" = clean ] ; then
  rm -rf *.log *.log.filtered *.wlf work transcript* *.diff sc_dpi*.h; exit
fi

# internal use only
check () {
  if [ -n "$INTEROP_REGRESS" ] ; then
    perl ../regress/regress_passfail.pl $TOP_LEVEL.log 01_adapters ../results.log
  fi
}

#---------------------------------------------------------------------------

${INTEROP_HOME:=../..}
${VMM_DPI_DIR=$VMM_HOME/shared/lib/linux_x86_64}

VLOG_ARGS="-novopt -mfcu -sv \
           +incdir+$OVM_HOME/src \
           +incdir+$VMM_HOME/sv \
           +incdir+$INTEROP_HOME/src \
           +incdir+../src" 

vlib work

for EXAMPLE in $LIST; do

  TOP_LEVEL=`echo example_$EXAMPLE | sed -e "s/.sv//"`

  vlog $VLOG_ARGS $EXAMPLE | tee $TOP_LEVEL.log
  if [ $? -eq 0 ]
  then
  vsim -novopt -sv_lib $VMM_DPI_DIR/vmm_str_dpi -c -do "run -all; quit" $TOP_LEVEL -l $TOP_LEVEL.log
  fi
  
  check

done

