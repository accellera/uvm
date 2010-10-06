-mfcu
-timescale "1ns/1ns"
+acc=rmb
-suppress 2218,2181
+incdir+../../../../src 
+incdir+../../../xbus/sv
+incdir+../common
+incdir+../common/reg_defn
+incdir+../common/sequences
../../../../src/uvm_pkg.sv 
../../../xbus/sv/xbus.svh
../common/reg_defn/ral_xa0.sv
../common/xbus_top.sv
../common/xbus_test.sv
+define+XA0_TOP_PATH=xbus_ral_tb_top.dut
