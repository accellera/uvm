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

`include "uvm_macros.svh"
import uvm_pkg::*;

bit test_error = 0;

//----------------------------------------------------------------------
// obj
//----------------------------------------------------------------------
class obj extends uvm_object;

  int t;
  string xt;

  `uvm_object_utils_begin(obj)
    `uvm_field_int(t, UVM_DEFAULT)
    `uvm_field_string(xt, UVM_DEFAULT)
  `uvm_field_utils_end


  function new(string name="obj");
     super.new(name);
  endfunction

endclass

//----------------------------------------------------------------------
// component
//----------------------------------------------------------------------
class component extends uvm_component;

  int i;
  string s;
  obj o;

  `uvm_component_utils_begin(component)
    `uvm_field_int(i, UVM_DEFAULT)
    `uvm_field_string(s, UVM_DEFAULT)
    `uvm_field_object(o, UVM_DEFAULT)
  `uvm_field_utils_end

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build();
    // calling super.build invokes the auto config feature
    super.build();
  endfunction

  task run();

    // check to make sure all the field have been automatically
    // set to the expected values
    if(i != 7) begin
      `uvm_error("TESTERROR", "i != 7");
      test_error = 1;
    end

    if(s != "fortitude") begin
      `uvm_error("TESTERROR", "s != \"fortitude\"");
      test_error = 1;
    end

    if(o == null) begin
      `uvm_error("TESTERROR", "o is null");
      test_error = 1;
    end

    if(o != null && o.t != 19) begin
      `uvm_error("TESTERROR", "o.t != 19");
      test_error = 1;
    end

    if(o != null && o.xt != "yo!") begin
      `uvm_error("TESTERROR", "o.t != \"yo!\"");
      test_error = 1;
    end

  endtask

endclass

//----------------------------------------------------------------------
// env
//----------------------------------------------------------------------
class env extends uvm_component;

  component c;

  function new(string name, uvm_component parent = null);
    super.new(name, parent);
  endfunction

  function void build();
    obj o;

    // calling super.build here invokes the auto-config feature where
    // components that use field automation can be automatically
    // configured.
    super.build();

    c = new("c", this);
    
    o = new();
    o.t = 19;
    o.xt = "yo!";
    set_config_object("*", "o", o, 0); // no clone
    set_config_int("*", "i", 7);
    set_config_string("*", "s", "fortitude");
  endfunction

endclass

class test extends uvm_component;

  `uvm_component_utils(test)

  env e;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build();
    e = new("env", this);
    uvm_component::print_config_matches = 1;
  endfunction

  task run();
    print_config_with_audit(1);
  endtask

  function void report();
    if(test_error)
      $display("** UVM TEST FAIL **");
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
