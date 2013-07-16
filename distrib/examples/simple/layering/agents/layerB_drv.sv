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


class layerB_drv extends upperB_drv;

  local lower_sqr sqr;
  
  `uvm_component_utils(layerB_drv)

  function new(string name = "layerB_drv", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  virtual task run_phase(uvm_phase phase);
    lower_passthru_seq seq = new("seq");
    lower_sqr sqr;

    if (!uvm_config_db#(lower_sqr)::get(this, "", "lower_sqr", sqr) || sqr == null) begin
      `uvm_fatal("UPPERB/DRV/NOPASS", "No lower_sqr sequencer specified")
    end

    fork
      seq.start(sqr);
    join_none
    
    forever begin
      upperB_item tr;

      wait (seq.req != null);
      seq_item_port.get_next_item(tr);
      seq.req.encapsulate(tr);
      seq.req = null;
      seq_item_port.item_done();
    end
  endtask
endclass
