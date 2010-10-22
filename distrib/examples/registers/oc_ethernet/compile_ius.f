-uvm
-uvmhome ../../..
-uvmnoautocompile
../../../src/uvm_pkg.sv

timescale.v
+define+SINGLE_RAM_VARIABLE+RAM128x64

-incdir ../common/wishbone
-incdir ../common/oc_ethernet_rtl
-F ../common/oc_ethernet_rtl/rtl_file_list.lst
tb_top.sv
tb_env.sv
//-linedebug -gui

// NOTE using the backdoor API requires R(ead) and potentially W(rite) access to the hdl signals used
// 
// to enable it use one of the following strategies 
// 1. -linedebug (enables full access to ALL values)
// 2. -access +rw (enables full access to ALL values)
// 3a. use "-genafile <accessfile>" for a simulation the generate a specific access file
// 3b. use "-afile <accessfile>" to enable only access to the recorded objects 
-access +rw


// the VPI part for the backdoor
../../../../distrib/src/C/uvm_hdl.c
-DNCSIM

