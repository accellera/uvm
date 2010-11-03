`ifndef REG_B
`define REG_B

import uvm_pkg::*;

class reg_reg_B_R extends uvm_reg;
	rand uvm_reg_field F;

	function new(string name = "B_R");
		super.new(name,8,UVM_NO_COVERAGE);
	endfunction: new

   virtual function void build();
		F = uvm_reg_field::type_id::create("F");
		F.configure(this, 8, 0, "RW", 0, 8'h0, 0, 1);
	endfunction: build

	`uvm_object_utils(reg_reg_B_R)

endclass : reg_reg_B_R


class reg_fld_B_CTL_CTL;
	typedef enum bit[1:0] { 
		NOP, 
		INC, 
		DEC, 
		CLR
	} CTL_values;
endclass : reg_fld_B_CTL_CTL


class reg_reg_B_CTL extends uvm_reg;
	rand uvm_reg_field CTL;

	function new(string name = "B_CTL");
		super.new(name,8,UVM_NO_COVERAGE);
	endfunction: new

   virtual function void build();
		CTL = uvm_reg_field::type_id::create("CTL");
		CTL.configure(this, 2, 0, "WO", 0, 2'h0, 0, 1);
		set_attribute("NO_REG_TESTS", "1");
	endfunction: build

	`uvm_object_utils(reg_reg_B_CTL)

endclass : reg_reg_B_CTL


class reg_block_B extends uvm_reg_block;
	rand reg_reg_B_R R;
	rand reg_reg_B_CTL CTL;
	rand uvm_reg_field F;

	function new(string name = "B");
		super.new(name,UVM_NO_COVERAGE);
	endfunction: new

   virtual function void build();

                // create regs
		R   =   reg_reg_B_R::type_id::create("R");
		CTL = reg_reg_B_CTL::type_id::create("CTL");

                // build regs
		R.build   ();
                R.configure(this, null);
		CTL.build ();
                CTL.configure(this, null);

                // create map
                default_map = create_map("default_map", 'h0, 1, UVM_LITTLE_ENDIAN);
                default_map.add_reg(R, 'h0, "RW");
                default_map.add_reg(CTL, 'h1, "RW");

                // assign field aliases
		F = R.F;

		lock_model();
	endfunction : build

	`uvm_object_utils(reg_block_B)

endclass : reg_block_B


`endif
