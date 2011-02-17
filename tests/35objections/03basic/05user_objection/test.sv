//
//------------------------------------------------------------------------------
//   Copyright 2011 (Authors)
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

module test;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  uvm_objection myobjection = new("myobjection");

  class mycomp extends uvm_component;
    function new(string name, uvm_component parent);
      super.new(name,parent);
    endfunction
    task run;
      uvm_test_done.raise_objection(this);
      repeat(10) begin
        #1 myobjection.raise_objection(this);
        #19 myobjection.drop_objection(this);
      end
      uvm_test_done.drop_objection(this);
    endtask
  endclass

  class test extends uvm_component;
    mycomp mc1, mc2;
    int mc1_user_cnt = 0;
    int mc2_user_cnt = 0;
    int test_done_cnt = 0;

    `uvm_component_utils(test)
    function new(string name, uvm_component parent);
      super.new(name,parent);
      mc1 = new("mc1", this);
      mc2 = new("mc2", this);
    endfunction
    virtual function void raised (uvm_objection objection, 
      uvm_object source_obj, string description, int count);
      uvm_report_info("Raised", $sformatf("Raised objection %s from object %s", objection.get_name(), source_obj.get_full_name()), UVM_NONE);
      if(source_obj == mc1 && objection == myobjection)
        mc1_user_cnt++;
      if(source_obj == mc2 && objection == myobjection)
        mc2_user_cnt++;
      if(objection == uvm_test_done)
        test_done_cnt++;
    endfunction
    virtual function void dropped (uvm_objection objection,
      uvm_object source_obj, string description, int count);
      uvm_report_info("Dropped", $sformatf("Dropped objection %s from object %s", objection.get_name(), source_obj.get_full_name()), UVM_NONE);
      if(source_obj == mc1 && objection == myobjection)
        mc1_user_cnt++;
      if(source_obj == mc2 && objection == myobjection)
        mc2_user_cnt++;
      if(objection == uvm_test_done)
        test_done_cnt++;
    endfunction
    function void report();
      //Each component will do 10 raises and 10 drops of the user objection
      //and one raise/drop of test done.
      if(mc1_user_cnt != 20) $display("** UVM TEST FAILED : mc1 cnt: %0d**", mc1_user_cnt);
      if(mc2_user_cnt != 20) $display("** UVM TEST FAILED : mc2 cnt: %0d**", mc2_user_cnt);
      if(test_done_cnt != 4) $display("** UVM TEST FAILED : test_done cnt: %0d**", test_done_cnt);
      $display("** UVM TEST PASSED **");
    endfunction 
  endclass

  initial run_test();
endmodule
