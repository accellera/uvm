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

`ifndef XBUS_RAL_TB_SV
`define XBUS_RAL_TB_SV

`define DEF2STR(arg) `"arg`"

class vif_container extends uvm_object;
   `uvm_object_utils(vif_container);
   virtual interface xbus_if vif;
endclass

 
import uvm_pkg::*;
`include "xbus.svh"
`include "ral_xa0.sv"
`include "ral2xbus_adapter.sv"
`include "xbus_indirect_reg_ftdr_seq.sv"
`include "xbus_user_acp_reg.sv"


class xbus_ral_model extends ral_sys_xa0;

  `uvm_object_utils(xbus_ral_model)

  function new (string name="");
    super.new(name);
  endfunction

  virtual function void build();
    xbus_user_acp_reg_cb cb = new;
    super.build();
    uvm_callbacks#(ral_reg_xa0_xbus_rf_user_acp_reg, uvm_ral_reg_cbs)::add(xbus_rf.user_acp_reg, cb);
    
    foreach(xbus_rf.xbus_indirect_reg[i]) begin
      xbus_indirect_reg_ftdr_seq ftdr = new(this, i);
      xbus_rf.xbus_indirect_reg[i].set_frontdoor(ftdr);
    end
  endfunction

endclass


class xbus_ral_env extends xbus_env;

  // the register model
  xbus_ral_model rdb;
  uvm_ral_predictor #(xbus_transfer) xbus2ral;
  uvm_sequencer #(uvm_rw_access) ral_seqr;
  ral2xbus_adapter ral2xbus;

  `uvm_component_utils(xbus_ral_env)

  function new (string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new

  // build
  virtual function void build();
    xbus2ral = new("xbus2ral",this);
    set_config_int("slaves*", "is_active", UVM_PASSIVE);
    num_masters = 1;
    num_slaves = 1;
    super.build();
    rdb = xbus_ral_model::type_id::create("xa0", this);
    ral_seqr = uvm_sequencer #(uvm_rw_access)::type_id::create("ral_seqr",this);
    rdb.build();
    // Should be done using resources
    rdb.set_hdl_path_root(`DEF2STR(`XA0_TOP_PATH));
    rdb.default_map.set_auto_predict(0);
    xbus2ral.map = rdb.default_map;
    ral_seqr.set_report_id_action("SQRWFG",UVM_NO_ACTION);
    ral2xbus = ral2xbus_adapter::type_id::create("ral2xbus");
  endfunction : build

  // Connect register sequencer to xbus master
  function void connect();
    vif_container vif_obj         = uvm_utils #(vif_container,"xbus_vif")::get_config(this,1);
    uvm_ral_passthru_adapter ral2ral  = uvm_ral_passthru_adapter::type_id::create("ral2ral");

    rdb.default_map.set_sequencer(ral_seqr,ral2ral);

    slaves[0].monitor.item_collected_port.connect(xbus2ral.bus_in);
    xbus2ral.adapter = ral2xbus;

    assign_vi(vif_obj.vif);         // xbus agent should use get_config, not this
    masters[0].sequencer.count = 0; //prevent auto-start

  endfunction : connect
    

  function void end_of_elaboration();
    set_slave_address_map("slaves[0]", 0, 16'hffff);
    bus_monitor.set_report_verbosity_level(UVM_HIGH);
  endfunction : end_of_elaboration

  typedef uvm_ral_sequence #(uvm_sequence #(xbus_transfer)) ral2xbus_seq_t;
  virtual task run();
    
    ral2xbus_seq_t ral2xbus_seq = ral2xbus_seq_t::type_id::create("ral2xbus_seq");
    ral2xbus_seq.ral_seqr = ral_seqr;
    ral2xbus_seq.adapter = ral2xbus;
    ral2xbus_seq.start(masters[0].sequencer);
  endtask

endclass : xbus_ral_env

`endif
