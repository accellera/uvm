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
// Template for UVM-compliant RAL adapter sequence

class reg_adapter extends uvm_reg_adapter;

 `uvm_object_utils(reg_adapter)

 function new (string name="");
   super.new(name);
 endfunction
 
   
 virtual function uvm_sequence_item reg2bus(const ref uvm_reg_bus_op rw);
  trans_snps tr;
  tr = trans_snps::type_id::create("tr"); 
  tr.kind = (rw.kind == UVM_READ) ? trans_snps::READ : trans_snps::WRITE; 
  tr.addr = rw.addr;
  tr.data = rw.data;
  return tr;
 endfunction

 virtual function void bus2reg (uvm_sequence_item bus_item,
                                ref uvm_reg_bus_op rw);
  trans_snps tr;
  if (!$cast(tr, bus_item))
   `uvm_fatal("NOT_HOST_REG_TYPE", "bus_item is not correct type");
  rw.kind = tr.kind ? UVM_READ : UVM_WRITE;
  rw.addr = tr.addr;
  rw.data = tr.data;
  rw.status = UVM_IS_OK;
 endfunction

endclass: reg_adapter
