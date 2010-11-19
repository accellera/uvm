// 
// -------------------------------------------------------------
//    Copyright 2004-2010 Synopsys, Inc.
//    Copyright 2010 Mentor Graphics Corp.
//    Copyright 2010 Cadence Design Systems, Inc.
//    All Rights Reserved Worldwide
// 
//    Licensed under the Apache License, Version 2.0 (the
//    "License"); you may not use this file except in
//    compliance with the License.  You may obtain a copy of
//    the License at
// 
//        http://www.apache.org/licenses/LICENSE-2.0
// 
//    Unless required by applicable law or agreed to in
//    writing, software distributed under the License is
//    distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
//    CONDITIONS OF ANY KIND, either express or implied.  See
//    the License for the specific language governing
//    permissions and limitations under the License.
// -------------------------------------------------------------
// 


//
// This example shows how to integrate a register model
// using a layered register sequencer.
//
// By default, the mirror in the register model is updated implicitly.
// For explicit monitoring, define the `EXPLICIT_MON macro
//

typedef uvm_reg_sequence #(uvm_sequence #(apb_rw)) reg2apb_seq_t;

class tb_env extends uvm_component;

   `uvm_component_utils(tb_env)

   dut_regmodel                 regmodel; 
   uvm_sequencer#(uvm_reg_item) reg_seqr;
   reg2apb_seq_t                reg2apb_seq;
   apb_agent                    apb;
`ifdef EXPLICIT_MON
   uvm_reg_predictor#(apb_rw)   apb2reg_predictor;
`endif

   function new(string name, uvm_component parent=null);
      super.new(name,parent);
   endfunction

   virtual function void build();
      if (regmodel == null) begin
         regmodel = dut_regmodel::type_id::create("regmodel",,get_full_name());
         regmodel.build();
         regmodel.lock_model();

         reg_seqr = uvm_sequencer#(uvm_reg_item)::type_id::create("reg_seqr",
                                                                  this);
         reg2apb_seq = new();
         apb = apb_agent::type_id::create("apb", this);
`ifdef EXPLICIT_MON
         apb2reg_predictor = new("apb2reg_predictor", this);
`endif
      end
   endfunction

   virtual function void connect();
      if (apb != null) begin
         reg2apb_adapter reg2apb     = new;

         regmodel.default_map.set_sequencer(reg_seqr,null);

         reg2apb_seq.reg_seqr = reg_seqr;
         reg2apb_seq.adapter  = reg2apb;
`ifdef EXPLICIT_MON
         apb2reg_predictor.map = regmodel.default_map;
         apb2reg_predictor.adapter = reg2apb;
         regmodel.default_map.set_auto_predict(0);
         apb.mon.ap.connect(apb2reg_predictor.bus_in);
`endif
      end
   endfunction

   virtual task run();
      reg2apb_seq.start(apb.sqr);
   endtask

endclass

