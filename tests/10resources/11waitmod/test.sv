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

// This test verifies that waiters wake up at the correct time.

  bit failed = 0;

// Component that has waiters

class cfgobj;
  int value;
  function new(int v);
    value = v;
  endfunction
endclass

class mycomp extends uvm_component;
  int field1;
  cfgobj field2;

  int cfg_settings = 0;

  int f1_start, f2_start;
  bit f1_init=0, f2_init=0;

  function new(string name, uvm_component parent);
    super.new(name,parent);
    fork
      watch_field1;
      watch_field2;
    join_none
  endfunction

  task watch_field1;
    int prev;
    int exp;

    while(1) begin
      uvm_config_db#(uvm_bitstream_t)::wait_modified(this, "", "field1");
      cfg_settings++;

      prev = field1;
      void'(get_config_int("field1",field1));

      if(!f1_init) begin
        f1_init = 1;
        exp = f1_start;
      end
      else exp = prev + 20;

      if(exp != field1) begin
        failed = 1;
        $display("*** UVM TEST FAILED for %s field1, expected value %0d, got %0d", get_full_name(), exp, field1);
      end

      `uvm_info("Field1", $sformatf("Got change to field1 from %0d to %0d",prev, field1), UVM_NONE);
    end
  endtask
  task watch_field2;
    cfgobj prev;
    int exp;

    while(1) begin
      uvm_config_db#(cfgobj)::wait_modified(this, "", "field2");
      cfg_settings++;

      prev = field2;
      void'(uvm_config_db#(cfgobj)::get(this,"","field2",field2));

      if(!f2_init) begin
        exp = f2_start;
        f2_init = 1;
      end
      else exp = prev.value + 20;

      if(exp != field2.value) begin
        failed = 1;
        $display("*** UVM TEST FAILED for %s field2, expected value %0d, got %0d", get_full_name(), exp, field2.value);
      end

      if(field2 == null)
         `uvm_info("Field2", "Got change to field2 to null", UVM_NONE)
      else if(prev == null)
         `uvm_info("Field2", $sformatf("Got change to field2 from null to %0d", field2.value), UVM_NONE)
      else
         `uvm_info("Field2", $sformatf("Got change to field2 from %0d to %0d",prev.value, field2.value), UVM_NONE)
    end
  endtask
endclass

//----------------------------------------------------------------------
// test
//----------------------------------------------------------------------
class test extends uvm_component;

  mycomp c1;
  mycomp c2;

  `uvm_component_utils(test)

  function new(string name, uvm_component parent = null);
    super.new(name, parent);
    c1 = new("c1", this);
    c2 = new("c2", this);
  endfunction

  cfgobj obj;
  function void build();
    c1.f1_start = 10;
    c2.f1_start = 20;

    c1.f2_start = 30;
    c2.f2_start = 40;

    set_config_int("c1","field1",10);
    set_config_int("c2","field1",20);
    obj = new(30);
    uvm_config_db#(cfgobj)::set(this,"c1","field2",obj);
    obj = new(40);
    uvm_config_db#(cfgobj)::set(this,"c2","field2",obj);
  endfunction

  task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    for(int i= 30; i<130; i+=20) begin
      #10;
      set_config_int("c1","field1",i);
      set_config_int("c2","field1",i+10);
      obj = new(i+20);
      uvm_config_db#(cfgobj)::set(this,"c1","field2",obj);
      obj = new(i+30);
      uvm_config_db#(cfgobj)::set(this,"c2","field2",obj);
    end  
    phase.drop_objection(this);
  endtask

  function void report();
    if(c1.cfg_settings != 12 || c2.cfg_settings != 12) begin
       failed = 1;
       `uvm_error("FAILED", $sformatf("Did not get the expected 12 wakeups per component, got %0d at c1 and %0d at c2", c1.cfg_settings, c2.cfg_settings))
    end
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
