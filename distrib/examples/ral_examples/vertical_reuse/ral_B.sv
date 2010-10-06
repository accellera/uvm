`ifndef RAL_B
`define RAL_B

import uvm_pkg::*;

class ral_reg_B_R extends uvm_ral_reg;
	rand uvm_ral_field F;

	function new(string name = "B_R");
		super.new(name,8,uvm_ral::NO_COVERAGE);
	endfunction: new

   virtual function void build();
		F = uvm_ral_field::type_id::create("F");
		F.configure(this, 8, 0, "RW", 8'h0, `UVM_RAL_DATA_WIDTH'hx, 0, 1);
	endfunction: build

	`uvm_object_utils(ral_reg_B_R)

endclass : ral_reg_B_R


class ral_fld_B_CTL_CTL;
	typedef enum bit[1:0] { 
		NOP, 
		INC, 
		DEC, 
		CLR
	} CTL_values;
endclass : ral_fld_B_CTL_CTL


class ral_reg_B_CTL extends uvm_ral_reg;
	rand uvm_ral_field CTL;

	function new(string name = "B_CTL");
		super.new(name,8,uvm_ral::NO_COVERAGE);
	endfunction: new

   virtual function void build();
		CTL = uvm_ral_field::type_id::create("CTL");
		CTL.configure(this, 2, 0, "WO", 2'h0, `UVM_RAL_DATA_WIDTH'hx, 0, 1);
		set_attribute("NO_RAL_TESTS", "1");
	endfunction: build

	`uvm_object_utils(ral_reg_B_CTL)

endclass : ral_reg_B_CTL


class ral_block_B extends uvm_ral_block;
	rand ral_reg_B_R R;
	rand ral_reg_B_CTL CTL;
	rand uvm_ral_field F;

	function new(string name = "B");
		super.new(name,uvm_ral::NO_COVERAGE);
	endfunction: new

   virtual function void build();

                // create regs
		R   =   ral_reg_B_R::type_id::create("R");
		CTL = ral_reg_B_CTL::type_id::create("CTL");

                // build regs
		R.build   ();
                R.configure(this, null);
		CTL.build ();
                CTL.configure(this, null);

                // create map
                default_map = create_map("default_map", 'h0, 1, uvm_ral::LITTLE_ENDIAN);
                default_map.add_reg(R, 'h0, "RW");
                default_map.add_reg(CTL, 'h1, "RW");

                // assign field aliases
		F = R.F;

		Xlock_modelX();
	endfunction : build

	`uvm_object_utils(ral_block_B)

endclass : ral_block_B


`endif
