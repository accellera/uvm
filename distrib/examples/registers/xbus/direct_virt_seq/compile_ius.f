-uvm
-uvmhome ../../../..
-uvmnoautocompile
../../../../src/uvm_pkg.sv


+incdir+../../../xbus/sv
+incdir+../../../xbus/examples
+incdir+../common
+incdir+../common/reg_defn
+incdir+../common/sequences
+define+XA0_TOP_PATH=xbus_reg_tb_top.dut

../common/xbus_top.sv 

// the VPI part for the backdoor
../../../../../distrib/src/C/uvm_hdl.c
-DNCSIM


