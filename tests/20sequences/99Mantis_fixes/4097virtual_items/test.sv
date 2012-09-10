module test();

  import uvm_pkg::*;
  `include "uvm_macros.svh"

  initial begin
     run_test();
  end

  virtual class my_v_sequence_item extends uvm_sequence_item;
    `uvm_field_utils_begin(my_v_sequence_item)
    `uvm_field_utils_end
    function new(string name = "unnamed-my_v_sequence_item");
      super.new(name);
    endfunction
  endclass

  virtual class my_v_sequence #(type T = my_v_sequence_item) extends
    uvm_sequence #(T);
    `uvm_field_utils_begin(my_v_sequence)
    `uvm_field_utils_end
    function new(string name = "unnamed-my_v_sequence");
      super.new(name);
    endfunction
  endclass

  class my_sequence_item extends my_v_sequence_item;
    `uvm_object_utils(my_sequence_item)
    function new(string name = "unnamed-my_sequence_item");
      super.new(name);
    endfunction
  endclass

  class my_sequence extends my_v_sequence #(my_sequence_item);
    `uvm_object_utils(my_sequence)
    function new(string name = "unnamed-my_sequence");
      super.new(name);
    endfunction
  endclass

  class test extends uvm_test;
    `uvm_component_utils_begin(test)
    `uvm_component_utils_end
    function new(string name, uvm_component parent);
      super.new(name, parent);
    endfunction
    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
    endfunction
    task run_phase(uvm_phase phase);
      uvm_sequence_library#(my_v_sequence_item) my_sl;
      my_v_sequence my_vseq;
      phase.raise_objection(this);
      #5;
      phase.drop_objection(this);
    endtask // run_phase

    function void report_phase(uvm_phase phase);
       $display("*** UVM TEST PASSED ***");
    endfunction : report_phase
  endclass

endmodule
