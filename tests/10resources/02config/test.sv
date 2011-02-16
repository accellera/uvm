//----------------------------------------------------------------------
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


//----------------------------------------------------------------------
// This example illustrates backward compatibility between the new
// resources facility and the old set_config/get_config facility.
//----------------------------------------------------------------------

import uvm_pkg::*;
`include "uvm_macros.svh"

bit test_error = 0;

//----------------------------------------------------------------------
// leaf
//----------------------------------------------------------------------
class leaf extends uvm_component;

  int A;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction
  
  function void build();
    // set A to a pseudo-default value.  If get_config_int fails then A
    // will have the value of 39
    A = 39;
    if(!get_config_int("A", A)) begin
      `uvm_error("TESTERROR", "Did not get setting for A");
      test_error = 1;
    end
    $display("%s: A = %0d", get_full_name(), A);
  endfunction

  function void check();

    string msg;

    // Check to see if the value of A is correct based on the calls to
    // set_config_int made in ancestor component.

    // All leaves in scopes *.c2* must have A set to 7
    if((uvm_re_match(uvm_glob_to_re("*.c2*"), get_full_name()) == 0) && A != 7) begin
      $sformat(msg, "A = %0d, it should be 7", A);
      `uvm_error("TESTERROR", msg);
      test_error = 1;
    end
    else
      // Leaves in scopes other than *.c2* have A set to 11
      if((uvm_re_match(uvm_glob_to_re("*.c2*"), get_full_name()) != 0) && A != 11) begin
        $sformat(msg, "A = %0d, it should be 11", A);
        `uvm_error("TESTERROR", msg);
        test_error = 1;
      end
  endfunction

endclass

//----------------------------------------------------------------------
// component
//----------------------------------------------------------------------
class component extends uvm_component;

  leaf l1;
  leaf l2;

  int A;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build();
    l1 = new("leaf1", this);
    l2 = new("leaf2", this);

    // This is the default value of A for all the leaves (*.leaf*)
    set_config_int("*", "A", 11);

    // What's the value in THIS component?
    void'(get_config_int("A", A));
  endfunction

  function void check();

   string msg;

    // in *.c1 the value must be 5
    if((uvm_re_match(uvm_glob_to_re("*.c1"), get_full_name()) == 0) && A != 5) begin
      $sformat(msg, "A = %0d, it should be 5", A);
      `uvm_error("TESTERROR", msg);
      test_error = 1;
    end
    else
      // in *.c2* the value must be 7
      if((uvm_re_match(uvm_glob_to_re("*.c2*"), get_full_name()) == 0) && A != 7) begin
        $sformat(msg, "A = %0d, it should be 7", A);
        `uvm_error("TESTERROR", msg);
        test_error = 1;
      end
  endfunction

endclass

//----------------------------------------------------------------------
// env
//----------------------------------------------------------------------
class env extends uvm_component;

  component c1, c2, c23;

  function new(string name, uvm_component parent = null);
    super.new(name, parent);
  endfunction

  function void build();

    c1 = new("c1", this);
    c2 = new("c2", this);
    c23 = new("c23", this);

    // set resource named A in component c1
    set_config_int("c1", "A", 5);

    // set resource named A in any component whose name has a prefix of
    // c2.  This overrides the default set in the child of env
    set_config_int("c2*", "A", 7);
  endfunction

endclass

//----------------------------------------------------------------------
// test
//
// Top-level test
//----------------------------------------------------------------------
class test extends uvm_component;

  `uvm_component_utils(test)

  env e;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build();
    e = new("env", this);
  endfunction


  function void report();
    // We print the configuration datbase just for reference.  The
    // result does not affect whether or not the test passes.
    print_config(1);

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


