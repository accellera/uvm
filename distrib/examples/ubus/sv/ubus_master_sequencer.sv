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

`ifndef UBUS_MASTER_SEQUENCER_SV
`define UBUS_MASTER_SEQUENCER_SV

//------------------------------------------------------------------------------
//
// CLASS: ubus_master_sequencer
//
//------------------------------------------------------------------------------

class ubus_master_sequencer extends uvm_sequencer #(ubus_transfer);

  // Master Id
  protected int master_id;

  `uvm_component_utils_begin(ubus_master_sequencer)
    `uvm_field_int(master_id, UVM_DEFAULT)
  `uvm_component_utils_end
  /*
  `uvm_sequencer_utils_begin(ubus_master_sequencer)
    `uvm_field_int(master_id, UVM_DEFAULT)
  `uvm_sequencer_utils_end
*/
  // new - constructor
  function new (string name, uvm_component parent);
    super.new(name, parent);
 //   `uvm_update_sequence_lib_and_item(ubus_transfer)
    set_phase_domain("uvm");
  endfunction : new

endclass : ubus_master_sequencer

`endif // UBUS_MASTER_SEQUENCER_SV

