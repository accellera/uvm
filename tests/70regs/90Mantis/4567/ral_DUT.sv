// -------------------------------------------------------------
//    Copyright 2013 Synopsys, Inc.
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
//    permissions and limitations under t,he License.
// -------------------------------------------------------------
// 
`ifndef RAL_DUT
`define RAL_DUT

import uvm_pkg::*;

class ral_reg_DUT_DUT_BLK_CTRL_REG_bkdr extends uvm_reg_backdoor;

	function new(string name);
		super.new(name);
	endfunction

	virtual task read(uvm_reg_item rw);
		do_pre_read(rw);
		rw.value[0] = `DUT_TOP_PATH.ctrl_reg;
		rw.status = UVM_IS_OK;
		do_post_read(rw);
	endtask

	virtual task write(uvm_reg_item rw);
		do_pre_write(rw);
		`DUT_TOP_PATH.ctrl_reg = rw.value[0];
		rw.status = UVM_IS_OK;
		do_post_write(rw);
	endtask
endclass


class ral_reg_DUT_DUT_BLK_DATA_REG_bkdr extends uvm_reg_backdoor;

	function new(string name);
		super.new(name);
	endfunction

	virtual task read(uvm_reg_item rw);
		do_pre_read(rw);
		rw.value[0] = `DUT_TOP_PATH.data_reg;
		rw.status = UVM_IS_OK;
		do_post_read(rw);
	endtask

	virtual task write(uvm_reg_item rw);
		do_pre_write(rw);
		`DUT_TOP_PATH.data_reg = rw.value[0];
		rw.status = UVM_IS_OK;
		do_post_write(rw);
	endtask
endclass


class ral_reg_DUT_DUT_BLK_STATUS_REG_bkdr extends uvm_reg_backdoor;

	function new(string name);
		super.new(name);
	endfunction

	virtual task read(uvm_reg_item rw);
		do_pre_read(rw);
		rw.value[0] = `DUT_TOP_PATH.status_reg;
		rw.status = UVM_IS_OK;
		do_post_read(rw);
	endtask

	virtual task write(uvm_reg_item rw);
		rw.status = UVM_NOT_OK;
	endtask
endclass


class ral_reg_CTRL_REG extends uvm_reg;
	rand uvm_reg_field REG_VAL;

	function new(string name = "CTRL_REG");
		super.new(name, 24,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.REG_VAL = uvm_reg_field::type_id::create("REG_VAL",,get_full_name());
      this.REG_VAL.configure(this, 8, 0, "RW", 0, 1'b0, 1, 0, 1);
   endfunction: build

	`uvm_object_utils(ral_reg_CTRL_REG)

endclass : ral_reg_CTRL_REG


