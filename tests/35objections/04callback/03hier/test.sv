//----------------------------------------------------------------------
//   Copyright 2007-2009 Cadence Design Systems, Inc.
//   Copyright 2010-2011 Mentor Graphics Corporation
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
  class F extends uvm_component;
    int del;
    function new(string name, uvm_component parent);
      super.new(name,parent);
      del = ($random % 20) + 25;
    endfunction
    task run;
      repeat(20) begin
        // The #1 is to make sure nothing gets cancelled. Normally
        // cancelling is okay, but for this test I want all drops
        // propagated.
        uvm_test_done.raise_objection(this);
        #del;
        uvm_test_done.drop_objection(this);
        #1;
      end
    endtask
  endclass

  class E extends uvm_component;
    int del;
    F f1, f2;
  
    function new(string name, uvm_component parent);
      super.new(name,parent);
      f1 = new("f1", this);
      f2 = new("f2", this);
      del = ($random % 20) + 25;
    endfunction
    task run;
      repeat(20) begin
        uvm_test_done.raise_objection(this);
        #del;
        uvm_test_done.drop_objection(this);
        #1;
      end
    endtask
  endclass
  
  class D extends uvm_component;
    int del;
    E e1, e2;
  
    function new(string name, uvm_component parent);
      super.new(name,parent);
      e1 = new("e1", this);
      e2 = new("e2", this);
      del = ($random % 20) + 25;
    endfunction
    task run;
      repeat(20) begin
        uvm_test_done.raise_objection(this);
        #del;
        uvm_test_done.drop_objection(this);
        #1;
      end
    endtask
  endclass
  
  class C extends uvm_component;
    int del;
    D d1, d2;
  
    function new(string name, uvm_component parent);
      super.new(name,parent);
      d1 = new("d1", this);
      d2 = new("d2", this);
      del = ($random % 20) + 25;
    endfunction
    task run;
      repeat(20) begin
        uvm_test_done.raise_objection(this);
        #del;
        uvm_test_done.drop_objection(this);
        #1;
      end
    endtask
  endclass
  
  class B extends uvm_component;
    int del;
    C c1, c2;
  
    function new(string name, uvm_component parent);
      super.new(name,parent);
      c1 = new("c1", this);
      c2 = new("c2", this);
      del = ($random % 20) + 25;
    endfunction
    task run;
      repeat(20) begin
        uvm_test_done.raise_objection(this);
        #del;
        uvm_test_done.drop_objection(this);
        #1;
      end
    endtask
  endclass
  
  class test extends uvm_component;
    int del;
    B b1, b2;

    int cnts[string];
    int ad = 0;
 
    `uvm_component_utils(test) 
    function new(string name, uvm_component parent);
      super.new(name,parent);
      b1 = new("b1", this);
      b2 = new("b2", this);
      del = ($random % 20) + 25;
    endfunction
    task run;
      repeat(20) begin
        uvm_test_done.raise_objection(this);
        #del;
        uvm_test_done.drop_objection(this);
        #1;
      end
    endtask
    virtual function void raised (uvm_objection objection, uvm_object source_obj, string description, int count);
	string name=source_obj.get_full_name();

      uvm_report_info("Raised", $sformatf("%0s raised from %0s : local total count is %0d", objection.get_name(), source_obj.get_full_name(), objection.get_objection_total(this)), UVM_NONE);
      cnts[name]+=count;
    endfunction
    virtual function void dropped (uvm_objection objection, uvm_object source_obj, string description, int count);
	string name=source_obj.get_full_name();

      uvm_report_info("Dropped", $sformatf("%0s dropped from %0s : local total count is %0d", objection.get_name(), source_obj.get_full_name(), objection.get_objection_total(this)), UVM_NONE);
      cnts[name]+=count;
    endfunction
    virtual task all_dropped (uvm_objection objection, uvm_object source_obj, string description, int count);

      uvm_report_info("AllDropped", $sformatf("%0s all objections dropped from %0s : local total count is %0d", objection.get_name(), source_obj.get_full_name(), objection.get_objection_total(this)), UVM_NONE);
      ad++;
    endtask

    function void report();
      int total;
      if(cnts.num() != 63) begin
        $display("** UVM TEST FAILED contributers: %0d  exp: 63", cnts.num());
        return;
      end
      foreach(cnts[i]) begin
        total+=cnts[i];
        $display("%s : %0d", i, cnts[i]);
        if(cnts[i] != 40) begin
          $display("** UVM TEST FAILED for comp: %s count: %0d (exp: 40)", i, cnts[i]);
          return;
        end
      end
      if(ad != 1) begin
        $display("** UVM TEST FAILED all dropped count: %0d  exp: 1", ad);
        return;
      end
      
      $display("** UVM TEST PASSED **");
    endfunction
  endclass

  // Total component instances is 6 levels x 2 insances per level = 63. Each
  // instance does 20 raises and drops for a total of 2520 total raise/drop 
  // callbacks (1260 each). And, there should be only 1 all dropped callback.
  
  initial begin
    run_test();
  end
  initial begin
    #400 $display("______");
    uvm_test_done.display_objections();
    $display("______");
  end
endmodule
