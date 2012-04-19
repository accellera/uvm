`ifndef __MEM_VIP_ENV_SV__
`define __MEM_VIP_ENV_SV__


////////////////////////////////////
// Environment Class  //////////////
////////////////////////////////////
class mem_env extends uvm_env;

   /////////////////////////////////////////////////
   // Agents ///////////////////////////////////////
   /////////////////////////////////////////////////
   mem_agent mem_agt;

   
   /////////////////////////////////////////////////
   // Adapter //////////////////////////////////////
   /////////////////////////////////////////////////
   reg2mem_adapter mem_adapter;

   
   /////////////////////////////////////////////////
   // Register Model ///////////////////////////////
   /////////////////////////////////////////////////
   mem_reg_block  reg_model;

   
   /////////////////////////////////////////////////
   // Component Macros /////////////////////////////
   /////////////////////////////////////////////////
   `uvm_component_utils(mem_env)

     
   /////////////////////////////////////////////////
   // Methods //////////////////////////////////////
   /////////////////////////////////////////////////
   extern function new(string name, 
                       uvm_component parent);
   extern function void build_phase(uvm_phase phase);
   extern function void connect_phase(uvm_phase phase);
endclass // mem_vip_env


function mem_env::new(string name,
        	      uvm_component parent);
   super.new(name, parent);
endfunction // new


function void mem_env::build_phase(uvm_phase phase);
   super.build_phase(phase);

   mem_agt = mem_agent::type_id::create("mem_agt", this);
   
   if (!uvm_config_db #(mem_reg_block)::get(this, "", "reg_model", reg_model))
        `uvm_fatal("BAD_CONFIG","Cannot get() reg_model from uvm_config_db!");
endfunction // build_phase


function void mem_env::connect_phase(uvm_phase phase);
   super.connect_phase(phase);

   mem_adapter = reg2mem_adapter::type_id::create("mem_adapter");
   reg_model.default_map.set_sequencer(mem_agt.sequencer, mem_adapter);
endfunction

   
`endif // __MEM_ENV_SV__
