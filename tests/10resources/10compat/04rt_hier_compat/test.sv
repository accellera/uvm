module test;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  class myleaf extends uvm_component;
    int build_val=0;
    int run_val=0;
 
    `uvm_new_func
    `uvm_component_utils(myleaf)

    function void build();
      super.build();
      void'(get_config_int("value", build_val));
    endfunction
    task run;
      #5 void'(get_config_int("value", run_val));
    endtask
  endclass
 
  class mycomp extends uvm_component;
    myleaf leaf; 
    function new(string name, uvm_component parent);
      super.new(name,parent);
    endfunction
    `uvm_component_utils(mycomp)

    function void build();
      super.build();
      set_config_int("mc", "value", 33);
      leaf = new("leaf", this);
    endfunction
    task run;
      #2 set_config_int("leaf", "value", 55);
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
      set_config_int("mc.leaf", "value", 22);
      mc = new("mc", this);
    endfunction

    task run;
      bit failed = 0;

      set_config_int("mc.leaf", "value", 44); //takes precedence because of hierarhcy
      #10;
      if(mc.leaf.build_val != 22) begin 
        $display("*** UVM TEST FAILED, expected mc.leaf.build_val=22 but got %0d ***", mc.leaf.build_val);
        failed = 1;
      end

      // Create a backward incompat on purpose. Want last set at runtime. So,
      // would have gotten 44, but we want 55 since it is set at time 2.
      if(mc.leaf.run_val != 55) begin
        $display("*** UVM TEST FAILED, expected mc.run_val=55 but got %0d ***", mc.leaf.run_val);
        failed = 1;
      end
      if(!failed) $display("*** UVM TEST PASSED ***");
      global_stop_request();
    endtask
  endclass

  initial run_test();
endmodule
