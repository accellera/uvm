//----------------------------------------------------------------------
//   Copyright 2013 Synopsys, Inc.
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
//----------------------------------------------------------------------

`ifndef SIMPLE_AGENT_SV
`define SIMPLE_AGENT_SV

`include "simple_item.sv"
`include "simple_sequencer.sv"
`include "simple_driver.sv"
`include "simple_seq_lib.sv"


//------------------------------------------------------------------------------
//
// CLASS: simple_agent
//
// declaration
//------------------------------------------------------------------------------


class simple_agent extends uvm_agent;

  simple_sequencer sequencer;
  simple_driver    driver;
  // simple_monitor   monitor;

  // Provide implementations of virtual methods such as get_type_name and create
  `uvm_component_utils(simple_agent)

  // Constructor
  function new (string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    sequencer = simple_sequencer::type_id::create("sequencer", this);
    driver    = simple_driver::type_id::create("driver", this);
    // monitor    = simple_monitor::type_id::create("monitor", this);
  endfunction
  
  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    driver.seq_item_port.connect(sequencer.seq_item_export);
  endfunction

endclass : simple_agent


`endif // SIMPLE_AGENT_SV
