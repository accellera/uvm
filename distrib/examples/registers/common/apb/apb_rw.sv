// 
// -------------------------------------------------------------
//    Copyright 2004-2008 Synopsys, Inc.
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


`ifndef APB_RW__SV
`define APB_RW__SV

class apb_rw extends uvm_sequence_item;
  
   typedef enum {READ, WRITE} kind_e;
   rand bit   [31:0] addr;
   rand logic [31:0] data;
   rand kind_e kind;  
 
   `uvm_object_utils_begin(apb_rw)
     `uvm_field_int(addr, UVM_ALL_ON | UVM_NOPACK);
     `uvm_field_int(data, UVM_ALL_ON | UVM_NOPACK);
     `uvm_field_enum(kind_e,kind, UVM_ALL_ON | UVM_NOPACK);
   `uvm_object_utils_end
   
   function new (string name = "apb_rw");
      super.new(name);
   endfunction

   function string convert2string();
     return $sformatf("kind=%s addr=%0h data=%0h",kind,addr,data);
   endfunction

endclass: apb_rw


class reg2apb_adapter extends uvm_reg_adapter;

  `uvm_object_utils(reg2apb_adapter)

   function new(string name = "reg2apb_adapter");
      super.new(name);
   endfunction 

 virtual function uvm_sequence_item reg2bus(uvm_tlm_generic_payload rw);
    apb_rw apb = apb_rw::type_id::create("apb_rw");
    apb.kind = (rw.m_command == UVM_TLM_READ_COMMAND) ? apb_rw::READ : apb_rw::WRITE;
    apb.addr = rw.m_address;
    apb.data = 0;
    foreach(rw.m_data[i])
      apb.data |= (rw.m_data[i] << (i*8));
    return apb;
  endfunction

  virtual function void bus2reg(uvm_sequence_item bus_item,
                                uvm_tlm_generic_payload rw);
    apb_rw apb;
    if (!$cast(apb,bus_item)) begin
      `uvm_fatal("NOT_APB_TYPE","Provided bus_item is not of the correct type")
      return;
    end
    rw.m_command = apb.kind ? UVM_TLM_READ_COMMAND : UVM_TLM_WRITE_COMMAND;
    rw.m_address = apb.addr;
    rw.m_byte_enable = new [($size(apb.data)/8)];
    rw.set_streaming_width (($size(apb.data)/8));
    rw.m_data = new [4];
    foreach (rw.m_data[i]) begin
       rw.m_data[i] = 8'hff & (apb.data >> (8*i));
       rw.m_byte_enable[i] = 1;
    end
    rw.m_response_status = UVM_TLM_OK_RESPONSE;
  endfunction

endclass


`endif
