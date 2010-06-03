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

`include "uvm_sequences.sv"
`include "vmm_consumers.sv"
`include "apb_scoreboard.sv"

//------------------------------------------------------------------------------
//
// Example: avt_uvm_tlm2channel seq_item example
//
// This example uses the <avt_uvm_tlm2channel> adapter to connect an UVM sequencer to
// a VMM driver type. While this example does not illustrate use of a separate
// channel for returning responses back to the requester, the adapter is
// capable of handling such a configuration. 
//
// During construction, the adapter may be given an existing channel handle to
// use. If such a handle were not provided, the adapter creates a default channel
// instance for itself.
//
// During operation, an adapter process continually pulls transaction items from
// the UVM sequencer, converts, and puts them to the request channel. This 
// triggers the VMM driver process waiting on a peek or get to resume, pick up
// the transaction and execute it.
//
// If the response channel is used, the VMM driver would then place a response in
// this channel, and a second, independent adapter process would get it from the
// channel, convert, and forward to the attached sequencer.
//
// If the VMM driver uses the original request to put response information, the
// adapter can be configured to do a reverse conversion to reflect the response
// back to the UVM sequencer/sequence via the originating request handle.
//
// (see avt_uvm_tlm2channel_seq_item.gif)
//
// In the example below, we create all the components in the build method. 
// The driver's ~num_insts~ and the sequencer's ~num_trans~ parameters are set
// using the UVM configuration facility. In the run task, we create and
// start (execute) a sequence, which returns once the configured number of
// transactions have been executed by the driver.
//
// (inline source)
//------------------------------------------------------------------------------

class virt_seqr extends uvm_component;

  `uvm_component_utils(virt_seqr)

  uvm_sequencer #(uvm_apb_item) o_seqr;
  vmm_consumer #(vmm_apb_rw)    v_cons;
  apb_uvm_tlm2channel               adapter;
  apb_scoreboard                comp;

  bit PASS  = 0;

  function new (string name="virt_sqr",uvm_component parent=null);
    super.new(name,parent);
  endfunction

  virtual function void build();
    o_seqr = new("o_seqr", this);
    v_cons = new("v_cons", 0);
    adapter  = new("adapter", this, v_cons.in_chan);
    comp    = new("scoreboard",this,v_cons.in_chan);
  endfunction

  virtual function void connect();
    adapter.seq_item_port.connect(o_seqr.seq_item_export);
    adapter.request_ap.connect(comp.uvm_in);
  endfunction

  virtual task run();
    uvm_apb_rw_sequence seq = new({o_seqr.get_full_name(),".seq"});
    v_cons.start_xactor();
    seq.start(o_seqr);
    uvm_top.stop_request();
  endtask

  virtual function void check();
    if(comp.m_matches == 5 && comp.m_mismatches == 0)
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


module example_06_sequencer2channel;

  virt_seqr vs = new;

  initial run_test();

endmodule
