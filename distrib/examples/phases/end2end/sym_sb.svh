// 
// -------------------------------------------------------------
//    Copyright 2011 Synopsys, Inc.
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


`uvm_analysis_imp_decl(_sym_sb_expected)
`uvm_analysis_imp_decl(_sym_sb_observed)
                       
class sym_sb extends uvm_component;

   uvm_analysis_imp_sym_sb_expected#(vip_tr, sym_sb) expected;
   uvm_analysis_imp_sym_sb_observed#(vip_tr, sym_sb) observed;

   int n_obs_thresh = 10;
   local int m_n_obs;

   `uvm_component_utils(sym_sb)

   function new(string name, uvm_component parent = null);
      super.new(name, parent);
      expected = new("expected", this);
      observed = new("observed", this);
   endfunction

   function void build_phase(uvm_phase phase);
      void'(uvm_config_db#(int)::get(this, "", "n_obs_thresh", n_obs_thresh));
   endfunction

   function void write_sym_sb_expected(vip_tr tr);
      `uvm_info("SB/EXP", $sformatf("Expected: 0x%h", tr.chr), UVM_LOW)
   endfunction

   function void write_sym_sb_observed(vip_tr tr);
      `uvm_info("SB/OBS", $sformatf("Observed: 0x%h", tr.chr), UVM_LOW)
      m_n_obs++;
   endfunction


   task reset_phase(uvm_phase phase);
      m_n_obs = 0;
   endtask
            
   task main_phase(uvm_phase phase);
      phase.raise_objection(this, "Have not checked enough data");
      wait (m_n_obs > n_obs_thresh);
      phase.drop_objection(this, "Enough data has been observed");
   endtask
endclass
