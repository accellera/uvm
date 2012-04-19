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
 
  int value;
  int failed=0;

  typedef uvm_resource_db#(int) int_rsrc;

  class test extends uvm_component;
    `uvm_new_func
    `uvm_component_utils(test)

    task run;
      int_rsrc::set("m", "value", 55);
    
      void'(int_rsrc::read_by_name("at_end_m", "value", value));
      if(value == 55) begin
        $display("*** UVM TEST FAILED : got at_end_m for m ***");
        failed = 1;
      end

      value = 0;
      void'(int_rsrc::read_by_name("m_begin", "value", value));
      if(value == 55) begin
        $display("*** UVM TEST FAILED : got m_begin for m ***");
        failed = 1;
      end
      if(!failed) $display("*** UVM TEST PASSED ***");
    endtask
  endclass

  initial begin
    run_test();
  end
endmodule
