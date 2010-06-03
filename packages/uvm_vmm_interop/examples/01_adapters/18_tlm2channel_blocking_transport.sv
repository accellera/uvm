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
// Example: 
//
// This example uses an <vmm_channel_adapter> to connect an UVM producer
// (generator) to a VMM consumer (driver). 
//
//
// (inline source)
//------------------------------------------------------------------------------
class my_apb_scoreboard extends apb_scoreboard;
  function new(string name = "apb_scoreboard",
               uvm_component parent=null,
               vmm_channel_typed #(vmm_apb_rw) vmm_fifo = null);
     super.new(name, parent, vmm_fifo);
  endfunction : new

  virtual task run();
    uvm_apb_rw o, v2o=new();
    vmm_apb_rw v;
    
    forever begin
      uvm_fifo.get(o);
      vmm_fifo.get(v);
      
      v2o = apb_rw_convert_vmm2uvm::convert(v);
      //Every transaction is restricted to READ to check the response
      //transaction
      o.data='hdeadbeef;

      if(!o.compare(v2o)) begin
        uvm_report_error("mismatch",
                         {"UVM:\n", o.convert2string(),"\n",
                          "VMM:\n", v.psdisplay()});
        m_mismatches++;
      end
      else begin
        uvm_report_info("match",o.convert2string());
        m_matches++;
      end
    end
  endtask
endclass


class env extends uvm_component;

  `uvm_component_utils(env)

  uvm_blocking_transport_producer       o_prod;
  vmm_pipelined_consumer #(vmm_apb_rw)  v_cons;
  apb_uvm_tlm2channel                 the_adapter0;
  my_apb_scoreboard                  comp;
  
  bit PASS  = 0;
  
  function new (string name="env",uvm_component parent=null);
    super.new(name,parent);
  endfunction

  virtual function void build();
    o_prod       = new("o_prod", this);
    v_cons       = new("v_cons",0);
    the_adapter0 = new("the_adapter0", this ,v_cons.req_chan, v_cons.rsp_chan, 0);
    comp         = new("Comparator", this, v_cons.rsp_chan);
  endfunction

  virtual function void connect();
    o_prod.blocking_transport_port.connect(the_adapter0.blocking_transport_export);
    the_adapter0.request_ap.connect(comp.uvm_in);
  endfunction

  virtual task run();
    v_cons.start_xactor();
    @(v_cons.num_insts == 5);
    uvm_top.stop_request();
  endtask // run

  virtual function void check();
    if(comp.m_matches == 5 && comp.m_mismatches == 0)
      PASS  = 1;
  endfunction // check

  virtual function void report();
   `uvm_info("TEST_RESULT",((PASS==1)?"PASSED":"FAILED"), UVM_MEDIUM)
  endfunction // report
  
endclass


module example_18_uvm_tlm2channel_blocking_transport;

  env e = new;

  initial run_test();

endmodule
