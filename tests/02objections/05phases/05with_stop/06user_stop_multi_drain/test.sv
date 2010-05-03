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
      uvm_report_info("simple_driver", "Starting run task...", UVM_NONE);
      uvm_test_done.raise_objection(this);
      repeat(i) #10;
      uvm_test_done.drop_objection(this);
      uvm_report_info("simple_driver", "Ending run task...", UVM_NONE);
    endtask: run
  endclass : simple_driver

  class simple_stop_driver extends uvm_component;
    int i = 0;
    function new (string name, uvm_component parent);
      super.new(name, parent);
    endfunction : new
    `uvm_component_utils(simple_driver)
    task run();
      uvm_report_info("stop_driver", "Starting run task...", UVM_NONE);
      enable_stop_interrupt++;
      repeat(i) #10;
      enable_stop_interrupt--;
      uvm_report_info("stop_driver", "Ending run task...", UVM_NONE);
    endtask: run
    task stop(string ph_name);
      uvm_report_info("StopTask", $sformatf("Starting stop task with enable_stop_interrupt = %0d", enable_stop_interrupt), UVM_NONE);
      wait(enable_stop_interrupt == 0);
      uvm_report_info("StopTask", $sformatf("Ending stop task with enable_stop_interrupt = %0d", enable_stop_interrupt), UVM_NONE);
    endtask: stop
  endclass : simple_stop_driver

  class simple_env extends uvm_env;
    simple_driver drv1, drv2, drv3;
    simple_stop_driver sdrv1, sdrv2;
    function new (string name, uvm_component parent);
      super.new(name, parent);
      uvm_test_done.set_drain_time(this, 15);
    endfunction : new
    `uvm_component_utils(simple_env)
    function void build();
      super.build();
      drv1 = new("drv1", this); drv2 = new("drv2", this); drv3 = new("drv3", this);
      drv1.i = 1; drv2.i = 2; drv3.i = 3;
      sdrv1 = new("sdrv1", this); sdrv2 = new("sdrv2", this);
      sdrv1.i = 1; sdrv2.i = 5;
    endfunction
  endclass : simple_env

  class test extends uvm_test;
    simple_env env1, env2;
    function new (string name, uvm_component parent);
      super.new(name, parent);
      uvm_test_done.set_drain_time(this, 50);
    endfunction : new
    `uvm_component_utils(test)
    function void build();
      super.build();
      env1 = new("env1", this);
      env2 = new("env2", this);
      enable_stop_interrupt=1;
    endfunction
    function void start_of_simulation();
      this.print();
    endfunction
    task run;
      #15 global_stop_request();
    endtask
    int stoptime=0;
    task stop(string ph_name);
      stoptime = $time;
    endtask
    function void report;
      //The last component to finish should be sdrv2 at time 50. The
      //user calls global_stop_request at 15, but the objection will
      //hold it up until 30 and drain will hold another 15 and the
      //env drain will hold it another 50.
      if(stoptime != 95) begin
        $display("** UVM TEST FAILED stoptime: %0t, exp: 95 **", stoptime);
        return;
      end
      if($time != 95) begin
        $display("** UVM TEST FAILED time: %0t, exp: 95 **", $time);
        return;
      end
      $display("** UVM TEST PASSED **");
    endfunction
  endclass : test

  initial
    run_test("test");

endmodule
