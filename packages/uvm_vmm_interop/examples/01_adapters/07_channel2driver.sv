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

`include "vmm_producers.sv"
`include "uvm_consumers.sv"
`include "apb_scoreboard.sv"

//------------------------------------------------------------------------------
//
// Example: avt_channel2uvm_tlm seq_item example
//
// This example uses the <avt_channel2uvm_tlm> adapter to connect an VMM producer to
// an UVM sequence item driver. While this example does not illustrate use of a
// separate channel for returning responses back to the requester, the adapter is
// capable of handling such a configuration. 
//
// During construction, the adapter may be given an existing channel handle to
// use. If such a handle were not provided, the adapter creates a default channel
// instance for itself. A pre-allocated response channel, if used, must be
// provided by end-of-elaboration; the adapter will not create one by default.
//
// During operation, the UVM driver requests a new transaction from what it sees
// as an UVM sequencer via its seq_item_port. The adapter, serving as the
// sequencer, will attempt to get a new transaction from the request channel.
// When available, the transaction is gotten, converted, and returned to the
// UVM driver.
// 
// If the UVM driver returns explicit responses, it can do so via the ~put~
// method on the same seq_item_port. The adapter than converts and sneaks this 
// into the response channel. 
//
// If the UVM driver uses the original request to put response information, the
// adapter can be configured to do a reverse conversion to reflect the response
// back to the VMM producer via the originating request handle.
//
// (see avt_channel2uvm_tlm_seq_item.gif)
//
// In the example below, we create all the components in the build method.
// The VMM generator's ~stop_after_n_insts~ parameter is set using the UVM
// configuration facility. The run phase is ended when the atomic generator
// has indicated its DONE notification.
//
// (inline source)
//------------------------------------------------------------------------------

class env extends uvm_component;

  `uvm_component_utils(env)

  vmm_producer_1chan gen;
  apb_channel2uvm_tlm    adapt;
  uvm_driver_req     drv;
  apb_scoreboard     comp;

  bit PASS  = 0;

  function new (string name="env",uvm_component parent=null);
    super.new(name,parent);
  endfunction

  virtual function void build();
    gen   = new("gen", 0);
    adapt = new("adapt", this, gen.out_chan);
    drv   = new("drv", this);
    comp    = new("scoreboard",this,gen.out_chan);
  endfunction

  virtual function void connect();
    drv.seq_item_port.connect(adapt.seq_item_export);
    drv.ap.connect(comp.uvm_in);
  endfunction

  virtual task run();
    gen.start_xactor();
    gen.notify.wait_for(vmm_xactor::XACTOR_STOPPED);
    uvm_top.stop_request();
  endtask

  virtual function void check();
    if(comp.m_matches == 20 && comp.m_mismatches == 0)
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

module example_07_channel2driver;

  env e = new;

  initial run_test();

endmodule
