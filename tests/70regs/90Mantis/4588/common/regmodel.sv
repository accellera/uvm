`ifndef RAL_SLAVE
`define RAL_SLAVE

import uvm_pkg::*;
`include "uvm_macros.svh"

class ral_reg_slave_B1_CHIP_ID extends uvm_reg;
	uvm_reg_field REVISION_ID;
	uvm_reg_field CHIP_ID;
	uvm_reg_field PRODUCT_ID;

	function new(string name = "slave_B1_CHIP_ID");
		super.new(name, 32,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.REVISION_ID = uvm_reg_field::type_id::create("REVISION_ID",,get_full_name());
      this.REVISION_ID.configure(this, 8, 0, "RO", 0, 8'h03, 1, 0, 1);
      this.CHIP_ID = uvm_reg_field::type_id::create("CHIP_ID",,get_full_name());
      this.CHIP_ID.configure(this, 8, 8, "RO", 0, 8'h5A, 1, 0, 1);
      this.PRODUCT_ID = uvm_reg_field::type_id::create("PRODUCT_ID",,get_full_name());
      this.PRODUCT_ID.configure(this, 10, 16, "RO", 0, 10'h176, 1, 0, 1);
   endfunction: build

	`uvm_object_utils(ral_reg_slave_B1_CHIP_ID)

endclass : ral_reg_slave_B1_CHIP_ID


