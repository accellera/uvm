//----------------------------------------------------------------------
//   Copyright 2007-2010 Mentor Graphics Corporation
//   Copyright 2007-2010 Cadence Design Systems, Inc.
//   Copyright 2010 Synopsys, Inc.
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

`ifndef UBUS_SLAVE_SEQUENCER_SV
`define UBUS_SLAVE_SEQUENCER_SV

//------------------------------------------------------------------------------
//
// CLASS: ubus_slave_sequencer
//
//------------------------------------------------------------------------------

class ubus_slave_sequencer extends uvm_sequencer #(ubus_transfer);

  // TLM port to peek the address phase from the slave monitor
  uvm_blocking_peek_port#(ubus_transfer) addr_ph_port;

  // Provide implementations of virtual methods such as get_type_name and create
  `uvm_component_utils(ubus_slave_sequencer)

  // new - constructor
  function new (string name, uvm_component parent);
    super.new(name, parent);
//    `uvm_update_sequence_lib_and_item(ubus_transfer)
    addr_ph_port = new("addr_ph_port", this);
    set_phase_domain("uvm");
    
  endfunction : new

endclass : ubus_slave_sequencer

`endif // UBUS_SLAVE_SEQUENCER_SV

