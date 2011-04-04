//----------------------------------------------------------------------
//   Copyright 2007-2010 Cadence Design Systems, Inc.
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

/*
    Code for existing UVC and DUT.
*/

package uvc_pkg;
  import uvm_pkg::*;
  class transaction extends uvm_sequence_item;
    rand bit[31:0] addr;
    rand logic[31:0] data;
    rand uvm_pkg::uvm_access_e dir;
    `uvm_object_utils_begin(transaction)
      `uvm_field_int(addr, UVM_ALL_ON)
      `uvm_field_int(data, UVM_ALL_ON)
      `uvm_field_enum(uvm_pkg::uvm_access_e, dir, UVM_ALL_ON)
    `uvm_object_utils_end
    function new(string name="unnamed-transaction");
      super.new(name);
    endfunction
  endclass

  `uvm_blocking_put_imp_decl(_reg)
  
  class uvc_sequencer extends uvm_sequencer#(transaction);
    `uvm_sequencer_utils(uvc_sequencer)
    function new (string name, uvm_component parent);
      super.new(name, parent);
    endfunction : new
  endclass : uvc_sequencer

  class uvc_driver#(type T=int) extends uvm_driver#(transaction);
    uvm_analysis_port#(transaction) item_collected_port;
    T vif;
    task run_phase(uvm_phase phase);
      super.run_phase(phase);
      while(1) begin
        seq_item_port.get_next_item(req);
        vif.drive_tr(req);
        #1;
        if(req.dir==UVM_WRITE)
          `uvm_info("USRDRV", $sformatf("Write addr=%0d Data=0x%0x", req.addr, req.data), UVM_LOW)
        else
          `uvm_info("USRDRV", $sformatf("Read addr=%0d Data=0x%0x", req.addr, req.data), UVM_LOW)
        item_collected_port.write(req);
        seq_item_port.item_done();
      end
    endtask
    `uvm_component_param_utils(uvc_driver#(T))
    function new (string name, uvm_component parent);
      super.new(name, parent);
      item_collected_port=new("item_collected_port", this);
    endfunction : new
  endclass

  class uvc_env#(type T=int) extends uvm_env;
    uvc_sequencer seqr;
    uvc_driver#(T) drv;

    virtual function void build();
      super.build();
      // Create UVC sequencer
      seqr = uvc_sequencer::type_id::create("seqr", this);
      // Create UVC driver
      drv = uvc_driver#(T)::type_id::create("drv", this);
    endfunction

    virtual function void connect_phase(uvm_phase phase);
      super.connect_phase(phase);
      drv.seq_item_port.connect(seqr.seq_item_export);
    endfunction

    `uvm_component_param_utils(uvc_env#(T))
    function new(string name, uvm_component parent=null);
       super.new(name,parent);
    endfunction
  endclass
endpackage

// Below code mimics DUT
interface uvc_intf(input wire reset, reverse_reset);
  uvc_pkg::transaction tr;
  event drive_e;
  function void drive_tr(uvc_pkg::transaction req); 
    tr=req; 
    -> drive_e;
  endfunction
endinterface

module dut (uvc_intf pif);
  parameter int NUM_REGS=10;

  // Dummy Registers
  logic [31:0] myreg[0:NUM_REGS-1];

  always @(posedge pif.reset)
  begin
    uvm_pkg::uvm_report_info("DUT", "Resetting the DUT", uvm_pkg::UVM_LOW);
    foreach(myreg[i])
      if(!pif.reverse_reset) myreg[i]='h12345678;
      else myreg[i]='h87654321;
  end

  initial
  begin
    uvc_pkg::transaction tr;
    forever
    begin
      @(pif.drive_e);
      tr=pif.tr;
      if(tr.dir==uvm_pkg::UVM_WRITE)
        myreg[tr.addr/4]=tr.data;
      else
        tr.data=myreg[tr.addr/4];
    end
  end
endmodule
