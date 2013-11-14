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
// Template for UVM-compliant physical-level transactor
//

`ifndef DRV_SNPS__SV
`define DRV_SNPS__SV
`include "trans_snps.sv"

typedef class trans_snps;
typedef class drv_snps;

class drv_snps_callbacks extends uvm_callback;

   virtual task pre_tx( drv_snps xactor,
                        trans_snps tr);
                                   
   endtask: pre_tx


   virtual task post_tx( drv_snps xactor,
                         trans_snps tr);

   endtask: post_tx

endclass: drv_snps_callbacks


class drv_snps extends uvm_driver # (trans_snps);

   
   typedef virtual dut_if.mst v_if; 
   v_if drv_if;
   `uvm_register_cb(drv_snps,drv_snps_callbacks) 
   
   extern function new(string name = "drv_snps",
                       uvm_component parent = null); 
 
      `uvm_component_utils_begin(drv_snps)
      `uvm_component_utils_end


    extern virtual function void build_phase(uvm_phase phase);
    extern virtual function void end_of_elaboration_phase(uvm_phase phase);
    extern virtual function void connect_phase(uvm_phase phase);
   extern virtual task run_phase(uvm_phase phase);
   extern protected virtual task send(trans_snps tr); 
   extern protected virtual task tx_driver();

endclass: drv_snps


function drv_snps::new(string name = "drv_snps",
                   uvm_component parent = null);
   super.new(name, parent);
   
endfunction: new


function void drv_snps::build_phase(uvm_phase phase);
   super.build_phase(phase);
 `uvm_info("TRACE", $sformatf("%m"), UVM_LOW);

endfunction: build_phase

function void drv_snps::connect_phase(uvm_phase phase);
   super.connect_phase(phase);
   uvm_config_db#(v_if)::get(this, "", "drv_if", drv_if);
endfunction: connect_phase

function void drv_snps::end_of_elaboration_phase(uvm_phase phase);
   super.end_of_elaboration_phase(phase);
   if (drv_if == null)
       `uvm_fatal("NO_CONN", "Virtual port not connected to the actual interface instance");   
endfunction: end_of_elaboration_phase


task drv_snps::run_phase(uvm_phase phase);
   super.run_phase(phase);
   phase.raise_objection(this,"");
   fork 
      tx_driver();
   join
   phase.drop_objection(this);
endtask: run_phase


task drv_snps::tx_driver();
 forever begin
      trans_snps tr;
      `uvm_info("snps_env_DRIVER", "Starting transaction...",UVM_LOW)
      seq_item_port.get_next_item(tr);
      case (tr.kind) 
         trans_snps::READ: begin
            // ToDo: Implement READ transaction
	    drv_if.cb.enable <= 1'b1;
	    drv_if.cb.direction <= tr.kind;
	    drv_if.cb.addr <= tr.addr;
	    @(drv_if.cb);
            drv_if.cb.enable <= 1'b0;
            @(drv_if.cb);
	    tr.data = drv_if.cb.rdata;
         end
         trans_snps::WRITE: begin
            // ToDo: Implement READ transaction
            @(drv_if.cb);
	    drv_if.cb.enable <= 1'b1;
	    drv_if.cb.direction <= tr.kind;
	    drv_if.cb.addr <= tr.addr;
	    drv_if.cb.wdata <= tr.data;
            @(drv_if.cb);
            drv_if.cb.enable <= 1'b0;
         end
      endcase
	  `uvm_do_callbacks(drv_snps,drv_snps_callbacks,
                    pre_tx(this, tr))
      send(tr); 
      seq_item_port.item_done();
       `uvm_info("snps_env_DRIVER", "Completed transaction...",UVM_LOW)
      `uvm_info("snps_env_DRIVER", tr.sprint(),UVM_LOW)
      `uvm_do_callbacks(drv_snps,drv_snps_callbacks,
                    post_tx(this, tr))

   end
endtask : tx_driver

task drv_snps::send(trans_snps tr);
  
endtask: send


`endif // DRV_SNPS__SV


