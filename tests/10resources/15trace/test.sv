//----------------------------------------------------------------------
//   Copyright 2010 Mentor Graphics Corporation
//   Copyright 2011 Mentor Graphics Corporation
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

class cfg;
  int a;
endclass

//----------------------------------------------------------------------
// leaf
//----------------------------------------------------------------------
class leaf extends uvm_component;

  int A;
  int B;
  cfg C;

  `uvm_component_utils_begin(leaf)
      `uvm_field_int(B, UVM_ALL_ON)
  `uvm_component_utils_end

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction
  
  function void build_phase(uvm_phase phase);
     super.build_phase(phase);
     if(!get_config_int("A", A)) begin
        `uvm_error("TESTERROR", "Did not get setting for A");
     end
     if(!uvm_resource_db#(cfg)::read_by_name(get_full_name(), "C", C, this)) begin
        `uvm_error("TESTERROR", "Did not get setting for C");
     end
  endfunction
endclass

//----------------------------------------------------------------------
// env
//----------------------------------------------------------------------
class env extends uvm_component;

  leaf l1;
  leaf l2;

  int A;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
     
    l1 = new("leaf1", this);
    l2 = new("leaf2", this);

    // This is the default value of A for all the leaves (*.leaf*)
    set_config_int("*", "A", 11);
    set_config_int("*", "B", -11);

    // What's the value in THIS component?
    void'(get_config_int("A", A));
  endfunction

endclass

class my_catcher extends uvm_report_catcher;
   static int seen = 0;
   static int failed = 0;
   virtual function action_e catch();
      string msg = get_message();
      int len = msg.len();
      seen++;
      if (len>14 && (msg.substr(len-15,len-1) == "(failed lookup)")) begin
        failed++;
      end
      return THROW;
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

  function void build_phase(uvm_phase phase);
    cfg c = new;
    e = new("env", this);
    uvm_resource_db#(cfg)::set("*", "C", c, this);
  endfunction

  task run_phase(uvm_phase phase);
     int a;
     uvm_resource_db#(int)::set("a", "b", 0, this);
     uvm_resource_db#(int)::set_anonymous("a", 0, this);
     void'(uvm_resource_db#(int)::read_by_name("a", "b", a, this));
     void'(uvm_resource_db#(int)::read_by_type("a", a, this));
     void'(uvm_resource_db#(int)::write_by_name("a", "b", a, this));
     void'(uvm_resource_db#(int)::write_by_type("a", a, this));
  endtask

  function void report();
     uvm_report_server svr;
     svr = _global_reporter.get_report_server();

     if (my_catcher::seen != 23) begin
        `uvm_error("TEST", $sformatf("Saw %0d messages instead of 20",
                                     my_catcher::seen))
     end

     if (my_catcher::failed != 9) begin
        `uvm_error("TEST", $sformatf("Saw %0d failed trace messages instead of 9",
                                     my_catcher::failed))
     end

     if (svr.get_severity_count(UVM_FATAL) +
         svr.get_severity_count(UVM_ERROR) == 0)
        $write("** UVM TEST PASSED **\n");
     else
        $write("!! UVM TEST FAILED !!\n");
  endfunction

endclass

//----------------------------------------------------------------------
// top
//----------------------------------------------------------------------
module top;

  initial begin
    my_catcher ctch;
    ctch = new();
    uvm_report_cb::add(null,ctch);
    run_test();
  end

endmodule


