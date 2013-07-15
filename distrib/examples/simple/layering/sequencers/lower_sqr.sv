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

class lower_sqr extends uvm_sequencer#(lower_item);

  uvm_seq_item_pull_port#(upperA_item) upperA_item_port;
  uvm_seq_item_pull_port#(upperB_item) upperB_item_port;

  `uvm_component_utils(lower_sqr)

  function new(string name = "lower_sqr", uvm_component parent = null);
    super.new(name, parent);

    upperA_item_port = new("upperA_item_port", this);
    upperB_item_port = new("upperB_item_port", this);
  endfunction
endclass
