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

  class test extends uvm_test;
    `uvm_new_func
    `uvm_component_utils(test)

    task run;
      `uvm_info("SinglePercent", "This is a message with a single % sign in it", UVM_NONE)
      `uvm_info("PercentPercent", "This is a message with a %% in it", UVM_NONE)
      $display("*** UVM TEST PASSED ***");
    endtask

  endclass

  initial run_test();
endmodule
