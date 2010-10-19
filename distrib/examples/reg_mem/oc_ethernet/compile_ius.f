-uvm
-uvmhome ../../..
-uvmnoautocompile
../../../src/uvm_pkg.sv

timescale.v
-define SINGLE_RAM_VARIABLE=RAM128x64
-incdir ../common/wishbone
-incdir ../common/oc_ethernet_rtl
-F ../common/oc_ethernet_rtl/rtl_file_list.lst
tb_top.sv
tb_env.sv
