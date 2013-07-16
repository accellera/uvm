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

class layerB_seq extends uvm_sequence#(lower_item);

  `uvm_object_utils(layerB_seq)
  `uvm_declare_p_sequencer(lower_sqr)

  function new(string name = "layerB_seq");
    super.new(name);
  endfunction

  virtual task body();
    lower_item l_item;
    upperB_item u_item;

    forever begin
      p_sequencer.upperB_item_port.get_next_item(u_item);
      `uvm_create(l_item)
      l_item.encapsulate(u_item);
      `uvm_send(l_item)
      p_sequencer.upperB_item_port.item_done();
    end
  endtask

endclass
