module test;
  import uvm_pkg::*;
 
  int achoo;
 
  class test extends uvm_component;
    `uvm_new_func
    `uvm_component_utils(test)

    task run;
      set_config_int("a*","a*",10);
      uvm_top.get_config_int("achoo", achoo);
      $display("achoo: %0d", achoo);
      if(achoo != 10) $display("*** UVM TEST FAILED ***");
      else $display("*** UVM TEST PASSED ***");
      global_stop_request();
    endtask
  endclass

  initial run_test();
endmodule
