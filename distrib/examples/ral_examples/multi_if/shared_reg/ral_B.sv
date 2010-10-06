`ifndef RAL_B
`define RAL_B

import uvm_pkg::*;

class ral_reg_R extends uvm_ral_reg;
   rand uvm_ral_field F;

   function new(string name = "R");
      super.new(name, 8, uvm_ral::NO_COVERAGE);
   endfunction: new
   
   virtual function void build();
      this.F = uvm_ral_field::type_id::create("F");
      this.F.configure(this, 8, 0, "RW", 8'h0, `UVM_RAL_DATA_WIDTH'hx, 0, 1);
   endfunction: build

   `uvm_object_utils(ral_reg_R)
   
endclass : ral_reg_R


class ral_block_B extends uvm_ral_block;
   rand ral_reg_R A;
   rand ral_reg_R X;
   rand ral_reg_R W;

   uvm_ral_map APB;
   uvm_ral_map WSH;
   
   function new(string name = "B");
      super.new(name,uvm_ral::NO_COVERAGE);
   endfunction: new
   
   virtual function void build();

      APB = create_map("APB", 'h0, 1, uvm_ral::LITTLE_ENDIAN);
      WSH = create_map("WSH", 'h0, 1, uvm_ral::LITTLE_ENDIAN);
      default_map = APB;

      this.A = ral_reg_R::type_id::create("A");
      this.X = ral_reg_R::type_id::create("X");
      this.W = ral_reg_R::type_id::create("W");

      this.A.build();
      this.A.configure(this, null);
      this.X.build();
      this.X.configure(this, null);
      this.W.build();
      this.W.configure(this, null);

      APB.add_reg(A, 'h0,  "RW");
      APB.add_reg(X, 'h10, "RW");

      WSH.add_reg(X, 'h0,  "RW");
      WSH.add_reg(W, 'h10, "RW");

      this.Xlock_modelX();
   endfunction : build
   
   `uvm_object_utils(ral_block_B)
   
endclass : ral_block_B



`endif
