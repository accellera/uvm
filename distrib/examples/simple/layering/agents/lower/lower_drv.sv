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


class lower_drv extends uvm_driver#(lower_item);

  virtual lower_if vif;

  `uvm_component_utils(lower_drv)

  function new(string name = "lower_drv", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    if (!uvm_config_db#(virtual lower_if)::get(this, "", "vif", vif)) begin
      `uvm_fatal("LOWER/DRV/NOVIF", "No virtual interface specified")
    end
  endfunction

  virtual task run_phase(uvm_phase phase);
    forever begin
      lower_item tr;

      seq_item_port.get_next_item(tr);
      vif.item = tr;
      ->vif.ev;
      #10;
      seq_item_port.item_done();
    end
  endtask
endclass
