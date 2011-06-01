//----------------------------------------------------------------------
//   Copyright 2007-2010 Mentor Graphics Corporation
//   Copyright 2007-2010 Cadence Design Systems, Inc.
//   Copyright 2010-2011 Synopsys, Inc.
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


// Test derived from example: examples/simple/configuration/automated
//
// The example is not verifying the output, and the auto config of
// the associative array is broken.

`include "my_env_pkg.sv"

module top;
  import uvm_pkg::*;
  import my_env_pkg::*;

  class test extends uvm_component;
    my_env topenv;

    function new(string name, uvm_component parent);
      super.new(name,parent);
    endfunction

    `uvm_component_utils(test)

    function void build_phase(uvm_phase phase);
      //set configuration prior to creating the environment
      set_config_int("topenv.*.u1", "v", 30);
      set_config_int("topenv.inst2.u1", "v", 10);
      set_config_string("*", "myaa[foo]", "hi");
      set_config_string("*", "myaa[bar]", "bye");
      set_config_string("*", "myaa[foobar]", "howdy");
      set_config_string("topenv.inst1.u1", "myaa[foo]", "boo");
      set_config_string("topenv.inst1.u1", "myaa[foobar]", "boobah");

      topenv = new("topenv", this);
    endfunction

    function void report_phase(uvm_phase phase);
      bit failed = 0;
      // Check that the values are correct

      // v and s are configed at different levels
      if( topenv.inst1.u1.v != 30) begin
        `uvm_error("v", $sformatf("topenv.inst1.u1.v is %0d  but expected 30 (from test) ", topenv.inst1.u1.v))
        failed = 1;
      end
      if( topenv.inst1.u1.v != 30) begin
        `uvm_error("v", $sformatf("topenv.inst1.u1.v is %0d  but expected 30 (from test) ", topenv.inst1.u1.v))
        failed = 1;
      end
      if( topenv.inst1.u2.v != 5) begin
        `uvm_error("v", $sformatf("topenv.inst1.u2.v is %0d  but expected 5 (from my_env) ", topenv.inst1.u2.v))
        failed = 1;
      end
      if( topenv.inst2.u1.v != 10) begin
        `uvm_error("v", $sformatf("topenv.inst2.u1.v is %0d  but expected 10 (from test) ", topenv.inst2.u1.v))
        failed = 1;
      end
      if( topenv.inst1.u1.s != 'h10) begin
        `uvm_error("s", $sformatf("topenv.inst1.u1.s is 'h%0h  but expected 'h10 (from my_env) ", topenv.inst1.u1.s))
        failed = 1;
      end
      if( topenv.inst1.u2.s != 'h10) begin
        `uvm_error("s", $sformatf("topenv.inst1.u2.s is 'h%0h  but expected 'h10 (from my_env) ", topenv.inst1.u1.s))
        failed = 1;
      end
      if( topenv.inst2.u1.s != 0) begin
        `uvm_error("s", $sformatf("topenv.inst2.u1.s is %0d  but expected 0 (from default) ", topenv.inst2.u1.s))
        failed = 1;
      end

      // Check the string aa, myaa
      if( topenv.inst1.u1.myaa.size() != 3 ||
          topenv.inst1.u2.myaa.size() != 3 ||
          topenv.inst2.u1.myaa.size() != 3 )
      begin
        `uvm_error("myaa", "expected all myaa instances to be size 3")
        failed = 1;
      end
      if( topenv.inst1.u1.myaa["foo"] != "boo" || 
          topenv.inst1.u1.myaa["bar"] != "bye" || 
          topenv.inst1.u1.myaa["foobar"] != "boobah" ) 
      begin
        `uvm_error("myaa", $sformatf("expected topenv.inst1.u1.myaa = '{ foo:boo, bar:bye, foobar:boobah} but got '{ foo:%0s, bar: %0s, foobar: %0s}", topenv.inst1.u1.myaa["foo"], topenv.inst1.u1.myaa["bar"], topenv.inst1.u1.myaa["foobar"]))
        failed = 1;
      end
      if( topenv.inst1.u2.myaa["foo"] != "hi" || 
          topenv.inst1.u2.myaa["bar"] != "bye" || 
          topenv.inst1.u2.myaa["foobar"] != "howdy" ) 
      begin
        `uvm_error("myaa", $sformatf("expected topenv.inst1.u2.myaa = '{ foo:hi, bar:bye, foobar:howdy} but got '{ foo:%0s, bar: %0s, foobar: %0s}", topenv.inst1.u2.myaa["foo"], topenv.inst1.u2.myaa["bar"], topenv.inst1.u2.myaa["foobar"]))
        failed = 1;
      end
      if( topenv.inst2.u1.myaa["foo"] != "hi" || 
          topenv.inst2.u1.myaa["bar"] != "bye" || 
          topenv.inst2.u1.myaa["foobar"] != "howdy" ) 
      begin
        `uvm_error("myaa", $sformatf("expected topenv.inst2.u1.myaa = '{ foo:hi, bar:bye, foobar:howdy} but got '{ foo:%0s, bar: %0s, foobar: %0s}", topenv.inst2.u1.myaa["foo"], topenv.inst2.u1.myaa["bar"], topenv.inst2.u1.myaa["foobar"]))
        failed = 1;
      end

      if(failed) begin
        $display("*** UVM TEST FAILED ***");
      end
      else begin
        $display("*** UVM TEST PASSED ***");
      end
    endfunction
  endclass

  initial
    run_test();
endmodule
