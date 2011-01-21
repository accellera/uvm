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

`ifndef SIMPLE_ITEM_SV
`define SIMPLE_ITEM_SV

//------------------------------------------------------------------------------
//
// CLASS: simple_item
//
// declaration
//------------------------------------------------------------------------------

class simple_item extends uvm_sequence_item;

  rand int unsigned addr;
    constraint c1 { addr < 16'h2000; }
  rand int unsigned data;
    constraint c2 { data < 16'h1000; }

  `uvm_object_utils_begin(simple_item)
    `uvm_field_int(addr, UVM_ALL_ON)
    `uvm_field_int(data, UVM_ALL_ON)
  `uvm_object_utils_end

  // new - constructor
  function new (string name = "simple_item");
    super.new(name);
  endfunction : new

endclass : simple_item

`endif // SIMPLE_ITEM_SV
