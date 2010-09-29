module top;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  class comp extends uvm_component;
    `uvm_new_func
    `uvm_component_utils(comp)

    task run;
      uvm_test_done.set_drain_time(this, 1);

      for(int i=0;i<3; ++i) begin
        int v = i;
        fork begin
          doit(v);
        end join_none
      end
    endtask

    task doit(int v);
      uvm_report_info("DOIT", $sformatf("Calling doit with v = %0d", v));
      uvm_test_done.raise_objection(this);
      #(v*10 + 1);
      uvm_test_done.drop_objection(this);
      disable fork; 
    endtask

    function void report();
      $display("*** UVM TEST PASSED ***");
    endfunction
  endclass

  class test extends uvm_test;
    comp c;
    function new(string name, uvm_component parent);
      super.new(name,parent);
      c = new("c", this);
    endfunction
    `uvm_component_utils(test)
  endclass

  initial run_test;

endmodule
