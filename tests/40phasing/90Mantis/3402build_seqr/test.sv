module top;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  typedef class seqr;
  class seq extends uvm_sequence;
    static int exec=0;
    `uvm_object_utils(seq)
    task body;
	  uvm_phase phase = get_starting_phase();
	  phase.raise_objection(this);
      `uvm_info("SEQ", "Starting seq...", UVM_NONE)
      exec++;
      `uvm_info("SEQ", "Ending seq...", UVM_NONE)
  	  phase.drop_objection(this);     
    endtask 

  function new(string name="seq");
     super.new(name);
  endfunction

  endclass

  class seqr extends uvm_sequencer;
    function new(string name,uvm_component parent);
      super.new(name,parent);
    endfunction

    `uvm_component_utils(seqr)
  endclass

  class test extends uvm_component;
    seqr s1;
    
    function new(string name,uvm_component parent);
      super.new(name,parent);
    endfunction

    `uvm_component_utils(test)

    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      void'(uvm_config_string::set(this, "s1","default_sequence","seq"));

      s1 = new("s1",this);
      s1.build();

       begin
	  phase.print();
       end
    endfunction

    function void report_phase(uvm_phase phase);
      if(seq::exec == 1) $display("*** UVM TEST PASSED ***");
      else $display("*** UVM TEST FAILED ***");
    endfunction
  endclass
 
  initial begin
    run_test;
  end
endmodule
