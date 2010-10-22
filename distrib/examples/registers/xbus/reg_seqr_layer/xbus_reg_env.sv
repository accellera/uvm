//----------------------------------------------------------------------
//   Copyright 2007-2009 Cadence Design Systems, Inc.
//   Copyright 2010 Synopsys, Inc.
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

`ifndef XBUS_REG_TB_SV
`define XBUS_REG_TB_SV

`define DEF2STR(arg) `"arg`"

class vif_container extends uvm_object;
   `uvm_object_utils(vif_container)
   virtual interface xbus_if vif;
endclass

 
import uvm_pkg::*;
`include "xbus.svh"
`include "reg_xa0.sv"
`include "reg2xbus_adapter.sv"
`include "xbus_indirect_reg_ftdr_seq.sv"
`include "xbus_user_acp_reg.sv"


class xbus_reg_model extends reg_sys_xa0;

  `uvm_object_utils(xbus_reg_model)

  function new (string name="");
    super.new(name);
  endfunction

  virtual function void build();
    xbus_user_acp_reg_cb cb = new;
    super.build();
    uvm_callbacks#(reg_reg_xa0_xbus_rf_user_acp_reg, uvm_reg_cbs)::add(xbus_rf.user_acp_reg, cb);
    
    foreach(xbus_rf.xbus_indirect_reg[i]) begin
      xbus_indirect_reg_ftdr_seq ftdr = new(this, i);
      xbus_rf.xbus_indirect_reg[i].set_frontdoor(ftdr);
    end
  endfunction

endclass


class xbus_reg_env extends xbus_env;

  // the register model
  xbus_reg_model rdb;
  uvm_reg_predictor #(xbus_transfer) xbus2reg;
  uvm_sequencer #(uvm_reg_bus_item) reg_seqr;
  reg2xbus_adapter reg2xbus;

  `uvm_component_utils(xbus_reg_env)

  function new (string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new

  // build
  virtual function void build();
    xbus2reg = new("xbus2reg",this);
    set_config_int("slaves*", "is_active", UVM_PASSIVE);
    num_masters = 1;
    num_slaves = 1;
    super.build();
    rdb = xbus_reg_model::type_id::create("xa0", this);
    reg_seqr = uvm_sequencer #(uvm_reg_bus_item)::type_id::create("reg_seqr",this);
    rdb.build();
    // Should be done using resources
    rdb.set_hdl_path_root(`DEF2STR(`XA0_TOP_PATH));
    rdb.default_map.set_auto_predict(0);
    xbus2reg.map = rdb.default_map;
    reg_seqr.set_report_id_action("SQRWFG",UVM_NO_ACTION);
    reg2xbus = reg2xbus_adapter::type_id::create("reg2xbus");
  endfunction : build

  // Connect register sequencer to xbus master
  function void connect();
    vif_container vif_obj         = uvm_utils #(vif_container,"xbus_vif")::get_config(this,1);
    uvm_reg_passthru_adapter reg2reg  = uvm_reg_passthru_adapter::type_id::create("reg2reg");

    rdb.default_map.set_sequencer(reg_seqr,reg2reg);

    slaves[0].monitor.item_collected_port.connect(xbus2reg.bus_in);
    xbus2reg.adapter = reg2xbus;

    assign_vi(vif_obj.vif);         // xbus agent should use get_config, not this
    masters[0].sequencer.count = 0; //prevent auto-start

  endfunction : connect
    

  function void end_of_elaboration();
    set_slave_address_map("slaves[0]", 0, 16'hffff);
    bus_monitor.set_report_verbosity_level(UVM_HIGH);
  endfunction : end_of_elaboration

  typedef uvm_reg_sequence #(uvm_sequence #(xbus_transfer)) reg2xbus_seq_t;
  virtual task run();
    
    reg2xbus_seq_t reg2xbus_seq = reg2xbus_seq_t::type_id::create("reg2xbus_seq");
    reg2xbus_seq.reg_seqr = reg_seqr;
    reg2xbus_seq.adapter = reg2xbus;
    reg2xbus_seq.start(masters[0].sequencer);
  endtask

endclass : xbus_reg_env

`endif
