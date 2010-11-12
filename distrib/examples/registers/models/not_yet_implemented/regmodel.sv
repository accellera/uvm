`ifndef REG_B
`define REG_B

class reg_R1 extends uvm_reg;
   rand uvm_reg_field F1;
   uvm_reg_field F2;

   function new(string name = "R1");
      super.new(name, 32, UVM_NO_COVERAGE);
   endfunction: new
   
   virtual function void build();
      this.F1 = uvm_reg_field::type_id::create("value",,get_full_name());
      this.F1.configure(this, 8, 0, "RW", 0, 8'h0, 1, 1, 1);
      this.F2 = uvm_reg_field::type_id::create("value",,get_full_name());
      this.F2.configure(this, 8, 16, "RO", 0, 8'hA5, 1, 1, 1);
   endfunction: build

   `uvm_object_utils(reg_R1)
   
endclass : reg_R1


class reg_R2 extends uvm_reg;
   uvm_reg_field F3;
   uvm_reg_field F4;

   function new(string name = "R2");
      super.new(name, 32, UVM_NO_COVERAGE);
   endfunction: new
   
   virtual function void build();
      this.F3 = uvm_reg_field::type_id::create("value",,get_full_name());
      this.F3.configure(this, 8, 0, "WSRC", 0, 8'h0, 1, 1, 1);
      this.F4 = uvm_reg_field::type_id::create("value",,get_full_name());
      this.F4.configure(this, 8, 16, "WCRS", 0, 8'hFF, 1, 1, 1);
   endfunction: build

   `uvm_object_utils(reg_R2)
   
endclass : reg_R2


class block_B extends uvm_reg_block;
   rand reg_R1 R1;
   rand reg_R2 R2;

   function new(string name = "B");
      super.new(name,UVM_NO_COVERAGE);
   endfunction: new
   
   virtual function void build();

      default_map = create_map("", 0, 4, UVM_BIG_ENDIAN);

      R1 = reg_R1::type_id::create("R1",,get_full_name());
      R1.build();
      R1.configure(this, null);

      R2 = reg_R2::type_id::create("R2",,get_full_name());
      R2.build();
      R2.configure(this, null);

      default_map.add_reg(R1, 'h00,  "RW");
      default_map.add_reg(R2, 'h04,  "RW");
   endfunction : build
   
   `uvm_object_utils(block_B)
   
endclass : block_B

`endif
