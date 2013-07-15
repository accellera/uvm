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

class lower_mon extends uvm_monitor;

  virtual lower_if vif;

  `uvm_component_utils(lower_mon)

  uvm_analysis_port#(lower_item) ap;

  function new(string name = "lower_mon", uvm_component parent = null);
    super.new(name, parent);
    ap = new("ap", this);
  endfunction

  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    if (!uvm_config_db#(virtual lower_if)::get(this, "", "vif", vif)) begin
      `uvm_fatal("LAYERED/MON/NOVIF", "No virtual interface specified")
    end
  endfunction

  virtual task run_phase(uvm_phase phase);
    forever begin
      @(vif.ev);
      ap.write(vif.item);
    end
  endtask
endclass
