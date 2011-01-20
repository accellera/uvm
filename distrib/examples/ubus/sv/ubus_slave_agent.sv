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

//------------------------------------------------------------------------------
//
// CLASS: ubus_slave_agent
//
//------------------------------------------------------------------------------

class ubus_slave_agent extends uvm_agent;

  protected uvm_active_passive_enum is_active = UVM_ACTIVE;

  ubus_slave_driver driver;
  ubus_slave_sequencer sequencer;
  ubus_slave_monitor monitor;

  // Provide implementations of virtual methods such as get_type_name and create
  `uvm_component_utils_begin(ubus_slave_agent)
    `uvm_field_enum(uvm_active_passive_enum, is_active, UVM_DEFAULT)
  `uvm_component_utils_end

  // new - constructor
  function new (string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new

  // build_phase
  virtual function void build_phase();
    super.build_phase();
    monitor = ubus_slave_monitor::type_id::create("monitor", this);
    if(is_active == UVM_ACTIVE) begin
      driver = ubus_slave_driver::type_id::create("driver", this);
      sequencer = ubus_slave_sequencer::type_id::create("sequencer", this);
    end
  endfunction : build_phase

  // connect
  function void connect_phase();
    if(is_active == UVM_ACTIVE) begin
      driver.seq_item_port.connect(sequencer.seq_item_export);
      sequencer.addr_ph_port.connect(monitor.addr_ph_imp);
    end
  endfunction : connect_phase

endclass : ubus_slave_agent


