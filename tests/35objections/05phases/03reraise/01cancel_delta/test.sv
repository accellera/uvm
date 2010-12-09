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

// Each level has a loop of 5 raise->delay->drop sequences. The reraise
// after a drop happens in the same delta. Because of this the leaf
// components will only generate one raise/drop each but all intermediate
// nodes will generate 5 raise and drops.

module top;

  import uvm_pkg::*;
  `include "uvm_macros.svh"

  class base extends uvm_component;
    int base_raises = 0;
    function new(string name, uvm_component parent);
      super.new(name,parent);
    endfunction
    virtual function void raised (uvm_objection objection, uvm_object source_obj, string description, int count);
      //Ignore implicit run phase objection
      if(objection == run_ph.phase_done) return;

      base_raises++;
      if(source_obj == this)
        uvm_report_info(get_full_name(), $sformatf("%0s raised: local total count is %0d", get_full_name(), objection.get_objection_total(this)), UVM_NONE);
    endfunction
    virtual function void dropped (uvm_objection objection, uvm_object source_obj, string description, int count);
      //Ignore implicit run phase objection
      if(objection == run_ph.phase_done) return;

      if(source_obj == this)
        uvm_report_info(get_full_name(), $sformatf("%0s dropped: local total count is %0d", get_full_name(), objection.get_objection_total(this)), UVM_NONE);
    endfunction
    virtual task all_dropped (uvm_objection objection, uvm_object source_obj, string description, int count);
      //Ignore implicit run phase objection
      if(objection == run_ph.phase_done) return;

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
        uvm_test_done.raise_objection(this);
        #del uvm_test_done.drop_objection(this);
      end
    endtask
  endclass
  
  class B extends base;
    int del;
    C c1, c2;
  
    function new(string name, uvm_component parent);
      super.new(name,parent);
      c1 = new("c1", this);
      c2 = new("c2", this);
      c1.del = 5; c2.del = 7;
    endfunction
    task run;
      repeat(5) begin
        uvm_test_done.raise_objection(this);
        #del uvm_test_done.drop_objection(this);
      end
    endtask
  endclass
  
  class test extends base;
    int del;
    B b1, b2;
    int test_raises=0;
 
    `uvm_component_utils(test) 
    function new(string name, uvm_component parent);
      super.new(name,parent);
      b1 = new("b1", this);
      b2 = new("b2", this);
      b1.del = 5; b2.del = 7;
    endfunction
    task run;
      repeat(5) begin
        uvm_test_done.raise_objection(this);
        #5 uvm_test_done.drop_objection(this);
      end
    endtask

    virtual function void raised (uvm_objection objection, uvm_object source_obj, string description, int count);
      //Ignore implicit run phase objection
      if(objection == run_ph.phase_done) return;

      super.raised(objection,source_obj, description, count);
      test_raises++;
      uvm_report_info({source_obj.get_full_name(), "-RAISED"}, "Got raise", UVM_NONE);
    endfunction
    virtual function void dropped (uvm_objection objection, uvm_object source_obj, string description, int count);
      //Ignore implicit run phase objection
      if(objection == run_ph.phase_done) return;

      super.dropped(objection,source_obj, description, count);
      uvm_report_info({source_obj.get_full_name(), "-DROPPED"}, "Got drop", UVM_NONE);
    endfunction

    virtual function void report();
      //since all raises are in the same delta as the previous drops, should only
      //see the first raise/drop from each component.
      //7 total component instances, so 6 raises should be seen from lower comps
      //and 5 from this comp. Since this is all happening in deltas, it is possible
      //for some drops to not cancel.
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
