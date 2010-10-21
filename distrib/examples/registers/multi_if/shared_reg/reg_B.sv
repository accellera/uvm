`ifndef REG_B
`define REG_B

import uvm_pkg::*;

class reg_reg_R extends uvm_reg;
   rand uvm_reg_field F;

   function new(string name = "R");
      super.new(name, 8, UVM_NO_COVERAGE);
   endfunction: new
   
   virtual function void build();
      this.F = uvm_reg_field::type_id::create("F");
      this.F.configure(this, 8, 0, "RW", 8'h0, 0, 1);
   endfunction: build

   `uvm_object_utils(reg_reg_R)
   
endclass : reg_reg_R


class reg_block_B extends uvm_reg_block;
   rand reg_reg_R A;
   rand reg_reg_R X;
   rand reg_reg_R W;

   uvm_reg_map APB;
   uvm_reg_map WSH;
   
   function new(string name = "B");
      super.new(name,UVM_NO_COVERAGE);
   endfunction: new
   
   virtual function void build();

      APB = create_map("APB", 'h0, 1, UVM_LITTLE_ENDIAN);
      WSH = create_map("WSH", 'h0, 1, UVM_LITTLE_ENDIAN);
      default_map = APB;

      this.A = reg_reg_R::type_id::create("A");
      this.X = reg_reg_R::type_id::create("X");
      this.W = reg_reg_R::type_id::create("W");

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

      this.lock_model();
   endfunction : build
   
   `uvm_object_utils(reg_block_B)
   
endclass : reg_block_B



`endif
