//----------------------------------------------------------------------
//   Copyright 2013 Synopsys, Inc.
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

class layered_agt extends uvm_agent;

  uvm_sequencer#(upperA_item) uA_sqr;
  uvm_sequencer#(upperB_item) uB_sqr;
  lower_sqr l_sqr;
  lower_drv drv;
  lower_mon l_mon;
  upperA_mon uA_mon;
  upperB_mon uB_mon;

  uvm_analysis_port#(upperA_item) apA;
  uvm_analysis_port#(upperB_item) apB;

  `uvm_component_utils(layered_agt)

  function new(string name = "layered_agt", uvm_component parent = null);
    super.new(name, parent);
    apA = new("apA", this);
    apB = new("apB", this);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    uA_sqr = new("uA_sqr", this);
    uB_sqr = new("uB_sqr", this);
    l_sqr = lower_sqr::type_id::create("l_sqr", this);
    drv = lower_drv::type_id::create("drv", this);
    l_mon = lower_mon::type_id::create("l_mon", this);
    uA_mon = upperA_mon::type_id::create("uA_mon", this);
    uB_mon = upperB_mon::type_id::create("uB_mon", this);

    begin
      virtual lower_if vif;
      
      if (!uvm_config_db#(virtual lower_if)::get(this, "", "vif", vif)) begin
        `uvm_fatal("LAYERED/AGT/NOVIF", "No virtual interface specified")
      end
      uvm_config_db#(virtual lower_if)::set(this, "*", "vif", vif);
    end

  endfunction

  virtual function void connect_phase(uvm_phase phase);
    drv.seq_item_port.connect(l_sqr.seq_item_export);
    l_sqr.upperA_item_port.connect(uA_sqr.seq_item_export);
    l_sqr.upperB_item_port.connect(uB_sqr.seq_item_export);
    uA_mon.ap.connect(apA);
    uB_mon.ap.connect(apB);
    l_mon.ap.connect(uA_mon.axp);
    l_mon.ap.connect(uB_mon.axp);
  endfunction

  virtual task run_phase(uvm_phase phase);
    super.run_phase(phase);

    fork
      begin
        layerA_seq seq = layerA_seq::type_id::create("seq", this);
        seq.start(l_sqr);
      end
      begin
        layerB_seq seq = layerB_seq::type_id::create("seq", this);
        seq.start(l_sqr);
      end
    join_none
  endtask

endclass