class ral_reg_DATA_REG extends uvm_reg;
	rand uvm_reg_field REG_VAL;

	function new(string name = "DATA_REG");
		super.new(name, 24,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.REG_VAL = uvm_reg_field::type_id::create("REG_VAL",,get_full_name());
      this.REG_VAL.configure(this, 8, 0, "RW", 0, 1'b0, 1, 0, 1);
   endfunction: build

	`uvm_object_utils(ral_reg_DATA_REG)

endclass : ral_reg_DATA_REG


class ral_reg_STATUS_REG extends uvm_reg;
	uvm_reg_field WR_ERROR;
	uvm_reg_field RD_ERROR;

	function new(string name = "STATUS_REG");
		super.new(name, 24,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.WR_ERROR = uvm_reg_field::type_id::create("WR_ERROR",,get_full_name());
      this.WR_ERROR.configure(this, 1, 0, "RO", 0, 1'b0, 1, 0, 0);
      this.RD_ERROR = uvm_reg_field::type_id::create("RD_ERROR",,get_full_name());
      this.RD_ERROR.configure(this, 1, 4, "RO", 0, 1'b0, 1, 0, 0);
   endfunction: build

	`uvm_object_utils(ral_reg_STATUS_REG)

endclass : ral_reg_STATUS_REG


class ral_block_DUT_BLK extends uvm_reg_block;
	rand ral_reg_CTRL_REG CTRL_REG;
	rand ral_reg_DATA_REG DATA_REG;
	rand ral_reg_STATUS_REG STATUS_REG;
	rand uvm_reg_field CTRL_REG_REG_VAL;
	rand uvm_reg_field DATA_REG_REG_VAL;
	uvm_reg_field STATUS_REG_WR_ERROR;
	uvm_reg_field WR_ERROR;
	uvm_reg_field STATUS_REG_RD_ERROR;
	uvm_reg_field RD_ERROR;

	function new(string name = "DUT_BLK");
		super.new(name, build_coverage(UVM_NO_COVERAGE));
	endfunction: new

   virtual function void build();
      this.default_map = create_map("", 0, 3, UVM_LITTLE_ENDIAN, 0);
      this.CTRL_REG = ral_reg_CTRL_REG::type_id::create("CTRL_REG",,get_full_name());
      this.CTRL_REG.configure(this, null, "");
      this.CTRL_REG.build();
         this.CTRL_REG.add_hdl_path('{

            '{"ctrl_reg", -1, -1}
         });
      this.default_map.add_reg(this.CTRL_REG, `UVM_REG_ADDR_WIDTH'h0, "RW", 0);
		this.CTRL_REG_REG_VAL = this.CTRL_REG.REG_VAL;
      this.DATA_REG = ral_reg_DATA_REG::type_id::create("DATA_REG",,get_full_name());
      this.DATA_REG.configure(this, null, "");
      this.DATA_REG.build();
         this.DATA_REG.add_hdl_path('{

            '{"data_reg", -1, -1}
         });
      this.default_map.add_reg(this.DATA_REG, `UVM_REG_ADDR_WIDTH'h1, "RW", 0);
		this.DATA_REG_REG_VAL = this.DATA_REG.REG_VAL;
      this.STATUS_REG = ral_reg_STATUS_REG::type_id::create("STATUS_REG",,get_full_name());
      this.STATUS_REG.configure(this, null, "");
      this.STATUS_REG.build();
         this.STATUS_REG.add_hdl_path('{

            '{"status_reg", -1, -1}
         });
      this.default_map.add_reg(this.STATUS_REG, `UVM_REG_ADDR_WIDTH'h2, "RW", 0);
		this.STATUS_REG_WR_ERROR = this.STATUS_REG.WR_ERROR;
		this.WR_ERROR = this.STATUS_REG.WR_ERROR;
		this.STATUS_REG_RD_ERROR = this.STATUS_REG.RD_ERROR;
		this.RD_ERROR = this.STATUS_REG.RD_ERROR;
   endfunction : build

	`uvm_object_utils(ral_block_DUT_BLK)

endclass : ral_block_DUT_BLK


class ral_sys_DUT extends uvm_reg_block;

   rand ral_block_DUT_BLK DUT_BLK;

	function new(string name = "DUT");
		super.new(name);
	endfunction: new

	function void build();
      this.default_map = create_map("", 0, 3, UVM_LITTLE_ENDIAN, 0);
      this.DUT_BLK = ral_block_DUT_BLK::type_id::create("DUT_BLK",,get_full_name());
      this.DUT_BLK.configure(this, "");
      this.DUT_BLK.build();
      this.default_map.add_submap(this.DUT_BLK.default_map, `UVM_REG_ADDR_WIDTH'h0);

		//
		// Setting up backdoor access...
		//
		begin
			ral_reg_DUT_DUT_BLK_CTRL_REG_bkdr bkdr = new(this.DUT_BLK.CTRL_REG.get_full_name());
			this.DUT_BLK.CTRL_REG.set_backdoor(bkdr);
		end
		begin
			ral_reg_DUT_DUT_BLK_DATA_REG_bkdr bkdr = new(this.DUT_BLK.DATA_REG.get_full_name());
			this.DUT_BLK.DATA_REG.set_backdoor(bkdr);
		end
		begin
			ral_reg_DUT_DUT_BLK_STATUS_REG_bkdr bkdr = new(this.DUT_BLK.STATUS_REG.get_full_name());
			this.DUT_BLK.STATUS_REG.set_backdoor(bkdr);
		end
	endfunction : build

	`uvm_object_utils(ral_sys_DUT)
endclass : ral_sys_DUT



`endif
