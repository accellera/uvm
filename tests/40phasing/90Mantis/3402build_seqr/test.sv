module top;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  typedef class seqr;
  class seq extends uvm_sequence;
    static int exec=0;
    `uvm_sequence_utils(seq,seqr)
    task body;
      `uvm_info("SEQ", "Starting seq...", UVM_NONE)
      exec++;
      `uvm_info("SEQ", "Ending seq...", UVM_NONE)
    endtask 

  function new(string name="seq");
     super.new(name);
  endfunction

  endclass

  class seqr extends uvm_sequencer;
    function new(string name,uvm_component parent);
      super.new(name,parent);
      `uvm_update_sequence_lib
    endfunction

    `uvm_sequencer_utils(seqr)
  endclass

  class test extends uvm_component;
    seqr s1;
    
    function new(string name,uvm_component parent);
      super.new(name,parent);
    endfunction

    `uvm_component_utils(test)

    function void build;
//      uvm_config_db #(uvm_object_wrapper)::set(this,"s1.run_phase","default_sequence",seq::type_id::get());
      void'(set_config_string("s1","default_sequence","seq"));

      s1 = new("s1",this);
      s1.build();
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
