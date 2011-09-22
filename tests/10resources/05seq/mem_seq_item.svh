//------------------------------------------------------------------------------
//   Copyright 2010 Mentor Graphics Corporation
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
//------------------------------------------------------------------------------

typedef enum
{
  MEM_READ,
  MEM_WRITE
//  MEM_NOP
} mem_op_t;

//----------------------------------------------------------------------
// mem_seq_item
//----------------------------------------------------------------------
class mem_seq_item #(int unsigned ADDR_SIZE=16, int unsigned DATA_SIZE=8)
  extends uvm_sequence_item;

  typedef mem_seq_item #(ADDR_SIZE, DATA_SIZE) this_type;
  `uvm_object_param_utils(this_type)

  rand bit [DATA_SIZE-1:0] data;
  rand bit [ADDR_SIZE-1:0] addr;
  rand mem_op_t op;

  function string convert2string();
    string s;
    string fmt;

    // Set up address and data print formats based on size
    int unsigned data_chars = ((DATA_SIZE >> 2) + ((DATA_SIZE & 'h3) > 0));
    int unsigned addr_chars = ((ADDR_SIZE >> 2) + ((ADDR_SIZE & 'h3) > 0));
    $sformat(fmt, "%%s: addr=%%0%0dx  data=%%0%0dx", addr_chars, data_chars);

    $sformat(s, fmt, op.name(), addr, data);

    return s;
  endfunction


  function new(string name="mem_seq_item");
     super.new(name);
  endfunction

endclass
