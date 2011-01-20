class my_seqr extends uvm_sequencer;
  `uvm_sequencer_utils_begin(my_seqr)
  `uvm_sequencer_utils_end

  function new (string name="my_seqr0", uvm_component parent);
    super.new(name, parent);
    count = 0;
  endfunction : new

endclass : my_seqr

class my_seq extends uvm_sequence;
  `uvm_object_utils(my_seq)
endclass : my_seq
