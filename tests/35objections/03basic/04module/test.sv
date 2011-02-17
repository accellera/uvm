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
`timescale 1ns/1ns
module mb_test;

  // This is an example of using the objection mechanism from a module scope.
  // Note:  Can still set the drain time for uvm_top!

  import uvm_pkg::*;

  initial begin     
    uvm_test_done_objection tdo;
    tdo = uvm_test_done_objection::get();
    tdo.set_drain_time(uvm_top, 93);     
    //AK wait(run_ph.get_state() == UVM_PHASE_EXECUTING); //make sure we are in the run phase
    tdo.raise_objection();
    #200;
    tdo.drop_objection();
  end


endmodule

module vtest;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  //for the test infrastructure
  class test extends uvm_component;
    `uvm_component_utils(test)
    function new(string name, uvm_component parent);
      super.new(name, parent);
    endfunction
    function void report();
      //module mb_test will run to 200 then cause shut-down 
      if($time == 293) $display("** UVM TEST PASSED **");
      else $display("** UVM TEST FAILED **");
    endfunction 
  endclass

  initial
    run_test();
endmodule
