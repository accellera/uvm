//------------------------------------------------------------------------------
//   Copyright 2007-2011 Mentor Graphics Corporation
//   All Rights Reserved Worldwide
//
//   Licensed under the Apache License, Version 2.0 (the
//   "License"); you may not use this file except in
//   compliance with the License.  You may obtain a copy of
//   the License at
//
//       http://www.apache.org/licenses/LICENSE-2.0
//
//   Unless required by applicable law or agreed to in
//   writing, software distributed under the License is
//   distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
//   CONDITIONS OF ANY KIND, either express or implied.  See
//   the License for the specific language governing
//   permissions and limitations under the License.
//------------------------------------------------------------------------------

`include "ctypes.sv"
`include "mem_agent.sv"
`include "mem_sequences.sv"
`include "mem.sv"

import uvm_pkg::*;
`include "uvm_macros.svh"

import mem_agent::*;
import mem_sequences::*;


package top_pkg;
   import uvm_pkg::*;

   typedef virtual mem_if #(8, 8) vif_t;
   typedef uvm_resource_db#(virtual mem_if #(8, 8)) mem_if_rsrc_t;
endpackage

import top_pkg::*;


//----------------------------------------------------------------------
// top
//----------------------------------------------------------------------
module top;

  import top_pkg::*;

   parameter int ADDR_SIZE = 8;
   parameter int DATA_SIZE = 8;
 
  clkgen ck(clk);
  mem_if #(ADDR_SIZE, DATA_SIZE) mif1(clk);
  mem_if #(ADDR_SIZE, DATA_SIZE) mif2(clk);

  memory #(ADDR_SIZE, DATA_SIZE) mem1(mif1);
  memory #(ADDR_SIZE, DATA_SIZE) mem2(mif2);

  initial begin

    // set the virtuals interfaces into the resouce pool under the
    // pseudo-space "vif".  We put them in that space because we don't
    // know what the testbench hierarchy will look like and we need to
    // put them somewhere.  The top-level environment can retrieve them
    // and put them into the propoer part of the component space, if
    // necessary.

    mem_if_rsrc_t::set("vif.mem_if1", "mif1", mif1);
    mem_if_rsrc_t::set("vif.mem_if2", "mif2", mif2);

    run_test();
  end

endmodule


//----------------------------------------------------------------------
// env
//----------------------------------------------------------------------
class env #(int unsigned ADDR_SIZE=16, int unsigned DATA_SIZE=8)
   extends uvm_component;


  typedef env #(ADDR_SIZE, DATA_SIZE) this_type;

  `uvm_component_param_utils(this_type)

  mem_agent #(mem_agent_config, ADDR_SIZE, DATA_SIZE) agnt1;
  mem_agent #(mem_agent_config, ADDR_SIZE, DATA_SIZE) agnt2;



   
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build();

    vif_t mif1;
    vif_t mif2;

    // Retrieve the virtual interface resources from the vif
    // pseudo-space and put them into a component-oriented part of the
    // resource name space.  It's not strictly necessary to do this
    // since the virutal interfaces are in the resource pool.  However,
    // it puts less burden on the agents to have to know where to go
    // looking for them.  The agents can just assume that the virtual
    // interfaces have been made visible in their own name space.

    if (!mem_if_rsrc_t::read_by_type("vif.mem_if1", mif1)) begin
       `uvm_error("Test", "read_by_type() failed");
    end
    if (!mem_if_rsrc_t::read_by_type("vif.mem_if2", mif2)) begin
       `uvm_error("Test", "read_by_type() failed");
    end

    mem_if_rsrc_t::set("*.mem_agent1.*", "mif1", mif1, this);
    mem_if_rsrc_t::set("*.mem_agent2.*", "mif2", mif2, this);

    // instantiate the agents
    agnt1 = new("mem_agent1", this);
    agnt2 = new("mem_agent2", this);

  endfunction

endclass

//----------------------------------------------------------------------
// test
//----------------------------------------------------------------------
class test extends uvm_component;

  `uvm_component_utils(test)

  env #(8,8) e;
 
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build();

    // create and populate the config object for the mem agent
    mem_agent_config mem_cfg  = new();
    mem_cfg.initial_sequence = mem_seq_rand#(8,8)::get_type();

    // turn off resource auditing
    uvm_resource_options::turn_off_auditing();

     
    // create the configuration resource and set it into the resoures
    // database
    uvm_resource_db#(mem_agent_config)::set("*.mem_agent*", "mem_cfg",
                                            mem_cfg, this);
    // establish the loop count for the main sequence
    uvm_resource_db#(int unsigned)::set("mem_seq", "loop_count",
                                         1, this);
    
    e = new("env", this);
  endfunction

  task run_phase(uvm_phase phase);
     phase.raise_objection(this);
     #100;
     print_config(1);
     phase.drop_objection(this);
  endtask

  function void report();
    uvm_resource_pool rp = uvm_resource_pool::get();
    uvm_report_server rs = get_report_server();
    if(rs.get_severity_count(UVM_ERROR) > 0)
      $display("** UVM TEST FAIL **");
    else
      $display("** UVM TEST PASSED **");

    // The '1' argument to dump() instructs the function to also dump
    // the audit trail.  However, since we turned auditing off above we
    // should not see an audit trail appear.
    rp.dump(1);
  endfunction

endclass

