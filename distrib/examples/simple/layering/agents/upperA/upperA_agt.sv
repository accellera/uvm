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

class upperA_agt extends uvm_agent;

  uvm_sequencer#(upperA_item) sqr;
  upperA_drv drv;
  upperA_mon mon;

  uvm_analysis_port#(upperA_item) ap;

  `uvm_component_utils(upperA_agt)

  function new(string name = "upperA_agt", uvm_component parent = null);
    super.new(name, parent);
    ap = new("ap", this);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    sqr = new("sqr", this);
    drv = upperA_drv::type_id::create("drv", this);
    mon = upperA_mon::type_id::create("mon", this);

    begin
      virtual upperA_if vif;
      
      if (!uvm_config_db#(virtual upperA_if)::get(this, "", "vif", vif)) begin
        `uvm_fatal("UPPERA/AGT/NOVIF", "No virtual interface specified")
      end
      uvm_config_db#(virtual upperA_if)::set(this, "*", "vif", vif);
    end

  endfunction

  virtual function void connect_phase(uvm_phase phase);
    drv.seq_item_port.connect(sqr.seq_item_export);
    mon.ap.connect(ap);
  endfunction

endclass

