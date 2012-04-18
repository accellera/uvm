//----------------------------------------------------------------------
//   Copyright 2010-2011 Cadence Design Systems, Inc.
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
//----------------------------------------------------------------------

import uvm_pkg::*;
`include "uvm_macros.svh"

// This test makes sure that uvm_config_db::set calls get reused if
// the set call had previously been made, and that the set call gets
// moved to the head of the priority queue. This is done primarily
// for efficency for run time usage of config settings.
//
// To make this test, 2 different set calls are used to interleave
// sets during run time, and one uvm_resource_db call is used to 
// insert new resources in between to make sure the sets work correctly
// with direct calls to the uvm_resource_db. uvm_config_db::get()
// is used for all get calls.

//----------------------------------------------------------------------
// test
//----------------------------------------------------------------------
class test extends uvm_component;
  bit failed = 0;

  `uvm_component_utils(test)

  function new(string name, uvm_component parent = null);
    super.new(name, parent);
  endfunction

  task run();
    uvm_resource_pool rp = uvm_resource_pool::get();
    uvm_bitstream_t val;
    uvm_resource_types::rsrc_q_t rq;
    int sets = 0;
    uvm_resource#(uvm_bitstream_t) rsrc = new("val", get_full_name());
    rsrc.set(); sets++;

    //The first setting should create a new resource, but subsequence
    //sets via the config db should not.
    uvm_config_db#(uvm_bitstream_t)::set(this, "", "val", 0); 
    sets++;

    for(int i=0; i<5; ++i) begin
      // Test a write to the config db goes to the head of the queue
      uvm_config_db#(uvm_bitstream_t)::set(this, "", "val", i); 
      void'(uvm_config_db#(uvm_bitstream_t)::get(this,"","val",val));
      if(val != i) begin
        $display("Got wrong config value: expected %0d, got %0d", i, val);
        failed=1;
      end

      // Do a set_config
      set_config_int("", "val", 25*i);
      void'(get_config_int("val", val));
      if(val != 25*i) begin
        $display("Got wrong config value: expected %0d, got %0d", 25*i, val);
        failed=1;
      end
  
      // Test a write to the resource_db goes to the head of the queue.
      rsrc.write(i*i, this);
      rp.set_priority_name(rsrc, uvm_resource_types::PRI_HIGH);
      void'(uvm_resource_db#(uvm_bitstream_t)::read_by_name(get_full_name(), "val",
                                                      val, this));
      if(val != i*i) begin
        $display("Got wrong resource value: expected %0d, got %0d", i*i, val);
        failed=1;
      end

      rq =  rp.lookup_name(get_full_name(), "val");

      // Verify that the config settings got reused.
      if(sets != rq.size()) begin
        $display("Got wrong queue size: expected %0d, got %0d", sets, rq.size());
        failed=1;
      end 
    end
  endtask

  function void report();
    if(failed)
      $display("** UVM TEST FAILED **");
    else
      $display("** UVM TEST PASSED **");

  endfunction

endclass

//----------------------------------------------------------------------
// top
//----------------------------------------------------------------------
module top;

  initial run_test();

endmodule
