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

`uvm_analysis_imp_decl(A)
`uvm_analysis_imp_decl(B)

class tb_env extends uvm_env;

  lower_agt low;
  upperA_agt upA;
  upperB_agt upB;

  local lower_passthru_seq seqA;
  local lower_passthru_seq seqB;
  
  uvm_analysis_impA#(upperA_item, tb_env) axp_A;
  uvm_analysis_impB#(upperB_item, tb_env) axp_B;

  `uvm_component_utils(tb_env)

  function new(string name = "tb_env", uvm_component parent = null);
    super.new(name, parent);
    axp_A = new("axp_A", this);
    axp_B = new("axp_B", this);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    low = lower_agt::type_id::create("low", this);

    upA = upperA_agt::type_id::create("upA", this);
    uvm_config_db#(virtual upperA_if)::set(this, "upA", "vif", null);
    set_inst_override_by_type("upA.drv", upperA_drv::get_type(), layerA_drv::get_type());
    set_inst_override_by_type("upA.mon", upperA_mon::get_type(), layerA_mon::get_type());
    seqA = lower_passthru_seq::type_id::create("seqA", this);
    uvm_config_db#(lower_passthru_seq)::set(this, "upA.drv", "passthru_seq", seqA);

    upB = upperB_agt::type_id::create("upB", this);
    uvm_config_db#(virtual upperB_if)::set(this, "upB", "vif", null);
    set_inst_override_by_type("upB.drv", upperB_drv::get_type(), layerB_drv::get_type());
    set_inst_override_by_type("upB.mon", upperB_mon::get_type(), layerB_mon::get_type());
    seqB = lower_passthru_seq::type_id::create("seqB", this);
    uvm_config_db#(lower_passthru_seq)::set(this, "upB.drv", "passthru_seq", seqB);
  endfunction

  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    upA.ap.connect(axp_A);
    upB.ap.connect(axp_B);

    begin
      layerA_mon mon;
      $cast(mon, upA.mon);
      low.mon.ap.connect(mon.axp);
    end
    begin
      layerB_mon mon;
      $cast(mon, upB.mon);
      low.mon.ap.connect(mon.axp);
    end
  endfunction

  function void writeA(upperA_item item);
    $write("Observer upperA item:\n");
    item.print();
  endfunction

  function void writeB(upperB_item item);
    $write("Observer upperB item:\n");
    item.print();
  endfunction

  virtual task run_phase(uvm_phase phase);
    fork
      seqA.start(low.sqr);
      seqB.start(low.sqr);
    join_none
  endtask
endclass
