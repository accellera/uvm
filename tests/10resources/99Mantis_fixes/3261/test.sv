module test;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
 
  int value;
  int failed=0;

  typedef uvm_resource_db#(int) int_rsrc;

  class test extends uvm_component;
    `uvm_new_func
    `uvm_component_utils(test)

    task run;
      int_rsrc::set("m", "value", 55);
    
      int_rsrc::read_by_name("at_end_m", "value", value);
      if(value == 55) begin
        $display("*** UVM TEST FAILED : got at_end_m for m ***");
        failed = 1;
      end

      value = 0;
      int_rsrc::read_by_name("m_begin", "value", value);
      if(value == 55) begin
        $display("*** UVM TEST FAILED : got m_begin for m ***");
        failed = 1;
      end
      if(!failed) $display("*** UVM TEST PASSED ***");
      global_stop_request();
    endtask
  endclass

  initial begin
    run_test();
  end
endmodule
