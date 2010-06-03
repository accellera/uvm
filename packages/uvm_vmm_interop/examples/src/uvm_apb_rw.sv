//------------------------------------------------------------------------------
// Copyright 2008 Mentor Graphics Corporation
// All Rights Reserved Worldwide
// 
// Licensed under the Apache License, Version 2.0 (the "License"); you may
// not use this file except in compliance with the License.  You may obtain
// a copy of the License at
// 
//        http://www.apache.org/licenses/LICENSE-2.0
// 
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
// WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.  See the
// License for the specific language governing permissions and limitations
// under the License.
//------------------------------------------------------------------------------

`ifndef UVM_APB_RW_SV
`define UVM_APB_RW_SV

//------------------------------------------------------------------------------
//
// Class: uvm_apb_rw
//
// This class defines the UVM equivalent of the apb_rw VMM transaction type.
// There are two ways to define this, both shown.
//
// Manual - Here, you manually write the do_copy, do_print, and do_compare
//          methods. This gives you complete control at a cost of a little
//          more programming.
//
// Field Automation Macros - Here, you invoke a macro sequence that expands
//          into code that implements these methods. The macros expand into
//          a significant amount of code and can be hard to debug if not
//          used properly. However, many find their convenience to outweigh
//          these costs.
//         
// (inline source)
//------------------------------------------------------------------------------

class uvm_apb_rw extends uvm_sequence_item;

   rand int unsigned     addr;
   rand integer unsigned data;
   rand enum {RD, WR}    cmd;

   `uvm_object_utils(uvm_apb_rw)

   function new(string name="uvm_apb_rw");
     super.new(name);
   endfunction

   virtual function void do_copy(uvm_object rhs);
     uvm_apb_rw tr;
     super.do_copy(rhs);
     assert($cast(tr,rhs));
     cmd  = tr.cmd ;
     addr = tr.addr;
     data = tr.data;
   endfunction

   virtual function string convert2string();
     convert2string = { super.convert2string(),
                       "APB ",cmd.name(),
                       " @ 0x",$psprintf("%8h",addr),
                       " = 0x",$psprintf("%8h",data)};
   endfunction

   virtual function bit do_compare(uvm_object rhs, uvm_comparer comparer);
      uvm_apb_rw tr;

      if (rhs == null)
        return 0;

      if (!$cast(tr, rhs))
        return 0;

      if (cmd  !=  tr.cmd  ||
          addr !=  tr.addr ||
          data !== tr.data) begin
        $display("   ",this.convert2string(),"\n!= ",tr.convert2string());
        return 0;
      end

      return 1;

   endfunction

endclass : uvm_apb_rw


// Typedefs-  APB Transaction Types
//
// Define alternative names for the transaction type for those who
// speak in terms of transactions or items.

typedef uvm_apb_rw uvm_apb_tr;
typedef uvm_apb_rw uvm_apb_item;


`endif // UVM_APB_RW_SV
