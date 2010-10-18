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

  class simple_driver extends uvm_component;
    int i = 0;
    function new (string name, uvm_component parent);
      super.new(name, parent);
    endfunction : new
    `uvm_component_utils(simple_driver)
    task run();
    uvm_report_info("DRIVER_STARTED",{"Driver '",get_full_name(),"' started;",
      " will raise an objection but never drop it"});
      uvm_test_done.raise_objection(this);
      repeat(i) #10;
      //uvm_test_done.drop_objection(this);
    endtask: run
  endclass : simple_driver

  class test extends uvm_test;
    simple_driver drv1, drv2, drv3;
    `uvm_component_utils(test)
    function new (string name, uvm_component parent);
      super.new(name, parent);
    endfunction : new
    function void build();
      super.build();
      drv1 = new("drv1", this); drv2 = new("drv2", this); drv3 = new("drv3", this);
      drv1.i = 1; drv2.i = 2; drv3.i = 3;
    endfunction
    function void report();
      if($time != 100) begin
        $display("** UVM TEST FAILED time: %0t  exp: 100 **", $time);
        return;
      end
      $display("** UVM TEST PASSED **");
    endfunction
  endclass : test

  initial begin
    run_test("test");
  end

  initial
    #100 uvm_test_done.force_stop();

endmodule
