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

  `uvm_component_utils(xbus_ral_env)

  function new (string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new

  // build
  virtual function void build();
    set_config_int("slaves*", "is_active", UVM_PASSIVE);
    num_masters = 1;
    num_slaves = 1;
    super.build();
    rdb = xbus_ral_model::type_id::create("xa0", this);
    rdb.build();
    // Should be done using resources
    begin
    string top_path;
    top_path = `DEF2STR(`XA0_TOP_PATH);
    if (top_path[0] == "$")
       top_path = top_path.substr(6,top_path.len()-1);
    rdb.set_hdl_path_root(top_path);
    end
  endfunction : build

  // Connect register sequencer to xbus master
  function void connect();
    ral2xbus_adapter ral2xbus = ral2xbus_adapter::type_id::create("ral2xbus_seq");
    masters[0].sequencer.count = 0; //prevents auto-start
    rdb.default_map.set_sequencer(masters[0].sequencer,ral2xbus);

    // Assign interface
    begin
      uvm_object obj;
      vif_container vif_obj;
      if (get_config_object("xbus_vif",obj,0) && !$cast(vif_obj,obj)) begin
        uvm_report_fatal("NO_VIF","No access to bus signals. Use set_config_object to set the bus_vif_container.");
        return;
      end
      assign_vi(vif_obj.vif);
    end

    bus_monitor.set_report_verbosity_level(UVM_LOW);

  endfunction : connect
    

  function void end_of_elaboration();
    // Set up slave address map for xbus env (basic default)
    set_slave_address_map("slaves[0]", 0, 16'hffff);
    // Shut off logging from xbus monitor
    bus_monitor.set_report_verbosity_level(UVM_NONE);
    //set_report_verbosity_level_hier(UVM_HIGH);
  endfunction : end_of_elaboration

  virtual task run();
  endtask

endclass : xbus_ral_env

`endif
