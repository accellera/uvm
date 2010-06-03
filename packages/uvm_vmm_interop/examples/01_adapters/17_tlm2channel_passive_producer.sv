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
//
// This example uses an avt_notify2analysis and an avt_uvm_tlm2channel adapter
// to connect a vmm_notifier_consumer and an uvm_passive_producer. The
// uvm_passive_producer gets notifier through  avt_notify2analysis, then
// puts response on avt_uvm_tlm2channel back to consumer

// (see avt_uvm_tlm2channel_put.gif)
//
// (inline source)
//------------------------------------------------------------------------------
class my_apb_scoreboard extends apb_scoreboard;
  function new(string name = "my_apb_scoreboard",
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

  uvm_passive_producer #(uvm_apb_rw)      o_prod;
  vmm_notifier_consumer #(vmm_apb_rw)      v_cons;
  apb_uvm_tlm2channel                 the_adapter0;
  apb_notify2analysis		  the_adapter1;
  my_apb_scoreboard                  comp;
  
  bit PASS  = 0;
  
  function new (string name="env",uvm_component parent=null);
    super.new(name,parent);
  endfunction

  virtual function void build();
    o_prod       = new("o_prod", this);
    v_cons       = new("v_cons",0);
    the_adapter0 = new("the_adapter0",this,v_cons.in_chan);
    the_adapter1 = new("the_adapter1",this,v_cons.notify, v_cons.GENERATED);
    comp         = new("Comparator", this, v_cons.out_chan);
  endfunction

  virtual function void connect();
    the_adapter0.blocking_get_peek_port.connect(o_prod.get_peek_export);
    the_adapter0.request_ap.connect(comp.uvm_in);
    the_adapter1.analysis_port.connect(o_prod.analysis_export);
    
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


module example_17_uvm_tlm2channel_passive_producer;

  env e = new;

  initial run_test();

endmodule
