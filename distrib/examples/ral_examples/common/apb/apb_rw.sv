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


`ifndef APB_RW__SV
`define APB_RW__SV

class apb_rw extends uvm_sequence_item;
  
   typedef enum {READ, WRITE, RESET} kind_e;
   rand bit   [31:0] addr;
   rand logic [31:0] data;
   rand kind_e kind;  
 
   `uvm_object_utils_begin(apb_rw)
     `uvm_field_int(addr, UVM_ALL_ON | UVM_NOPACK);
     `uvm_field_int(data, UVM_ALL_ON | UVM_NOPACK);
     `uvm_field_enum(kind_e,kind, UVM_ALL_ON | UVM_NOPACK);
   `uvm_object_utils_end;
   
   function new (string name = "apb_rw");
      super.new(name);
   endfunction

   constraint no_rand_reset { kind != RESET; }

   function string convert2string();
     return $sformatf("kind=%s addr=%0h data=%0h",kind,addr,data);
   endfunction

endclass: apb_rw


class apb_reset extends apb_rw;
   `uvm_object_utils(apb_reset)
   function new (string name = "apb_reset");
      super.new(name);
      kind = RESET;
      data = 5;
   endfunction
endclass




class apb_reset_seq extends uvm_sequence #(apb_reset);
   `uvm_object_utils(apb_reset_seq)

   function new(string name = "apb_reset_seq");
      super.new(name);
   endfunction: new

   virtual task body();
     req = apb_reset::type_id::create("apb_reset",,get_full_name());
     start_item(req);
     finish_item(req);
   endtask

endclass


class ral2apb_adapter extends uvm_ral_adapter;

  `uvm_object_utils(ral2apb_adapter)

  virtual function uvm_sequence_item ral2bus(uvm_rw_access rw_access);
    apb_rw apb = apb_rw::type_id::create("apb_rw");
    apb.kind = (rw_access.kind == uvm_ral::READ) ? apb_rw::READ : apb_rw::WRITE;
    apb.addr = rw_access.addr;
    apb.data = rw_access.data;
    return apb;
  endfunction

  virtual function void bus2ral(uvm_sequence_item bus_item, uvm_rw_access rw_access);
    apb_rw apb;
    if (!$cast(apb,bus_item)) begin
      `uvm_fatal("NOT_APB_TYPE","Provided bus_item is not of the correct type")
      return;
    end
    rw_access.kind = apb.kind ? uvm_ral::READ : uvm_ral::WRITE;
    rw_access.addr = apb.addr;
    rw_access.data = apb.data;
  endfunction

endclass


`endif
