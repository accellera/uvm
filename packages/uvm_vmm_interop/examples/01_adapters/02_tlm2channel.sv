//------------------------------------------------------------------------------
// Copyright 2008 Mentor Graphics Corporation
// All Rights Reserved Worldwide
// 
// Licensed under the Apache License, Version 2.0 (the "License"); you may
// not use this file except in compliance with the License.  You may obtain
// a copy of the License at
// 
//        http://www.apache.org/licenses/LICENSE-2.0
// 
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
// WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.  See the
// License for the specific language governing permissions and limitations
// under the License.
//------------------------------------------------------------------------------
`define UVM_ON_TOP

`include "uvm_vmm_pkg.sv"
 
`include "uvm_apb_rw.sv"
`include "vmm_apb_rw.sv"
`include "apb_rw_converters.sv"

`include "uvm_producers.sv"
`include "vmm_consumers.sv"
`include "apb_scoreboard.sv"


//------------------------------------------------------------------------------
//
// Example: avt_uvm_tlm2channel example
//
// This example uses an <avt_uvm_tlm2channel> adapter to connect an UVM producer
// (generator) to a VMM consumer (driver). With this adapter, any UVM producer
// component that outputs transactions via any flavor of the TLM put interfaces
// can be connected to any any VMM consumer xactor that uses a vmm_channel to
// obtain transactions.
//
// (see avt_uvm_tlm2channel_put.gif)
//
// (inline source)
//------------------------------------------------------------------------------

class env extends uvm_component;

  `uvm_component_utils(env)

  uvm_producer #(uvm_apb_rw)      o_prod;
  vmm_consumer #(vmm_apb_rw)      v_cons;
  apb_uvm_tlm2channel                 put_adapter;
  apb_scoreboard                  compare;
  
  bit PASS  = 0;
  
  function new (string name="env",uvm_component parent=null);
    super.new(name,parent);
  endfunction

  virtual function void build();
    o_prod       = new("o_prod", this);
    v_cons       = new("v_cons",0);
    put_adapter  = new("put_adapter",this,v_cons.in_chan);
    compare      = new("comparator", this, v_cons.in_chan);
  endfunction

  virtual function void connect();
    o_prod.blocking_put_port.connect(put_adapter.put_export);
    put_adapter.request_ap.connect(compare.uvm_in);
  endfunction

  virtual task run();
    v_cons.start_xactor();
    @(v_cons.num_insts == 5);
    uvm_top.stop_request();
  endtask // run

  virtual function void check();
    if(compare.m_matches == 5 && compare.m_mismatches == 0)
      PASS  = 1;
  endfunction // check

  virtual function void report();
    if(PASS == 1) begin
      //OVM2UVM> `UVM_REPORT_INFO("PASS","Test PASSED");
      `uvm_info("PASS","Test PASSED", UVM_MEDIUM);  //OVM2UVM> 
    end
    else begin
      //OVM2UVM> `UVM_REPORT_ERROR("FAIL","Test FAILED");
      `uvm_error("FAIL","Test FAILED");
    end
  endfunction // report
  
endclass


module example_02_uvm_tlm2channel;

  env e = new;

  initial run_test();

endmodule
