-sverilog +acc +vpi
timescale.v
+incdir+../../../src 
../../../src/uvm_pkg.sv 
+define+SINGLE_RAM_VARIABLE
+incdir+../common/wishbone
+incdir+../common/oc_ethernet_rtl
-F ../common/oc_ethernet_rtl/rtl_file_list.lst
tb_top.sv
tb_env.sv
+verilog1995ext+.v
../../../lib/libuvm_vcs.so
