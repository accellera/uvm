// 
// -------------------------------------------------------------
//    Copyright 2010 Synopsys, Inc.
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

//
// This example demonstrates how to model aliased registers
// i.e. registers that are present at two physical addresses,
// possibily with different access policies.
//
// In this case, we have a register "R" which is known under two names
// "Ra" and "Rb". When accessed as "Ra", field F2 is RO.
//


class reg_Ra extends uvm_reg;
   rand uvm_reg_field F1;
   rand uvm_reg_field F2;

   function new(string name = "Ra");
      super.new(name, 32, UVM_NO_COVERAGE);
   endfunction: new
   
   virtual function void build();
      F1 = uvm_reg_field::type_id::create("F1");
      F1.configure(this, 8, 0, "RW", 0, 8'h0, 0, 1);
      F2 = uvm_reg_field::type_id::create("F2");
      F2.configure(this, 8, 16, "RO", 0, 8'h0, 0, 1);
   endfunction: build

   `uvm_object_utils(reg_Ra)
   
endclass : reg_Ra


class reg_Rb extends uvm_reg;
   rand uvm_reg_field F1;
   rand uvm_reg_field F2;

   function new(string name = "Rb");
      super.new(name, 32, UVM_NO_COVERAGE);
   endfunction: new
   
   virtual function void build();
      F1 = uvm_reg_field::type_id::create("F1");
      F1.configure(this, 8, 0, "RW", 0, 8'h0, 0, 1);
      F2 = uvm_reg_field::type_id::create("F2");
      F2.configure(this, 8, 16, "RW", 0, 8'h0, 0, 1);
   endfunction: build

   `uvm_object_utils(reg_Rb)
   
endclass : reg_Rb


class write_also_to_F extends uvm_reg_cbs;
   local uvm_reg_field m_toF;

   function new(uvm_reg_field toF);
      m_toF = toF;
   endfunction
   
   virtual task post_write(uvm_reg_item item);
      if (item.map.get_auto_predict())
         m_toF.predict(item.value[0]);
   endtask
   
endclass



class block_B extends uvm_reg_block;
   rand reg_Ra Ra;
   rand reg_Rb Rb;

   function new(string name = "B");
      super.new(name,UVM_NO_COVERAGE);
   endfunction: new
   
   virtual function void build();

      default_map = create_map("", 0, 4, UVM_BIG_ENDIAN);

      Ra = reg_Ra::type_id::create("Ra");
      Ra.build();
      Ra.configure(this, null);

      Rb = reg_Rb::type_id::create("Rb");
      Rb.build();
      Rb.configure(this, null);

      begin
         write_also_to_F F2F;

         F2F = new(Ra.F1);
         uvm_reg_field_cb::add(Rb.F1, F2F);
         F2F = new(Ra.F2);
         uvm_reg_field_cb::add(Rb.F2, F2F);
         F2F = new(Rb.F1);
         uvm_reg_field_cb::add(Ra.F1, F2F);
      end

      default_map.add_reg(Ra, 'h0,  "RW");
      default_map.add_reg(Rb, 'h100,  "RW");
   endfunction : build
   
   `uvm_object_utils(block_B)
   
endclass : block_B
