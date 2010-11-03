`ifndef REG_B
`define REG_B

class reg_R extends uvm_reg;
   rand uvm_reg_data_t value;
   local rand uvm_reg_field _dummy;

   constraint _dummy_is_reg {
      _dummy.value == value;
   }

   function new(string name = "R");
      super.new(name, 8, UVM_NO_COVERAGE);
   endfunction: new
   
   virtual function void build();
      this._dummy = uvm_reg_field::type_id::create("value");
      this._dummy.configure(this, 8, 0, "RW", 0, 8'h0, 0, 1);
      this._dummy.value.rand_mode(1);
   endfunction: build

   `uvm_object_utils(reg_R)
   
endclass : reg_R


class block_B extends uvm_reg_block;
   rand reg_R R;

   function new(string name = "B");
      super.new(name,UVM_NO_COVERAGE);
   endfunction: new
   
   virtual function void build();

      default_map = create_map("", 0, 4, UVM_BIG_ENDIAN);

      this.R = reg_R::type_id::create("R");
      this.R.build();
      this.R.configure(this, null);

      default_map.add_reg(R, 'h0,  "RW");
   endfunction : build
   
   `uvm_object_utils(block_B)
   
endclass : block_B



`endif
