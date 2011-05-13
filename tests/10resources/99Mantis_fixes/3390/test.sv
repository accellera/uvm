//
//------------------------------------------------------------------------------
//   Copyright 2011 Cadence
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
 
  int value;
  int failed=0;
  byte bvalue;

  class test extends uvm_component;
    `uvm_new_func
    `uvm_component_utils(test)

    task run;
       uvm_resource_db#(int)::set("","value",31);
       uvm_resource_db#(byte)::set("","value",'hfe);
       uvm_resource_db#(int)::set("","value",0);
        
       if(!uvm_resource_db#(byte)::read_by_name("","value",bvalue))
            `uvm_fatal("FAIL","*** UVM TEST FAILED : no value found for byte value  ***")
            
       if(bvalue != 'hfe) begin
        `uvm_fatal("FAIL","*** bad value found ***")
      end

      $display("*** UVM TEST PASSED ***");
    endtask
  endclass

  initial begin
    run_test();
  end
endmodule
