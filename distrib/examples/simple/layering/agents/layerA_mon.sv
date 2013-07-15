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

class layerA_mon extends upperA_mon;

  `uvm_component_utils(layerA_mon)

  uvm_analysis_imp#(lower_item, layerA_mon) axp;

  function new(string name = "layerA_mon", uvm_component parent = null);
    super.new(name, parent);
    axp = new("axp", this);
  endfunction

  function void write(lower_item l_item);
    upperA_item u_item;

    if ($cast(u_item, l_item.decapsulate()) && u_item != null) begin
      ap.write(u_item);
    end
  endfunction

  task run_phase(uvm_phase phase);
  endtask
endclass
