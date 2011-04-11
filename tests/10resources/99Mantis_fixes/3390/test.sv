//---------------------------------------------------------------------- 
//   Copyright 2011 Cadence Design Systems, Inc.
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

  class test extends uvm_test;
    `uvm_new_func
    `uvm_component_utils(test)

    task run_phase(uvm_phase phase);
      int v;
      byte v2;
      bit v3;
      bit failed = 0;

      phase.raise_objection(this);

      uvm_resource_db#(int)::set("","value",31);
      uvm_resource_db#(byte)::set("","value",'hff);
      uvm_resource_db#(bit)::set("","value",0);

      if(!uvm_resource_db#(int)::read_by_name("","value",v)) begin
        $display("*** UVM TEST FAILED didn't get int value ***");
        failed = 1;
      end
      if(v != 31) begin
        $display("*** UVM TEST FAILED expected int value 10, got %0d ***", v);
        failed = 1;
      end

      if(!uvm_resource_db#(byte)::read_by_name("","value",v2)) begin
        $display("*** UVM TEST FAILED didn't get byte value ***");
        failed = 1;
      end
      if(v2 != 'hff) begin
        $display("*** UVM TEST FAILED expected byte value 'hff, got %0d ***", v2);
        failed = 1;
      end

      if(!uvm_resource_db#(bit)::read_by_name("","value",v3)) begin
        $display("*** UVM TEST FAILED didn't get bit value ***");
        failed = 1;
      end
      if(v3 != 0) begin
        $display("*** UVM TEST FAILED expected bit value 0, got %0d ***", v3);
        failed = 1;
      end

      if(!failed)
        $display("*** UVM TEST PASSED ***");

      phase.drop_objection(this);
    endtask

endclass

initial
  run_test("test");

endmodule
