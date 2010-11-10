module test;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  class mycomp extends uvm_component;
    int build_val=0;
    int run_val=0;
 
    `uvm_new_func
    `uvm_component_utils(mycomp)

    function void build();
      super.build();
//      get_config_int("value", build_val);
      $display("full name = %s", get_full_name());
      uvm_resource_db#(int)::read_by_name("value", get_full_name(), build_val, this);
    endfunction
    task run;
//      #2 get_config_int("value", run_val);
      #2;
      uvm_resource_db#(int)::read_by_name("value", get_full_name(), run_val, this);
    endtask
  endclass
 
  class test extends uvm_component;
    mycomp mc;
    function new(string name, uvm_component parent);
      super.new(name,parent);
    endfunction
    `uvm_component_utils(test)

    function void build();
      super.build();
      uvm_resource_db#(int)::write_and_set("value", { get_full_name(), ".mc"}, 22, this);
      uvm_resource_db#(int)::write_by_name("value", { get_full_name(), ".mc"}, 33, this);
//      set_config_int("mc", "value", 22);
//      set_config_int("mc", "value", 33);
      mc = new("mc", this);
    endfunction

    task run;
      bit failed = 0;
      uvm_resource_db#(int)::write_by_name("value", { get_full_name(), ".mc"}, 44, this);
//      set_config_int("mc", "value", 44);
      #10;
      if(mc.build_val != 33) begin
        $display("*** UVM TEST FAILED, expected mc.build_val=33 but got %0d ***", mc.build_val);
        failed = 1;
      end
      if(mc.run_val != 44) begin
        $display("*** UVM TEST FAILED, expected mc.run_val=44 but got %0d ***", mc.run_val);
        failed = 1;
      end
      if(!failed) $display("*** UVM TEST PASSED ***");
      global_stop_request();
    endtask

    function void report();
      uvm_resource_pool rp = uvm_resource_pool::get();
      rp.dump();
    endfunction
  endclass

  initial run_test();
endmodule
