module test;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  class test extends uvm_test ;
    `uvm_component_utils(test)

    bit ran;
     
    function new(string name, uvm_component parent);
      super.new(name,parent) ;
    endfunction

    uvm_phase main_ph ;
    
    task reset_phase(uvm_phase phase) ;
      phase.raise_objection(this);
      main_ph = phase.find_by_name("main");
      // the next two lines cause main phase to take 0 time
      main_ph.raise_objection(this) ;
      #5;
      main_ph.drop_objection(this) ;
      `uvm_info("TEST","done with reset", UVM_MEDIUM);
      phase.drop_objection(this);
    endtask

    task main_phase(uvm_phase phase) ;
      `uvm_info("TEST","starting main", UVM_MEDIUM);
      phase.raise_objection(this) ;
      #5 ;
      `uvm_info("TEST","done with main", UVM_MEDIUM); // This will never get executed
      phase.drop_objection(this);

      ran = 1;
    endtask

     function void report_phase(uvm_phase phase);
        if (ran) $write("** UVM TEST PASSED **\n");
        else begin
           `uvm_error("TEST", "main phase was aborted")
           $write("!! UVM TEST FAILED !!\n");
        end
     endfunction
  endclass
  
  initial run_test("test");
endmodule