class ral_reg_slave_B1_STATUS extends uvm_reg;
	uvm_reg_field BUSY;
	rand uvm_reg_field TXEN;
	rand uvm_reg_field MODE;
	rand uvm_reg_field READY;

	constraint status_reg_valid {
		(MODE.value == 3'h5) -> TXEN.value != 1'b1;
	}

	constraint TXEN_valid {
	}
	constraint MODE_valid {
		MODE.value < 3'h6; 
	}
	constraint READY_valid {
	}

	function new(string name = "slave_B1_STATUS");
		super.new(name, 24,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.BUSY = uvm_reg_field::type_id::create("BUSY",,get_full_name());
      this.BUSY.configure(this, 1, 0, "RO", 0, 1'h0, 1, 0, 0);
      this.TXEN = uvm_reg_field::type_id::create("TXEN",,get_full_name());
      this.TXEN.configure(this, 1, 1, "RW", 0, 1'h0, 1, 1, 0);
      this.MODE = uvm_reg_field::type_id::create("MODE",,get_full_name());
      this.MODE.configure(this, 3, 2, "RW", 0, 3'h0, 1, 1, 0);
      this.READY = uvm_reg_field::type_id::create("READY",,get_full_name());
      this.READY.configure(this, 1, 16, "W1C", 0, 1'h0, 1, 1, 1);
   endfunction: build

	`uvm_object_utils(ral_reg_slave_B1_STATUS)

endclass : ral_reg_slave_B1_STATUS


class ral_reg_slave_B1_MASK extends uvm_reg;
	rand uvm_reg_field READY;

	constraint READY_valid {
	}

	function new(string name = "slave_B1_MASK");
		super.new(name, 24,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.READY = uvm_reg_field::type_id::create("READY",,get_full_name());
      this.READY.configure(this, 1, 16, "RW", 0, 1'h0, 1, 1, 1);
   endfunction: build

	`uvm_object_utils(ral_reg_slave_B1_MASK)

endclass : ral_reg_slave_B1_MASK


class ral_reg_slave_B1_COUNTERS extends uvm_reg;
	uvm_reg_field value;

	function new(string name = "slave_B1_COUNTERS");
		super.new(name, 32,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.value = uvm_reg_field::type_id::create("value",,get_full_name());
      this.value.configure(this, 32, 0, "RO", 0, 32'h0, 1, 0, 1);
   endfunction: build

	`uvm_object_utils(ral_reg_slave_B1_COUNTERS)

endclass : ral_reg_slave_B1_COUNTERS


class ral_mem_slave_B1_DMA_RAM extends uvm_mem;
   function new(string name = "slave_B1_DMA_RAM");
      super.new(name, `UVM_REG_ADDR_WIDTH'h400, 32, "RW", build_coverage(UVM_NO_COVERAGE));
   endfunction
   virtual function void build();
   endfunction: build

   `uvm_object_utils(ral_mem_slave_B1_DMA_RAM)

endclass : ral_mem_slave_B1_DMA_RAM


class ral_block_slave_B1 extends uvm_reg_block;
	rand ral_reg_slave_B1_CHIP_ID CHIP_ID;
	rand ral_reg_slave_B1_STATUS STATUS;
	rand ral_reg_slave_B1_MASK MASK;
	rand ral_reg_slave_B1_COUNTERS COUNTERS[256];
	rand ral_mem_slave_B1_DMA_RAM DMA_RAM;
	uvm_reg_field CHIP_ID_REVISION_ID;
	uvm_reg_field REVISION_ID;
	uvm_reg_field CHIP_ID_CHIP_ID;
	uvm_reg_field CHIP_ID_PRODUCT_ID;
	uvm_reg_field PRODUCT_ID;
	uvm_reg_field STATUS_BUSY;
	uvm_reg_field BUSY;
	rand uvm_reg_field STATUS_TXEN;
	rand uvm_reg_field TXEN;
	rand uvm_reg_field STATUS_MODE;
	rand uvm_reg_field MODE;
	rand uvm_reg_field STATUS_READY;
	rand uvm_reg_field MASK_READY;
	uvm_reg_field COUNTERS_value[256];
	uvm_reg_field value[256];

	function new(string name = "slave_B1");
		super.new(name, build_coverage(UVM_NO_COVERAGE));
	endfunction: new

   virtual function void build();
      this.default_map = create_map("", 0, 4, UVM_LITTLE_ENDIAN, 0);
      this.CHIP_ID = ral_reg_slave_B1_CHIP_ID::type_id::create("CHIP_ID",,get_full_name());
      this.CHIP_ID.configure(this, null, "");
      this.CHIP_ID.build();
      this.default_map.add_reg(this.CHIP_ID, `UVM_REG_ADDR_WIDTH'h0, "RW", 0);
		this.CHIP_ID_REVISION_ID = this.CHIP_ID.REVISION_ID;
		this.REVISION_ID = this.CHIP_ID.REVISION_ID;
		this.CHIP_ID_CHIP_ID = this.CHIP_ID.CHIP_ID;
		this.CHIP_ID_PRODUCT_ID = this.CHIP_ID.PRODUCT_ID;
		this.PRODUCT_ID = this.CHIP_ID.PRODUCT_ID;
      this.STATUS = ral_reg_slave_B1_STATUS::type_id::create("STATUS",,get_full_name());
      this.STATUS.configure(this, null, "");
      this.STATUS.build();
         this.STATUS.add_hdl_path('{
            '{"BUSY", 0, 1},
            '{"TXEN", 1, 1},
            '{"MODE", 2, 3},
            '{"RDY", 16, 1}
         });
      this.default_map.add_reg(this.STATUS, `UVM_REG_ADDR_WIDTH'h4, "RW", 0);
		this.STATUS_BUSY = this.STATUS.BUSY;
		this.BUSY = this.STATUS.BUSY;
		this.STATUS_TXEN = this.STATUS.TXEN;
		this.TXEN = this.STATUS.TXEN;
		this.STATUS_MODE = this.STATUS.MODE;
		this.MODE = this.STATUS.MODE;
		this.STATUS_READY = this.STATUS.READY;
      this.MASK = ral_reg_slave_B1_MASK::type_id::create("MASK",,get_full_name());
      this.MASK.configure(this, null, "");
      this.MASK.build();
         this.MASK.add_hdl_path('{
            '{"RDY_MSK", 16, 1}
         });
      this.default_map.add_reg(this.MASK, `UVM_REG_ADDR_WIDTH'h5, "RW", 0);
		this.MASK_READY = this.MASK.READY;
      foreach (this.COUNTERS[i]) begin
         int J = i;
         this.COUNTERS[J] = ral_reg_slave_B1_COUNTERS::type_id::create($psprintf("COUNTERS[%0d]",J),,get_full_name());
         this.COUNTERS[J].configure(this, null, "");
         this.COUNTERS[J].build();
         this.COUNTERS[J].add_hdl_path('{

            '{$psprintf("COUNTERS[%0d]", J), -1, -1}
         });
         this.default_map.add_reg(this.COUNTERS[J], `UVM_REG_ADDR_WIDTH'h400+J*`UVM_REG_ADDR_WIDTH'h1, "RW", 0);
			this.COUNTERS_value[J] = this.COUNTERS[J].value;
			this.value[J] = this.COUNTERS[J].value;
      end
      this.DMA_RAM = ral_mem_slave_B1_DMA_RAM::type_id::create("DMA_RAM",,get_full_name());
      this.DMA_RAM.configure(this, "DMA");
      this.DMA_RAM.build();
      this.default_map.add_mem(this.DMA_RAM, `UVM_REG_ADDR_WIDTH'h800, "RW", 0);
      uvm_resource_db#(bit)::set({"REG::", this.get_full_name()}, "NO_REG_TESTS", "1", this);
   endfunction : build

	`uvm_object_utils(ral_block_slave_B1)

endclass : ral_block_slave_B1


class ral_sys_slave extends uvm_reg_block;

   rand ral_block_slave_B1 B1;

	function new(string name = "slave");
		super.new(name);
	endfunction: new

	function void build();
      this.default_map = create_map("", 0, 4, UVM_LITTLE_ENDIAN, 0);
      this.B1 = ral_block_slave_B1::type_id::create("B1",,get_full_name());
      this.B1.configure(this, "");
      this.B1.build();
      this.default_map.add_submap(this.B1.default_map, `UVM_REG_ADDR_WIDTH'h0);
	endfunction : build

	`uvm_object_utils(ral_sys_slave)
endclass : ral_sys_slave



`endif
