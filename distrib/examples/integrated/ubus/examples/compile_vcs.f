#usage: vcs -file compile_vcs.f 

-sverilog -timescale=1ns/1ns
+incdir+../sv
+incdir+../../../src
../../../src/uvm_pkg.sv
ubus_tb_top.sv
+acc +vpi ../../../src/dpi/uvm_dpi.cc -cflags -DVCS
