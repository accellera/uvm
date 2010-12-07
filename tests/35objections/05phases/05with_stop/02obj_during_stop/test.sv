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
      //Invalid raise during stop. Don't drop it to verify that the raised objection
      //is ignored.
      uvm_test_done.raise_objection(this);
      wait(enable_stop_interrupt == 0);
      uvm_report_info("StopTask", $sformatf("Ending stop task with enable_stop_interrupt = %0d", enable_stop_interrupt), UVM_NONE);
    endtask: stop
  endclass : simple_stop_driver

  int got_illraise = 0;
  int got_objout = 0;

  class my_catcher extends uvm_report_catcher;
     virtual function action_e catch();
        if(get_id() == "ILLRAISE") begin
          got_illraise++;
        end
        if(get_id() == "OBJOUT") begin
          got_objout++;
        end
        return THROW;
     endfunction
  endclass
  my_catcher ctchr = new;

  class test extends uvm_test;
    simple_driver drv1, drv2, drv3;
    simple_stop_driver sdrv1, sdrv2;
    function new (string name, uvm_component parent);
      super.new(name, parent);
      enable_stop_interrupt=1;
    endfunction : new
    `uvm_component_utils(test)
    function void build();
      super.build();
      drv1 = new("drv1", this); drv2 = new("drv2", this); drv3 = new("drv3", this);
      drv1.i = 1; drv2.i = 2; drv3.i = 3;
      sdrv1 = new("sdrv1", this); sdrv2 = new("sdrv2", this);
      sdrv1.i = 1; sdrv2.i = 5;
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
      //The last component to finish should be sdrv2 at time 50
      //There should be a warning during this stop. User stop at time 15,
      //but stop doesn't happen until all objections dropped at 30.
      if(stoptime != 30) begin
        $display("** UVM TEST FAILED stoptime: %0t, exp: 30 **", stoptime);
        return;
      end
      if($time != 50) begin
        $display("** UVM TEST FAILED time: %0t, exp: 50 **", $time);
        return;
      end
      if(got_illraise != 1) begin
        $display("** UVM TEST FAILED got_illraise: %0d, exp: 1 **", got_illraise);
        return;
      end
      $display("** UVM TEST PASSED **");
    endfunction
  endclass : test

  initial begin
    uvm_report_cb::add(null,ctchr);
    run_test("test");
  end
endmodule
