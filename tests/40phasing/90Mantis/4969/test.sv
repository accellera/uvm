module top;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

class base_seq extends uvm_sequence;
 
  `uvm_object_utils(base_seq)

  function new(string name="base_seq");
    super.new(name);
  endfunction

  task pre_body();
    if (starting_phase != null) begin
      starting_phase.raise_objection(this, get_type_name());
      `uvm_info(get_type_name(), "raise objection", UVM_MEDIUM)
    end
  endtask : pre_body

  task body();
    #20ns;
  endtask

  task post_body();
    if (starting_phase != null) begin
      starting_phase.drop_objection(this, get_type_name());
      `uvm_info(get_type_name(), "raise objection", UVM_MEDIUM)
    end
  endtask : post_body

endclass : base_seq

class test extends uvm_test;

  `uvm_component_utils(test)

  uvm_sequencer sequencer;

  function new (string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    sequencer = uvm_sequencer::type_id::create("sequencer", this);
    uvm_config_wrapper::set(this, "sequencer.run_phase",
                            "default_sequence",
                            base_seq::type_id::get());

  endfunction // build_phase
   virtual function void check_phase(uvm_phase phase);
      if($time == 0) `uvm_fatal("TEST","objection raise/drop without effect")
   endfunction
endclass

initial begin
  run_test("test");
end

endmodule : top

