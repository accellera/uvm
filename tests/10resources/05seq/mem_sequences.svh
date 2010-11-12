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

//----------------------------------------------------------------------
// mem_seq_rand
//----------------------------------------------------------------------
class mem_seq_rand #(int unsigned ADDR_SIZE=16, int unsigned DATA_SIZE=8)
  extends uvm_sequence #(mem_seq_item #(ADDR_SIZE, DATA_SIZE));

  typedef mem_seq_rand #(ADDR_SIZE, DATA_SIZE) this_type;
  typedef mem_seq_item #(ADDR_SIZE, DATA_SIZE) item_t;
  `uvm_object_param_utils(this_type)

  int unsigned loop_count;

  function new(string name="mem_seq_rand");
    super.new(name);
  endfunction

  task pre_body();

    // obtain the loop count from the resources database
    if(!uvm_resource_db#(int unsigned)::read_by_name("mem_seq", "loop_count", loop_count, this))
      loop_count = 5;

    $display("loop_count = %0d", loop_count);

  endtask

  task body();

    item_t item;
    int unsigned i;

    for(i = 0; i < loop_count; i++) begin
      assert($cast(item, create_item(item_t::get_type(),
                   m_sequencer, "mem_item")));
      start_item(item);
      assert(item.randomize());
      finish_item(item);
      get_response(item);
    end
  endtask

endclass
