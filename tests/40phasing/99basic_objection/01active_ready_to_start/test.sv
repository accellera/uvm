module test;

   import uvm_pkg::*;
`include "uvm_macros.svh"

class test extends uvm_test;

  `uvm_component_utils(test)

  uvm_basic_objection foo;

  function new(string name="quick test", uvm_component parent);
    super.new(name, parent);
  endfunction // new

  task run_phase(uvm_phase phase);
    phase.raise_objection(this);

    foo = new("foo");
    foo.raise_objection(this);
    fork
      begin
	foo.wait_for_sum(0);
	$display("*** UVM TEST PASSED ***");
      end
    join_none
    #5;
    foo.drop_objection(this);
    #100 phase.drop_objection(this);
  endtask
endclass
  
  initial 
    run_test();
      
endmodule // test
