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


class layerA_drv extends upperA_drv;

  `uvm_component_utils(layerA_drv)

  function new(string name = "layerA_drv", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  virtual task run_phase(uvm_phase phase);
    lower_passthru_seq l_seq;
    lower_sqr          l_sqr;
    int                pri = -1;

    if (!uvm_config_db#(lower_sqr)::get(this, "", "lower_sqr", l_sqr) || l_sqr == null) begin
      `uvm_fatal("UPPERA/DRV/NOPASS", "No lower_sqr sequencer specified")
    end
    uvm_config_db#(int)::get(this, "", "pri", pri);

    l_seq = lower_passthru_seq::type_id::create("l_seq", this);
    
    forever begin
      upperA_item u_item;
      lower_item  l_item;

      seq_item_port.get_next_item(u_item);
      l_item = lower_item::type_id::create("l_item", this);
      l_item.encapsulate(u_item);
      l_seq.start_item(l_item, pri, l_sqr);
      l_seq.finish_item(l_item, pri);
      seq_item_port.item_done();
    end
  endtask
endclass
