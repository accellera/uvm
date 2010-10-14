-mfcu
-f ../common/oc_ethernet_rtl/rtl_file_list2.lst
+acc=rmb
+incdir+../../../src 
timescale.v
../../../src/uvm_pkg.sv 
+define+SINGLE_RAM_VARIABLE+RAM128x64
+incdir+../common/wishbone
+incdir+../common/oc_ethernet_rtl
-suppress 2218,2181
tb_top.sv
tb_env.sv
