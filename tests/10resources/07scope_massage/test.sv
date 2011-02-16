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

import uvm_pkg::*;
`include "uvm_macros.svh"

// global tests status bit
bit test_error = 0;


class env extends uvm_component;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  task run(); 

    // The input string to each call of test_massage represents the
    // scope passed in by set_config_*.  The return value represents the
    // effective scope used by the resources facility.  The input and
    // output are globs, not "pure" regular expressions.
    
    //           -- input --     -- expected return value --
    test_massage("",             {"^$"});
    test_massage("*",            {get_full_name(), ".*"});
    test_massage("a.b.c",        {get_full_name(), ".a.b.c"});
    test_massage("uvm_test_top", "uvm_test_top");
    test_massage(".q.r",         {get_full_name(), ".q.r"});

    test_match("^a$", "a", 1);
    test_match("^a$", "aaaa", 0);
    test_match("^m$", "m_begin", 0);
    test_match("^m$", "at_end_m", 0);
    test_match("^m$", "m", 1);

  endtask

  function void test_massage(string s, string expected);
    string t = massage_scope(s);
    bit err = (t != expected);

    $write("[%s] scope \"%s\" ->\"%s\"", (err?"ERR":"OK"), s, massage_scope(s));
    if(err)
      $display(" -- expected \"%s\"", expected);
    else
      $display();
    test_error |= err;    
  endfunction

  function void test_match(string re, string str, bit expected_match);
    int err = uvm_re_match(re, str);

    // expected_match == 0 means we don't expect the string to match
    // the regular expression.  expected_match == 1 means we do expect
    // the string to match the regular expression
    if(!expected_match)
      err = !err;

    $display("[%s] scope \"%s\" %s \"%s\"", (err?"ERR":"OK"), re,
             (expected_match?"matches":"does not match"), str);
    test_error |= (err != 0);
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
  endfunction

  function void report();
    // We print the configuration datbase just for reference.  The
    // result does not affect whether or not the test passes.
    uvm_resources.dump();
    uvm_resources.dump_get_records();

    if(test_error)
      $display("** UVM TEST FAIL **");
    else
      $display("** UVM TEST PASSED **");
  endfunction

endclass


module top;

  initial run_test();

endmodule
