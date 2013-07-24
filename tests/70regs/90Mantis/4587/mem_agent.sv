`ifndef __MEM_AGENT_SV__
`define __MEM_AGENT_SV__


class mem_agent extends uvm_agent;

   protected uvm_active_passive_enum   is_active = UVM_ACTIVE;

   mem_driver    driver;
   mem_sequencer sequencer;

   
   `uvm_component_utils_begin(mem_agent)
      `uvm_field_enum(uvm_active_passive_enum, is_active, UVM_ALL_ON)
   `uvm_component_utils_end

   extern function new(string name, uvm_component parent);
   extern function void build_phase(uvm_phase phase);
   extern function void connect_phase(uvm_phase phase);
endclass // mem_agent


function mem_agent::new(string name, uvm_component parent);
   super.new(name, parent);
endfunction // new


function void mem_agent::build_phase(uvm_phase phase);
   string inst_name;
   
   super.build_phase(phase);
   
   if (is_active == UVM_ACTIVE) begin
      driver    = mem_driver::type_id::create("driver", this);
      sequencer = mem_sequencer::type_id::create("sequencer", this);
   end // if (is_active == UVM_ACTIVE)
endfunction // build_phase


function void mem_agent::connect_phase(uvm_phase phase);
   super.connect_phase(phase);
   
   if (is_active == UVM_ACTIVE) begin
      driver.seq_item_port.connect(sequencer.seq_item_export);
   end
endfunction // connect_phase


`endif // __MEM_AGENT_SV__
