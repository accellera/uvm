`ifndef __MEM_SEQUENCER_SV__
`define __MEM_SEQUENCER_SV__


class mem_sequencer extends uvm_sequencer #(mem_transfer);

   
   `uvm_component_utils(mem_sequencer)

     
   extern function new(string name, uvm_component parent);
endclass // mem_sequencer


function mem_sequencer::new(string name, uvm_component parent);
   super.new(name, parent);
endfunction // new

   
`endif // __MEM_SEQUENCER_SV__
