-sv
-timescale "1ns/1ns"
-mfcu
-suppress 2218,2181
//+define+UVM_NO_BACKDOOR_DPI
+incdir+../../../src 
../../../src/uvm_pkg.sv 
+incdir+../common/apb
tb_top.sv
test.sv
