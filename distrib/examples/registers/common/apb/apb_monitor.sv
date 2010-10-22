// 
// -------------------------------------------------------------
//    Copyright 2004-2008 Synopsys, Inc.
//    Copyright 2010 Mentor Graphics Corp.
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


`ifndef APB_MONITOR__SV
`define APB_MONITOR__SV


typedef class apb_monitor;

class apb_monitor_cbs extends uvm_callback;
  virtual function void trans_observed(apb_monitor xactor,apb_rw cycle);
  endfunction:trans_observed
endclass: apb_monitor_cbs


class apb_monitor extends uvm_monitor;
   virtual apb_if.passive sigs;

   uvm_analysis_port#(apb_rw) ap;
   apb_config cfg;

   function new(string name, uvm_component parent = null);
      super.new(name, parent);
      ap = new("ap", this);
   endfunction: new

   virtual function void build();
     cfg = uvm_utils #(apb_config,"config")::get_config(this,1);
     sigs = cfg.vif;
   endfunction

   virtual protected task run();
      super.run();
      forever begin
         apb_rw tr;
         
         // Wait for a SETUP cycle
         do begin
            @ (this.sigs.pck);
         end
         while (this.sigs.pck.psel !== 1'b1 ||
                this.sigs.pck.penable !== 1'b0);

         tr = apb_rw::type_id::create("tr", this);
         
         tr.kind = (this.sigs.pck.pwrite) ? apb_rw::WRITE : apb_rw::READ;
         tr.addr = this.sigs.pck.paddr;

         @ (this.sigs.pck);
         if (this.sigs.pck.penable !== 1'b1) begin
            `uvm_error("APB", "APB protocol violation: SETUP cycle not followed by ENABLE cycle");
         end
         tr.data = (tr.kind == apb_rw::READ) ? this.sigs.pck.prdata :
                                               this.sigs.pck.pwdata;

         trans_observed(tr);
         `uvm_do_callbacks(apb_monitor,apb_monitor_cbs,trans_observed(this,tr))

         ap.write(tr);
      end
   endtask: run

   virtual protected task trans_observed(apb_rw tr);
   endtask

endclass: apb_monitor

`endif


