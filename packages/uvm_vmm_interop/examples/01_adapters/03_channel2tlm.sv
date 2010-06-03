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
`include "apb_scoreboard.sv"

`include "uvm_consumers.sv"

//------------------------------------------------------------------------------
//
// Example: avt_channel2uvm_tlm example
//
// This example uses an <avt_channel2uvm_tlm> to connect an VMM producer
// (generator) to an UVM consumer. With this adapter, any VMM producer
// using a vmm_channel to inject transactions can be connected to any UVM
// consumer that uses TLM port and exports.
//
// (see avt_channel2uvm_tlm_getpeek.gif)
//
// (inline source)
//------------------------------------------------------------------------------

class env extends uvm_component;

  `uvm_component_utils(env)

  vmm_apb_rw_atomic_gen      v_prod;
  uvm_consumer #(uvm_apb_rw) o_cons;
  apb_channel2uvm_tlm            adapter;
  apb_scoreboard             compare;

  bit PASS  = 0;
  
  function new (string name="env",uvm_component parent=null);
    super.new(name,parent);
  endfunction

  virtual function void build();
    v_prod   = new("v_prod",1);
    o_cons   = new("o_cons", this);
    adapter  = new("adapter",this,v_prod.out_chan);
    compare  = new("comparator", this,v_prod.out_chan);
    v_prod.out_chan.tee_mode(1);
  endfunction

  virtual function void connect();
    o_cons.blocking_get_port.connect(adapter.get_peek_export);
    o_cons.analysis_port.connect(compare.uvm_in);
  endfunction

  virtual task run();
    vmm_apb_rw vtr;
    v_prod.start_xactor();
    @(o_cons.num_trans == 5);
    uvm_top.stop_request();
  endtask

  virtual function void check();
    if(compare.m_matches == 5 && compare.m_mismatches == 0)
      PASS  = 1;
  endfunction // check

  virtual function void report();
    if(PASS == 1) begin
      `uvm_info("PASS","Test PASSED", UVM_MEDIUM);  
    end
    else begin
      `uvm_info("FAIL","Test FAILED", UVM_MEDIUM);
    end
  endfunction // report
  
endclass


module example_03_channel2uvm_tlm;

  env e = new;

  initial run_test();

endmodule
