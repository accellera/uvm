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
 
`include "vmm_producers.sv"
`include "uvm_consumers.sv"
`include "apb_scoreboard.sv"

//------------------------------------------------------------------------------
//
// Example: avt_notify2analysis example
//
// This example shows how to use the <avt_notify2analysis> adapter to connect
// a VMM xactor that passes transactions via event notifications to an
// UVM analysis subscriber.
//
// (see avt_notify2analysis.gif)
//
// When constructing the adapter, we pass it the VMM xactor's notify object and
// the notification descriptor, on which the adapter registers a callback. When
// the VMM xactor indicates the event with status, the callback is called,
// which forwards the received transaction to the adapter. The adapter then
// converts the transaction to UVM and publishes it to any connected UVM
// subscribers via its analysis port. An alternate implementation could have
// defined the callback to hold a handle the analysis port and write to the
// port without involving the adapter.
// 
// (inline source)
//------------------------------------------------------------------------------

class env extends uvm_component;

  vmm_notifier  #(vmm_apb_rw) v_prod;
  uvm_subscribe #(uvm_apb_rw) o_cons;
  apb_notify2analysis         v_to_o;
  apb_scoreboard              compare;
  vmm_apb_rw                  tmp;
  
  function new(string name, uvm_component parent=null);
    super.new(name,parent);
  endfunction

  virtual function void build();
    v_prod   = new("v_prod");
     o_cons   = new("o_cons",this);
    v_to_o   = new("v_to_o",this,v_prod.notify,v_prod.GENERATED);
    compare  = new("comparator", this, v_prod.out_chan,1);
   endfunction

  virtual function void connect();
    v_to_o.analysis_port.connect(o_cons.analysis_export);
    o_cons.ap.connect(compare.uvm_in);
  endfunction

  virtual task run();
    v_prod.start_xactor();
  endtask

  virtual function void report();
    super.report();
    if(compare.m_matches > 0 && compare.m_mismatches == 0)
      uvm_report_info("Comparator","Simulation PASSED");
    else
      uvm_report_error("Comparator","Simulation FAILED");
  endfunction // report

endclass


module example_12_notify2analysis;

  env e = new("env");  

  initial run_test();

  initial #200 global_stop_request();

endmodule
