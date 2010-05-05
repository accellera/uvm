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


module test;

  import uvm_pkg::*;
  `include "uvm_macros.svh"

  // In this test the leaf executes 5 sequences of 
  // raise->delay->raise->delay->raise->delay->drop(3). 
  //
  class base extends uvm_component;
    function new(string name, uvm_component parent);
      super.new(name,parent);
    endfunction
    virtual function void raised (uvm_objection objection, uvm_object source_obj, string description, int count);
      uvm_report_info(get_full_name(), $sformatf("raised: local total count is %0d", objection.get_objection_total(this)), UVM_NONE);
    endfunction
    virtual function void dropped (uvm_objection objection, uvm_object source_obj, string description, int count);
      uvm_report_info(get_full_name(), $sformatf("dropped: local total count is %0d", objection.get_objection_total(this)), UVM_NONE);
    endfunction
    virtual task all_dropped (uvm_objection objection, uvm_object source_obj, string description, int count);
      uvm_report_info("AllDropped", $sformatf("%0s all objections dropped from %0s : local total count is %0d", objection.get_name(), source_obj.get_full_name(), objection.get_objection_total(this)), UVM_NONE);
    endtask
  endclass

  class C extends base;
    int del;
  
    function new(string name, uvm_component parent);
      super.new(name,parent);
    endfunction
    task run;
      repeat(5) begin
      $display;
        uvm_test_done.raise_objection(this);
      $display;
        #del uvm_test_done.raise_objection(this);
      $display;
        #del uvm_test_done.raise_objection(this);
      $display;
        #del uvm_test_done.drop_objection(this,"drop multi",3);
      end
    endtask
  endclass
  
  class B extends base;
    C c1;
  
    function new(string name, uvm_component parent);
      super.new(name,parent);
      c1 = new("c1", this);
      c1.del = 5; 
    endfunction
    task run;
    endtask
  endclass
  
  class test extends base;
    int test_raises=0;
    int del;
    B b1;
  
    `uvm_component_utils(test) 
    function new(string name, uvm_component parent);
      super.new(name,parent);
      b1 = new("b1", this);
    endfunction
    task run;
        uvm_test_done.raise_objection(this);
        #50 uvm_test_done.drop_objection(this);
    endtask

    virtual function void raised (uvm_objection objection, uvm_object source_obj, string description, int count);
      super.raised(objection,source_obj, description, count);
      uvm_report_info({source_obj.get_full_name(), "-RAISED"}, "Got raise", UVM_NONE);
    endfunction
    virtual function void dropped (uvm_objection objection, uvm_object source_obj, string description, int count);
      super.dropped(objection,source_obj, description, count);
      uvm_report_info({source_obj.get_full_name(), "-DROPPED"}, "Got drop", UVM_NONE);
    endfunction
    virtual function void report();
      //since all raises are in the same delta as the previous drops, should only
      //see the first raise/drop from each component.
      //7 total component instances, so 7 raises should be seen.
      if(test_raises > 20) begin
        $display("** UVM TEST FAILED raises: %0d exp: <20 **", test_raises);
        return;
      end
      if($time > 1000) begin
        $display("** UVM TEST FAILED time: %0t exp: <1000 **", test_raises);
        return;
      end
        $display("** UVM TEST PASSED **");
    endfunction
  endclass

  initial begin
    run_test();
  end
endmodule
