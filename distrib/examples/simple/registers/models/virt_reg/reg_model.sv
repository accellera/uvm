//
// -------------------------------------------------------------
//    Copyright 2010 Mentor Graphics Corporation
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
`ifndef REG_B
`define REG_B

import uvm_pkg::*;


class vreg_R extends uvm_vreg;
   uvm_vreg_field F1;
   uvm_vreg_field F2;

   function new(string name = "vreg_R");
      super.new(name, 32);
   endfunction: new
   
   virtual function void build();
      F1 = new("F1");
      F1.configure(this, 8, 0);
      F2 = new("F2");
      F2.configure(this, 16, 8);
   endfunction: build

   `uvm_object_utils(vreg_R)
endclass

class reg_block_B extends uvm_reg_block;

   uvm_mem RAM;
   vreg_R  R;

   function new(string name = "B");
      super.new(name, UVM_NO_COVERAGE);
   endfunction: new
   
   virtual function void build();
      RAM = new("RAM", 1024, 8);
      RAM.configure(this, "RAM");

      R = vreg_R::type_id::create("R",,get_full_name());
      R.configure(this, RAM, 16, 0, 4);
      R.build();

      default_map = create_map("default_map", 'h0, 1, UVM_LITTLE_ENDIAN);
      default_map.add_mem(RAM, 'h0, "RW");
    endfunction

    `uvm_object_utils(reg_block_B)

endclass


`endif
