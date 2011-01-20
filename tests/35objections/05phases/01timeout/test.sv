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
      uvm_test_done.raise_objection(this);
      repeat(i) #10;
    endtask: run


  endclass : simple_driver

  class test extends uvm_test;

    simple_driver drv1, drv2, drv3;

    function new (string name, uvm_component parent);
      super.new(name, parent);
    endfunction : new

    `uvm_component_utils(test)

    function void build();
      super.build();
      drv1 = new("drv1", this);
      drv2 = new("drv2", this);
      drv3 = new("drv3", this);
      drv1.i = 1;
      drv2.i = 2;
      drv3.i = 3;
    endfunction

    function void start_of_simulation();
      this.print();
    endfunction

    task run;
      set_global_stop_timeout(200);
      #1 global_stop_request();
    endtask

    task stop(string ph_name);
      wait(1);
    endtask

    function void report();
      if ($time != 201)
        $display("** UVM TEST FAILED time: %0d  exp: 200", $time);
      else
        $display("** UVM TEST PASSED **");
    endfunction
    
  endclass : test

  initial
     run_test("test");

endmodule
