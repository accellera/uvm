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


class sym_sb extends uvm_component;

   uvm_analysis_imp#(vip_tr, sym_sb) rx;

   `uvm_component_utils(sym_sb)

   function new(string name, uvm_component parent = null);
      super.new(name, parent);
      rx = new("rx", this);
   endfunction

   function void write(vip_tr tr);
      `uvm_info("TX/CHR", $sformatf("Tx: 0x%h", tr.chr), UVM_LOW)
   endfunction
endclass
