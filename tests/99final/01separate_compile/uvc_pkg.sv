//----------------------------------------------------------------------
//   Copyright 2007-2011 Cadence Design Systems, Inc.
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
    rand bit[31:0] data;
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
    T vif;
    task run();
      while(1) begin
        seq_item_port.get_next_item(req);
        vif.drive_tr(req);
        #1 `uvm_info("USRDRV", $sformatf("Received following transaction :\n%0s",
          req.sprint()), UVM_LOW)
        seq_item_port.item_done();
      end
    endtask
    `uvm_component_param_utils(uvc_driver#(T))
    function new (string name, uvm_component parent);
      super.new(name, parent);
    endfunction : new
  endclass

  class uvc_env#(type T=int) extends uvm_env;
    uvc_sequencer uos;
    uvc_driver#(T) uod;

    virtual function void build();
      super.build();
      // Create UVC sequencer
      uos = uvc_sequencer::type_id::create("uos", this);
      // Create UVC driver
      uod = uvc_driver#(T)::type_id::create("uod", this);
    endfunction

    virtual function void connect();
      uod.seq_item_port.connect(uos.seq_item_export);
    endfunction

    `uvm_component_param_utils(uvc_env#(T))
    function new(string name, uvm_component parent=null);
       super.new(name,parent);
    endfunction
  endclass
endpackage

// Below code mimics DUT
interface uvc_intf();
  uvc_pkg::transaction tr;
  event drive_e;
  function void drive_tr(uvc_pkg::transaction req); 
    tr=req; 
    -> drive_e;
  endfunction
endinterface

module dut(uvc_intf pif);
  parameter NUM_REGS=`NUM_REGS;

  // Dummy Registers
  logic [31:0] myreg[0:NUM_REGS-1];

  function void reset();
    foreach(myreg[i])
      myreg[i]='h12345678;
  endfunction

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
