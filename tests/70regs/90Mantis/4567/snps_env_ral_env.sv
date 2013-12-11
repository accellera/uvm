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
// //
// Template for UVM-compliant verification environment
//

`ifndef SNPS_ENV_RAL_ENV__SV
`define SNPS_ENV_RAL_ENV__SV

`include "snps_env.sv"
`include "ral_DUT.sv"

class reg_seq extends uvm_reg_sequence #(uvm_sequence #(trans_snps));
   
   ral_sys_DUT regmodel;

   `uvm_object_utils(reg_seq)

   function new(string name = "");
      super.new(name);
   endfunction:new

   task pre_body();
      $cast(model,this.regmodel);
   endtask

   task body;
      uvm_status_e status;
      uvm_status_e wr_status;
      uvm_reg_data_t data;
      uvm_phase starting_phase = get_starting_phase();
        `uvm_info("TRACE", $sformatf("%m"), UVM_HIGH);
     if (starting_phase != null)
       starting_phase.raise_objection(this);
//SNPS
regmodel.DUT_BLK.STATUS_REG.read(.status(status), .value(data), .path(UVM_BACKDOOR), .parent(this));
`uvm_info("RD", $sformatf("%s%s%s%h"," read status = ", status, ", read value = ", data), UVM_LOW)
regmodel.DUT_BLK.STATUS_REG.write(.status(wr_status), .value(8'h12), .path(UVM_BACKDOOR), .parent(this));
`uvm_info("WR", $sformatf(" write status = %s ", wr_status), UVM_LOW)
        if (status != UVM_IS_OK)
            `uvm_error("WR_ERR", "Change in status .");
regmodel.DUT_BLK.STATUS_REG.read(.status(status), .value(data), .path(UVM_BACKDOOR), .parent(this));
`uvm_info("RD", $sformatf("%s%s%s%h"," read status = ", status, ", read value = ", data), UVM_LOW)

     if (starting_phase != null)
       starting_phase.drop_objection(this);

   endtask
endclass

class snps_env_ral_env extends uvm_env;
   ral_sys_DUT  regmodel;
   reg_seq ral_sequence; 
   drv_snps mast_drv;
   drv_snps slave_drv;
   sqr_snps mast_seqr;
   
   reg_adapter reg2host;
   
    `uvm_component_utils(snps_env_ral_env)

   extern function new(string name= "snps_env_ral_env", uvm_component parent=null);
   extern virtual function void build_phase(uvm_phase phase);
   extern virtual function void connect_phase(uvm_phase phase);

endclass: snps_env_ral_env

function snps_env_ral_env::new(string name= "snps_env_ral_env",uvm_component parent=null);
   super.new(name,parent);
endfunction:new

function void snps_env_ral_env::build_phase(uvm_phase phase);
   string hdl_path;
   super.build();
   mast_drv = drv_snps::type_id::create("mast_drv",this); 
      
   mast_seqr = sqr_snps::type_id::create("mast_seqr",this);

 if (regmodel == null) begin
       if (!uvm_config_db #(string)::get(this, "", "hdl_path", hdl_path)) begin
         `uvm_warning("PATHNOTSET", "HDL path for backdoor not set!");
      end
end
   regmodel = ral_sys_DUT::type_id::create("regmodel",this); 
   regmodel.build();
   regmodel.lock_model();
   regmodel.set_hdl_path_root(hdl_path);
   reg2host = new("reg2host");
endfunction: build_phase

function void snps_env_ral_env::connect_phase(uvm_phase phase);
   super.connect_phase(phase);
   mast_drv.seq_item_port.connect(mast_seqr.seq_item_export);

   regmodel.default_map.set_sequencer(mast_seqr,reg2host);
   regmodel.default_map.set_auto_predict(1);

endfunction: connect_phase

`endif // SNPS_ENV_RAL_ENV__SV
