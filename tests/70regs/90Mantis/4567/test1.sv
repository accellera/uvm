// -------------------------------------------------------------
//    Copyright 2013 Synopsys, Inc.
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
//    permissions and limitations under t,he License.
// -------------------------------------------------------------
// 
// Template for UVM-compliant testcase

`ifndef TEST__SV
`define TEST__SV
`include "snps_env_ral_env.sv"

typedef class snps_env_ral_env;

class test extends uvm_test;

  `uvm_component_utils(test)

  snps_env_ral_env env;
  reg_seq ral_sequence;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env = snps_env_ral_env::type_id::create("env", this);
    uvm_config_db #(string)::set(this, "env", "hdl_path", "snps_env_top.dut");
    `ifndef UVM_RAL_SEQ
    uvm_config_db #(uvm_object_wrapper)::set(this, "env.mast_seqr.main_phase",
                   "default_sequence", sequence_1::get_type());
    `endif
    endfunction

virtual task run_phase(uvm_phase phase);
phase.raise_objection(this);
ral_sequence = reg_seq::type_id::create("ral_sequence");
ral_sequence.regmodel = env.regmodel; 
if(ral_sequence==null)
`uvm_info("RAL OBJ FAIL",$sformatf("RAL object failed to create"),UVM_LOW);
`ifdef UVM_RAL_SEQ
ral_sequence.start(env.mast_seqr);
`endif

phase.drop_objection(this);
endtask


 virtual function void final_phase(uvm_phase phase);
    super.final_phase(phase);
    `uvm_info("TRACE", $sformatf("%m"), UVM_HIGH);
    uvm_top.print_topology();
  endfunction


endclass : test

`endif //TEST__SV

