//------------------------------------------------------------------------------
//    Copyright 2008 Mentor Graphics Corporation
//    All Rights Reserved Worldwide
// 
//    Licensed under the Apache License, Version 2.0 (the "License"); you may
//    not use this file except in compliance with the License.  You may obtain
//    a copy of the License at
// 
//        http://www.apache.org/licenses/LICENSE-2.0
// 
//    Unless required by applicable law or agreed to in writing, software
//    distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
//    WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.  See the
//    License for the specific language governing permissions and limitations
//    under the License.
//------------------------------------------------------------------------------
`define UVM_ON_TOP

`include "uvm_macros.svh"
`include "uvm_vmm_pkg.sv"
 
`include "uvm_apb_rw.sv"
`include "vmm_apb_rw.sv"
`include "apb_rw_converters.sv"

`include "uvm_producers.sv"
`include "vmm_consumers.sv"
`include "apb_scoreboard.sv"

//------------------------------------------------------------------------------
//
// Example: avt_analysis2notify example
//
// This example shows how to use the <avt_analysis2notify> adapter to connect
// an UVM publisher to a VMM xactor that receives data via vmm_notify
// event notifications.
//
// The UVM publisher broadcasts an UVM transaction to the adapter, which is
// serving as an UVM subscriber. The adapter converts the transaction then
// indicates a pre-configured notification, passing the converted transaction
// as its status argument.
//
// There are at least two ways VMM components may choose
// to receive the transaction:
//
// - wait for the notification and call status() once the wait returns. This
//   is not recommended because multiple non-blocking broadcasts from the UVM
//   publisher can take place before the waiting process has a chance to wake
//   up. 
//
// - define and register a callback on the notification so that data is received
//   immediately. The receiver must process the transaction without blocking.
//   If this is not possible, the transaction must be cached/queued.
//
// This example applies the 2nd approach. The VMM watcher component defines a
// callback that will forward the transaction back to the watcher for
// processing.
//
// (see avt_analysis2notify.gif)
//
// When instantiating the adapter, we pass it the handle to the watcher's
// notify object and notification id. When the adapter receives an UVM
// transaction via its analysis export, it will convert the transaction to
// VMM and indicate the given notification. 
//
// (inline source)
//------------------------------------------------------------------------------

class env extends uvm_component;

  uvm_publish #(uvm_apb_rw) o_prod;
  vmm_watcher #(vmm_apb_rw) v_cons;
  apb_analysis2notify       o_to_v;
  apb_scoreboard            comp;

  bit PASS  = 0;

  function new (string name, uvm_component parent=null);
    super.new(name,parent);
  endfunction

  virtual function void build();
    o_prod  = new("o_prod",this);
    v_cons  = new("v_cons");
    o_to_v  = new("o_to_v",this, v_cons.notify, v_cons.INCOMING);
    comp    = new("scoreboard",this,v_cons.sbd_chan);
  endfunction

  virtual function void connect();
    o_prod.out.connect(o_to_v.analysis_export);
    o_prod.out.connect(comp.uvm_in);
  endfunction

  virtual task run();
    v_cons.start_xactor();
  endtask

  virtual function void check();
    if(comp.m_matches == 1 && comp.m_mismatches == 0)
      PASS  = 1;
  endfunction // check
  
  virtual function void report();
    if(PASS == 1) begin
      //OVM2UVM> `UVM_REPORT_INFO("PASS","Test PASSED");
      `uvm_info("PASS","Test PASSED", UVM_MEDIUM);
    end
    else begin
      //OVM2UVM> `UVM_REPORT_ERROR("FAIL","Test FAILED");
      `uvm_info("FAIL","Test FAILED", UVM_MEDIUM);
    end
  endfunction // report
  
endclass


module example_11_analysis2notify;

  env e = new("env");  

  initial run_test();

  initial #100 global_stop_request();

endmodule
