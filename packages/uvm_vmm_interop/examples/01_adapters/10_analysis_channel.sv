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
`include "uvm_consumers.sv"
`include "vmm_consumers.sv"
`include "apb_scoreboard.sv"


//------------------------------------------------------------------------------
//
// Example: avt_analysis_channel example
//
// This example shows how to use the <vmm_analysis_adapter> to connect VMM
// xactors to UVM components with analysis ports and exports.
//
// Two modes of connection are possible.
//
// - UVM publisher -> VMM consumer - 
//   The UVM publisher broadcasts an UVM transaction to the adapter, which is
//   serving as an UVM subscriber. The adapter converts the transaction
//   to its VMM counterpart and sneaks it into the VMM consumer's input channel.
//
// - VMM generator -> UVM subscriber -
//   The VMM generator puts VMM transactions into its output channel. The
//   adapter, having a handle to the same channel, continually gets transactions,
//   converts them to their UVM counterpart, and broadcasts them to all UVM
//   subscribers. In this case, the adapter is serving as the UVM publisher.
//
// (see avt_analysis_channel.gif)
//
// (inline source)
//------------------------------------------------------------------------------

class example extends uvm_component;

  // UVM source -> VMM sink
  uvm_publish #(uvm_apb_rw) o_publ;
  vmm_consumer #(vmm_apb_rw)v_cons;
  apb_analysis_channel      o_to_v;
  apb_scoreboard            comp_o2v;

  // VMM source -> UVM sink
  vmm_apb_rw_atomic_gen       v_prod;
  uvm_subscribe #(uvm_apb_rw) o_subs;
  apb_analysis_channel        v_to_o;
  apb_scoreboard              comp_v2o;

  bit PASS  = 0;

  function new(string name, uvm_component parent=null);
    super.new(name,parent);
  endfunction

  virtual function void build();

    o_publ   = new("o_prod",this);
    v_cons   = new("v_cons");
    o_to_v   = new("o_to_v",this, v_cons.in_chan); 
    comp_o2v = new("comp_o2v",this,v_cons.in_chan);

    v_prod   = new("v_prod");
    o_subs   = new("o_cons",this);
    v_to_o   = new("v_to_o",this, v_prod.out_chan); 
    comp_v2o = new("comp_v2o",this,v_prod.out_chan);
    
    v_prod.stop_after_n_insts  = 1;

  endfunction

  virtual function void connect();
    o_publ.out.connect(o_to_v.analysis_export);
    v_to_o.analysis_port.connect(o_subs.analysis_export);
    o_publ.out.connect(comp_o2v.uvm_in);
    v_to_o.analysis_port.connect(comp_v2o.uvm_in);
  endfunction

  virtual task run();
    uvm_report_info("uvm2vmm","UVM publisher to VMM consumer");
    v_cons.start_xactor();
    #10;
    uvm_report_info("vmm2uvm","VMM atomic_gen to UVM subscriber");
    v_prod.start_xactor();
  endtask

  virtual function void check();
    if(comp_v2o.m_matches == 1 && comp_v2o.m_mismatches == 0 &&
       comp_o2v.m_matches == 1 && comp_o2v.m_mismatches == 0)
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


module example_10_analysis_channel;

  example env = new("env");

  initial run_test();

  initial #200 global_stop_request();

endmodule
