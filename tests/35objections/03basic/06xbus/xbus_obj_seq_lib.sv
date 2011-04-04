//----------------------------------------------------------------------
//   Copyright 2007-2009 Cadence Design Systems, Inc.
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

//------------------------------------------------------------------------------
//
// SEQUENCE: obj_example_seq
//
//------------------------------------------------------------------------------

class obj_example_seq extends uvm_sequence #(xbus_transfer);

  function new(string name="obj_example_seq");
    super.new(name);
  endfunction : new

  `uvm_sequence_utils(obj_example_seq, xbus_master_sequencer)

  write_byte_seq write_byte_seq0;
  rand int unsigned count;
    constraint count_ct { count inside {[5:10]}; }

  virtual task pre_body();
    p_sequencer.uvm_report_info(get_type_name(),
      $sformatf("%s pre_body() raising an uvm_test_done objection", 
      get_sequence_path()), UVM_MEDIUM);
    uvm_test_done.raise_objection(this);
  endtask
  
  virtual task body();
    p_sequencer.uvm_report_info(get_type_name(),
      $sformatf("%s body() starting with count = %0d", 
      get_sequence_path(), count), UVM_MEDIUM);
    repeat(count) begin : repeat_block
      `uvm_do(write_byte_seq0)
    end : repeat_block
  endtask : body
  
  virtual task post_body();
    p_sequencer.uvm_report_info(get_type_name(),
      $sformatf("%s post_body() dropping an uvm_test_done objection after count %0d items", 
      get_sequence_path(), count), UVM_MEDIUM);
    uvm_test_done.drop_objection(this);
  endtask
  
endclass : obj_example_seq

