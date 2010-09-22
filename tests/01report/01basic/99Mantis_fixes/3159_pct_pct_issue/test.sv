module test;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  class test extends uvm_test;
    `uvm_new_func
    `uvm_component_utils(test)

    task run;
      `uvm_info("SinglePercent", "This is a message with a single % sign in it", UVM_NONE)
      `uvm_info("PercentPercent", "This is a message with a %% in it", UVM_NONE)
      $display("*** UVM TEST PASSED ***");
      global_stop_request();
    endtask

  endclass

  initial run_test();
endmodule

