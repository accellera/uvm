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
 
  int achoo;
 
  class test extends uvm_component;
    `uvm_new_func
    `uvm_component_utils(test)

    task run;
      uvm_top.set_config_int("*","a*",10);
      void'(get_config_int("achoo", achoo));
      $display("achoo: %0d", achoo);
      if(achoo != 10) $display("*** UVM TEST FAILED ***");
      else $display("*** UVM TEST PASSED ***");
    endtask
  endclass

  initial run_test();
endmodule
