//----------------------------------------------------------------------
// hfpb_sequencer
//----------------------------------------------------------------------
class hfpb_sequencer #(int DATA_SIZE=8, int ADDR_SIZE=16)
  extends uvm_sequencer #(hfpb_seq_item #(DATA_SIZE, ADDR_SIZE),
                          hfpb_seq_item #(DATA_SIZE, ADDR_SIZE));

  function new (string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  task run();
  endtask

endclass

  