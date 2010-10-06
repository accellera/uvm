`ifndef RAL_XA0
`define RAL_XA0

`define STR(arg) `"arg`"

class ral_reg_xa0_xbus_rf_addr_reg_bkdr extends uvm_ral_reg_backdoor;

	function new(uvm_ral_reg __ral_reg);
		super.new(__ral_reg);
	endfunction

	virtual task read(output uvm_ral::status_e status,
	                  output bit [`UVM_RAL_DATA_WIDTH-1:0] data,
	                  input uvm_sequence_base parent = null,
	                  input uvm_tlm_extension extension = null);
		super.pre_read(parent, extension);
                `ifndef UVM_NO_BACKDOOR_DPI
                void'(uvm_hdl_read({`STR(`XA0_TOP_PATH),".reg_file.addr_reg"},data));
                `else
		data = `XA0_TOP_PATH.reg_file.addr_reg;
                `endif
		status = uvm_ral::IS_OK;
		super.post_read(status, data, parent, extension);
	endtask

	virtual task write(output uvm_ral::status_e status,
	                   input bit [`UVM_RAL_DATA_WIDTH-1:0] data,
	                   input uvm_sequence_base parent = null,
	                   input uvm_tlm_extension extension = null);
		super.pre_write(data, parent, extension);
                `ifndef UVM_NO_BACKDOOR_DPI
                void'(uvm_hdl_deposit({`STR(`XA0_TOP_PATH),".reg_file.addr_reg"},data));
                `else
		`XA0_TOP_PATH.reg_file.addr_reg = data;
                `endif
		status = uvm_ral::IS_OK;
		super.post_write(status, data, parent, extension);
	endtask
endclass


class ral_reg_xa0_xbus_rf_config_reg_bkdr extends uvm_ral_reg_backdoor;

	function new(uvm_ral_reg __ral_reg);
		super.new(__ral_reg);
	endfunction

	virtual task read(output uvm_ral::status_e status,
	                  output bit [`UVM_RAL_DATA_WIDTH-1:0] data,
	                  input uvm_sequence_base parent = null,
	                  input uvm_tlm_extension extension = null);
		super.pre_read(parent, extension);
                `ifndef UVM_NO_BACKDOOR_DPI
                begin
                  bit [`UVM_RAL_DATA_WIDTH-1:0] tmp;
                  void'(uvm_hdl_read({`STR(`XA0_TOP_PATH),".reg_file.dest"},tmp)); data[1:0] = tmp; 
                  void'(uvm_hdl_read({`STR(`XA0_TOP_PATH),".reg_file.kind"},tmp)); data[3:2] = tmp;
                  void'(uvm_hdl_read({`STR(`XA0_TOP_PATH),".reg_file.rsvd"},tmp)); data[7:4] = tmp;
                end
                `else
		begin
			data = `UVM_RAL_DATA_WIDTH'h0;
			data[1:0] = `XA0_TOP_PATH.reg_file.dest;
			data[3:2] = `XA0_TOP_PATH.reg_file.kind;
			data[7:4] = `XA0_TOP_PATH.reg_file.rsvd;
		end
                `endif
		status = uvm_ral::IS_OK;
		super.post_read(status, data, parent, extension);
	endtask

	virtual task write(output uvm_ral::status_e status,
	                   input bit [`UVM_RAL_DATA_WIDTH-1:0] data,
	                   input uvm_sequence_base parent = null,
	                   input uvm_tlm_extension extension = null);
		super.pre_write(data, parent, extension);
                `ifndef UVM_NO_BACKDOOR_DPI
                begin
                  void'(uvm_hdl_deposit({`STR(`XA0_TOP_PATH),".reg_file.dest"},data[1:0]));
                  void'(uvm_hdl_deposit({`STR(`XA0_TOP_PATH),".reg_file.kind"},data[3:2]));
                  void'(uvm_hdl_deposit({`STR(`XA0_TOP_PATH),".reg_file.rsvd"},data[7:4]));
                end
                `else
		begin
			`XA0_TOP_PATH.reg_file.dest = data[1:0];
			`XA0_TOP_PATH.reg_file.kind = data[3:2];
			`XA0_TOP_PATH.reg_file.rsvd = data[7:4];
		end
                `endif
		status = uvm_ral::IS_OK;
		super.post_write(status, data, parent, extension);
	endtask
endclass


class ral_reg_xa0_xbus_rf_user_acp_reg_bkdr extends uvm_ral_reg_backdoor;

	function new(uvm_ral_reg __ral_reg);
		super.new(__ral_reg);
	endfunction

	virtual task read(output uvm_ral::status_e status,
	                  output bit [`UVM_RAL_DATA_WIDTH-1:0] data,
	                  input uvm_sequence_base parent = null,
	                  input uvm_tlm_extension extension = null);
		super.pre_read(parent, extension);
                `ifndef UVM_NO_BACKDOOR_DPI
                void'(uvm_hdl_read({`STR(`XA0_TOP_PATH),".reg_file.user_reg"},data));
                `else
		data = `XA0_TOP_PATH.reg_file.user_reg;
                `endif
		status = uvm_ral::IS_OK;
		super.post_read(status, data, parent, extension);
	endtask

	virtual task write(output uvm_ral::status_e status,
	                   input bit [`UVM_RAL_DATA_WIDTH-1:0] data,
	                   input uvm_sequence_base parent = null,
	                   input uvm_tlm_extension extension = null);
		super.pre_write(data, parent, extension);
                `ifndef UVM_NO_BACKDOOR_DPI
                void'(uvm_hdl_deposit({`STR(`XA0_TOP_PATH),".reg_file.user_reg"},data));
                `else
		`XA0_TOP_PATH.reg_file.user_reg = data;
                `endif
		status = uvm_ral::IS_OK;
		super.post_write(status, data, parent, extension);
	endtask
endclass


class ral_reg_xa0_xbus_rf_swr_reg_bkdr extends uvm_ral_reg_backdoor;

	function new(uvm_ral_reg __ral_reg);
		super.new(__ral_reg);
	endfunction

	virtual task read(output uvm_ral::status_e status,
	                  output bit [`UVM_RAL_DATA_WIDTH-1:0] data,
	                  input uvm_sequence_base parent = null,
	                  input uvm_tlm_extension extension = null);
		super.pre_read(parent, extension);
                `ifndef UVM_NO_BACKDOOR_DPI
                void'(uvm_hdl_read({`STR(`XA0_TOP_PATH),".reg_file.shared_wr_reg"},data));
                `else
		data = `XA0_TOP_PATH.reg_file.shared_wr_reg;
                `endif
		status = uvm_ral::IS_OK;
		super.post_read(status, data, parent, extension);
	endtask

	virtual task write(output uvm_ral::status_e status,
	                   input bit [`UVM_RAL_DATA_WIDTH-1:0] data,
	                   input uvm_sequence_base parent = null,
	                   input uvm_tlm_extension extension = null);
		super.pre_write(data, parent, extension);
                `ifndef UVM_NO_BACKDOOR_DPI
                void'(uvm_hdl_deposit({`STR(`XA0_TOP_PATH),".reg_file.shared_wr_reg"},data));
                `else
		`XA0_TOP_PATH.reg_file.shared_wr_reg = data;
                `endif
		status = uvm_ral::IS_OK;
		super.post_write(status, data, parent, extension);
	endtask
endclass


class ral_reg_xa0_xbus_rf_srd_reg_bkdr extends uvm_ral_reg_backdoor;

	function new(uvm_ral_reg __ral_reg);
		super.new(__ral_reg);
	endfunction

	virtual task read(output uvm_ral::status_e status,
	                  output bit [`UVM_RAL_DATA_WIDTH-1:0] data,
	                  input uvm_sequence_base parent = null,
	                  input uvm_tlm_extension extension = null);
		super.pre_read(parent, extension);
                `ifndef UVM_NO_BACKDOOR_DPI
                void'(uvm_hdl_read({`STR(`XA0_TOP_PATH),".reg_file.shared_rd_reg"},data));
                `else
		data = `XA0_TOP_PATH.reg_file.shared_rd_reg;
                `endif
		status = uvm_ral::IS_OK;
		super.post_read(status, data, parent, extension);
	endtask

	virtual task write(output uvm_ral::status_e status,
	                   input bit [`UVM_RAL_DATA_WIDTH-1:0] data,
	                   input uvm_sequence_base parent = null,
	                   input uvm_tlm_extension extension = null);
		status = uvm_ral::ERROR;
	endtask
endclass


class ral_reg_xa0_xbus_rf_xbus_indirect_reg_bkdr extends uvm_ral_reg_backdoor;
	int xbus_indirect_reg;

	function new(uvm_ral_reg __ral_reg, int xbus_indirect_reg);
		super.new(__ral_reg);
		this.xbus_indirect_reg = xbus_indirect_reg;
	endfunction

	virtual task read(output uvm_ral::status_e status,
	                  output bit [`UVM_RAL_DATA_WIDTH-1:0] data,
	                  input uvm_sequence_base parent = null,
	                  input uvm_tlm_extension extension = null);
		super.pre_read(parent, extension);
                `ifndef UVM_NO_BACKDOOR_DPI
                void'(uvm_hdl_read({`STR(`XA0_TOP_PATH),".reg_file.id_reg_values[",$sformatf("%0d",xbus_indirect_reg),"]"},data));
                `else
		data = `XA0_TOP_PATH.reg_file.id_reg_values[xbus_indirect_reg];
                `endif
		status = uvm_ral::IS_OK;
		super.post_read(status, data, parent, extension);
	endtask

	virtual task write(output uvm_ral::status_e status,
	                   input bit [`UVM_RAL_DATA_WIDTH-1:0] data,
	                   input uvm_sequence_base parent = null,
	                   input uvm_tlm_extension extension = null);
		super.pre_write(data, parent, extension);
                `ifndef UVM_NO_BACKDOOR_DPI
                void'(uvm_hdl_deposit({`STR(`XA0_TOP_PATH),".reg_file.id_reg_values[",$sformatf("%0d",xbus_indirect_reg),"]"},data));
                `else
		`XA0_TOP_PATH.reg_file.id_reg_values[xbus_indirect_reg] = data;
                `endif
		status = uvm_ral::IS_OK;
		super.post_write(status, data, parent, extension);
	endtask
endclass


class ral_reg_xa0_xbus_rf_rw_reg_bkdr extends uvm_ral_reg_backdoor;
	int rw_reg;
        string path;

	function new(uvm_ral_reg __ral_reg, int rw_reg);
		super.new(__ral_reg);
		this.rw_reg = rw_reg;
                path = {`STR(`XA0_TOP_PATH),".reg_file.rw_regs[",$sformatf("%0d",rw_reg),"]"};
	endfunction

	virtual task read(output uvm_ral::status_e status,
	                  output bit [`UVM_RAL_DATA_WIDTH-1:0] data,
	                  input uvm_sequence_base parent = null,
	                  input uvm_tlm_extension extension = null);
		super.pre_read(parent, extension);
                `ifndef UVM_NO_BACKDOOR_DPI
                void'(uvm_hdl_read(path,data));
                `else
		data = `XA0_TOP_PATH.reg_file.rw_regs[rw_reg];
                `endif
		status = uvm_ral::IS_OK;
		super.post_read(status, data, parent, extension);
	endtask

	virtual task write(output uvm_ral::status_e status,
	                   input bit [`UVM_RAL_DATA_WIDTH-1:0] data,
	                   input uvm_sequence_base parent = null,
	                   input uvm_tlm_extension extension = null);
		super.pre_write(data, parent, extension);
                `ifndef UVM_NO_BACKDOOR_DPI
                void'(uvm_hdl_deposit(path,data));
                `else
		`XA0_TOP_PATH.reg_file.rw_regs[rw_reg] = data;
                `endif
		status = uvm_ral::IS_OK;
		super.post_write(status, data, parent, extension);
	endtask
endclass


class ral_reg_xa0_xbus_rf_ro_reg_bkdr extends uvm_ral_reg_backdoor;
	int ro_reg;

	function new(uvm_ral_reg __ral_reg, int ro_reg);
		super.new(__ral_reg);
		this.ro_reg = ro_reg;
	endfunction

	virtual task read(output uvm_ral::status_e status,
	                  output bit [`UVM_RAL_DATA_WIDTH-1:0] data,
	                  input uvm_sequence_base parent = null,
	                  input uvm_tlm_extension extension = null);
		super.pre_read(parent, extension);
                `ifndef UVM_NO_BACKDOOR_DPI
                void'(uvm_hdl_read({`STR(`XA0_TOP_PATH),".reg_file.ro_regs[",$sformatf("%0d",ro_reg),"]"},data));
                `else
		data = `XA0_TOP_PATH.reg_file.ro_regs[ro_reg];
                `endif
		status = uvm_ral::IS_OK;
		super.post_read(status, data, parent, extension);
	endtask

	virtual task write(output uvm_ral::status_e status,
	                   input bit [`UVM_RAL_DATA_WIDTH-1:0] data,
	                   input uvm_sequence_base parent = null,
	                   input uvm_tlm_extension extension = null);
		status = uvm_ral::ERROR;
	endtask
endclass


class ral_reg_xa0_xbus_rf_wo_reg_bkdr extends uvm_ral_reg_backdoor;
	int wo_reg;
        string path;

	function new(uvm_ral_reg __ral_reg, int wo_reg);
		super.new(__ral_reg);
		this.wo_reg = wo_reg;
                path = {`STR(`XA0_TOP_PATH),".reg_file.wo_regs[",$sformatf("%0d",wo_reg),"]"};
	endfunction

	virtual task read(output uvm_ral::status_e status,
	                  output bit [`UVM_RAL_DATA_WIDTH-1:0] data,
	                  input uvm_sequence_base parent = null,
	                  input uvm_tlm_extension extension = null);
		super.pre_read(parent, extension);
                `ifndef UVM_NO_BACKDOOR_DPI
                void'(uvm_hdl_read(path,data));
                `else
		data = `XA0_TOP_PATH.reg_file.wo_regs[wo_reg];
                `endif
		status = uvm_ral::IS_OK;
		super.post_read(status, data, parent, extension);
	endtask

	virtual task write(output uvm_ral::status_e status,
	                   input bit [`UVM_RAL_DATA_WIDTH-1:0] data,
	                   input uvm_sequence_base parent = null,
	                   input uvm_tlm_extension extension = null);
		super.pre_write(data, parent, extension);
                `ifndef UVM_NO_BACKDOOR_DPI
                void'(uvm_hdl_deposit(path,data));
                `else
		`XA0_TOP_PATH.reg_file.wo_regs[wo_reg] = data;
                `endif
		status = uvm_ral::IS_OK;
		super.post_write(status, data, parent, extension);
	endtask
endclass


class ral_mem_xa0_xbus_rf_mem_bkdr extends uvm_ral_mem_backdoor;

	function new(uvm_ral_mem __ral_mem);
		super.new(__ral_mem);
	endfunction

	virtual task read(output uvm_ral::status_e status,
	                  input bit [`UVM_RAL_ADDR_WIDTH-1:0] offset,
	                  output bit [`UVM_RAL_DATA_WIDTH-1:0] data,
	                  input uvm_sequence_base parent = null,
	                  input uvm_tlm_extension extension = null);
		super.pre_read(offset, parent, extension);
                `ifndef UVM_NO_BACKDOOR_DPI
                void'(uvm_hdl_read({`STR(`XA0_TOP_PATH),".reg_file.mem[",$sformatf("%0d",offset),"]"},data));
                `else
		data = `XA0_TOP_PATH.reg_file.mem[offset];
                `endif
		status = uvm_ral::IS_OK;
		super.post_read(status, offset, data, parent, extension);
	endtask

	virtual task write(output uvm_ral::status_e status,
	                   input bit [`UVM_RAL_ADDR_WIDTH-1:0] offset,
	                   input bit [`UVM_RAL_DATA_WIDTH-1:0] data,
	                   input uvm_sequence_base parent = null,
	                   input uvm_tlm_extension extension = null);
		super.pre_write(offset, data, parent, extension);
                `ifndef UVM_NO_BACKDOOR_DPI
                void'(uvm_hdl_deposit({`STR(`XA0_TOP_PATH),".reg_file.mem[",$sformatf("%0d",offset),"]"},data));
                `else
		`XA0_TOP_PATH.reg_file.mem[offset] = data;
                `endif
		status = uvm_ral::IS_OK;
		super.post_write(status, offset, data, parent, extension);
	endtask
endclass


class ral_reg_xa0_xbus_rf_addr_reg extends uvm_ral_reg;

        `uvm_register_cb(ral_reg_xa0_xbus_rf_addr_reg, uvm_ral_reg_cbs)
        `uvm_set_super_type(ral_reg_xa0_xbus_rf_addr_reg, uvm_ral_reg)
   
	rand uvm_ral_field addr;

	function new(string name = "xa0_xbus_rf_addr_reg");
		super.new(name,8,uvm_ral::NO_COVERAGE);
	endfunction: new

   virtual function void build();
		addr = uvm_ral_field::type_id::create("addr");
		addr.configure(this, 3, 0, "RW", 3'h1, 'h0, 0, 1);
	endfunction: build

	`uvm_object_utils(ral_reg_xa0_xbus_rf_addr_reg)

endclass : ral_reg_xa0_xbus_rf_addr_reg


class ral_fld_xa0_xbus_rf_config_reg_frame_kind;
	typedef enum bit[1:0] { 
		k0 = 0, 
		k1 = 1, 
		k2 = 2, 
		k3 = 3
	} frame_kind_values;
endclass : ral_fld_xa0_xbus_rf_config_reg_frame_kind


class ral_reg_xa0_xbus_rf_config_reg extends uvm_ral_reg;

        `uvm_register_cb(ral_reg_xa0_xbus_rf_config_reg, uvm_ral_reg_cbs)
        `uvm_set_super_type(ral_reg_xa0_xbus_rf_config_reg, uvm_ral_reg)
   
	rand uvm_ral_field destination;
	rand uvm_ral_field frame_kind;
	rand uvm_ral_field rsvd0;

	constraint frame_kind_c1 {
		frame_kind.value inside {ral_fld_xa0_xbus_rf_config_reg_frame_kind::k1, ral_fld_xa0_xbus_rf_config_reg_frame_kind::k3};	}

	function new(string name = "xa0_xbus_rf_config_reg");
		super.new(name,8,uvm_ral::NO_COVERAGE);
		Xadd_constraintsX("frame_kind_c1");
	endfunction: new

   virtual function void build();
		destination = uvm_ral_field::type_id::create("destination");
		destination.configure(this, 2, 0, "RW", 2'h0, `UVM_RAL_DATA_WIDTH'hx, 0, 0);
		frame_kind = uvm_ral_field::type_id::create("frame_kind");
		frame_kind.configure(this, 2, 2, "RW", 2'h0, `UVM_RAL_DATA_WIDTH'hx, 1, 0);
		rsvd0 = uvm_ral_field::type_id::create("rsvd0");
		rsvd0.configure(this, 4, 4, "RW", 4'hf, 'hf, 0, 0);
	endfunction: build

	`uvm_object_utils(ral_reg_xa0_xbus_rf_config_reg)

endclass : ral_reg_xa0_xbus_rf_config_reg


class ral_reg_xa0_xbus_rf_user_acp_reg extends uvm_ral_reg;

        `uvm_register_cb(ral_reg_xa0_xbus_rf_user_acp_reg, uvm_ral_reg_cbs)
        `uvm_set_super_type(ral_reg_xa0_xbus_rf_user_acp_reg, uvm_ral_reg)
   
	rand uvm_ral_field data_msb;
	rand uvm_ral_field data_lsb;

	function new(string name = "xa0_xbus_rf_user_acp_reg");
		super.new(name,8,uvm_ral::NO_COVERAGE);
	endfunction: new

   virtual function void build();
		data_msb = uvm_ral_field::type_id::create("data_msb");
		data_msb.configure(this, 4, 4, "OTHER", 4'h0, 'h0, 0, 0);
		data_lsb = uvm_ral_field::type_id::create("data_lsb");
		data_lsb.configure(this, 4, 0, "OTHER", 4'h0, 'h0, 0, 0);
                set_attribute("NO_BIT_BASH_TEST", "1");
                set_attribute("NO_REG_ACCESS_TEST", "1");
	endfunction: build

	`uvm_object_utils(ral_reg_xa0_xbus_rf_user_acp_reg)

endclass : ral_reg_xa0_xbus_rf_user_acp_reg


class ral_reg_xa0_xbus_rf_swr_reg extends uvm_ral_reg;

        `uvm_register_cb(ral_reg_xa0_xbus_rf_swr_reg, uvm_ral_reg_cbs)
        `uvm_set_super_type(ral_reg_xa0_xbus_rf_swr_reg, uvm_ral_reg)
   
	rand uvm_ral_field wdata_msb;
	rand uvm_ral_field wdata_lsb;

	function new(string name = "xa0_xbus_rf_swr_reg");
		super.new(name,8,uvm_ral::NO_COVERAGE);
	endfunction: new

   virtual function void build();
		wdata_msb = uvm_ral_field::type_id::create("wdata_msb");
		wdata_msb.configure(this, 4, 4, "WO", 4'h0, `UVM_RAL_DATA_WIDTH'hx, 0, 0);
		wdata_lsb = uvm_ral_field::type_id::create("wdata_lsb");
		wdata_lsb.configure(this, 4, 0, "WO", 4'h0, `UVM_RAL_DATA_WIDTH'hx, 0, 0);
                set_attribute("NO_RAL_TESTS", "1");
	endfunction: build

	`uvm_object_utils(ral_reg_xa0_xbus_rf_swr_reg)

endclass : ral_reg_xa0_xbus_rf_swr_reg


class ral_reg_xa0_xbus_rf_srd_reg extends uvm_ral_reg;

        `uvm_register_cb(ral_reg_xa0_xbus_rf_srd_reg, uvm_ral_reg_cbs)
        `uvm_set_super_type(ral_reg_xa0_xbus_rf_srd_reg, uvm_ral_reg)
   
	uvm_ral_field rdata_msb;
	uvm_ral_field rdata_lsb;

	function new(string name = "xa0_xbus_rf_srd_reg");
		super.new(name,8,uvm_ral::NO_COVERAGE);
	endfunction: new

   virtual function void build();
		rdata_msb = uvm_ral_field::type_id::create("rdata_msb");
		rdata_msb.configure(this, 4, 4, "RO", 4'ha, `UVM_RAL_DATA_WIDTH'hx, 0, 0);
		rdata_lsb = uvm_ral_field::type_id::create("rdata_lsb");
		rdata_lsb.configure(this, 4, 0, "RO", 4'h5, `UVM_RAL_DATA_WIDTH'hx, 0, 0);
	endfunction: build

	`uvm_object_utils(ral_reg_xa0_xbus_rf_srd_reg)

endclass : ral_reg_xa0_xbus_rf_srd_reg


class ral_reg_xa0_xbus_rf_data_reg extends uvm_ral_reg;

        `uvm_register_cb(ral_reg_xa0_xbus_rf_data_reg, uvm_ral_reg_cbs)
        `uvm_set_super_type(ral_reg_xa0_xbus_rf_data_reg, uvm_ral_reg)
   
	rand uvm_ral_field value;

	function new(string name = "xa0_xbus_rf_data_reg");
		super.new(name,8,uvm_ral::NO_COVERAGE);
	endfunction: new

   virtual function void build();
		value = uvm_ral_field::type_id::create("value");
		value.configure(this, 8, 0, "OTHER", 8'h0, `UVM_RAL_DATA_WIDTH'hx, 0, 1);
	endfunction: build

	`uvm_object_utils(ral_reg_xa0_xbus_rf_data_reg)

endclass : ral_reg_xa0_xbus_rf_data_reg


class ral_reg_xa0_xbus_rf_xbus_indirect_reg extends uvm_ral_reg;

        `uvm_register_cb(ral_reg_xa0_xbus_rf_xbus_indirect_reg, uvm_ral_reg_cbs)
        `uvm_set_super_type(ral_reg_xa0_xbus_rf_xbus_indirect_reg, uvm_ral_reg)
   
	rand uvm_ral_field value;

	function new(string name = "xa0_xbus_rf_xbus_indirect_reg");
		super.new(name,8,uvm_ral::NO_COVERAGE);
	endfunction: new

   virtual function void build();
		value = uvm_ral_field::type_id::create("value");
		value.configure(this, 8, 0, "RW", 8'h0, `UVM_RAL_DATA_WIDTH'hx, 0, 1);
	endfunction: build

	`uvm_object_utils(ral_reg_xa0_xbus_rf_xbus_indirect_reg)

endclass : ral_reg_xa0_xbus_rf_xbus_indirect_reg


class ral_reg_xa0_xbus_rf_rw_reg extends uvm_ral_reg;

        `uvm_register_cb(ral_reg_xa0_xbus_rf_rw_reg, uvm_ral_reg_cbs)
        `uvm_set_super_type(ral_reg_xa0_xbus_rf_rw_reg, uvm_ral_reg)
   
	rand uvm_ral_field value;

	function new(string name = "xa0_xbus_rf_rw_reg");
		super.new(name,8,uvm_ral::NO_COVERAGE);
	endfunction: new

   virtual function void build();
		value = uvm_ral_field::type_id::create("value");
		value.configure(this, 8, 0, "RW", 8'h5a, `UVM_RAL_DATA_WIDTH'hx, 0, 1);
	endfunction: build

	`uvm_object_utils(ral_reg_xa0_xbus_rf_rw_reg)

endclass : ral_reg_xa0_xbus_rf_rw_reg


class ral_reg_xa0_xbus_rf_ro_reg extends uvm_ral_reg;

        `uvm_register_cb(ral_reg_xa0_xbus_rf_ro_reg, uvm_ral_reg_cbs)
        `uvm_set_super_type(ral_reg_xa0_xbus_rf_ro_reg, uvm_ral_reg)
   
	uvm_ral_field value;

	function new(string name = "xa0_xbus_rf_ro_reg");
		super.new(name,8,uvm_ral::NO_COVERAGE);
	endfunction: new

   virtual function void build();
		value = uvm_ral_field::type_id::create("value");
		value.configure(this, 8, 0, "RO", 8'ha5, `UVM_RAL_DATA_WIDTH'hx, 0, 1);
	endfunction: build

	`uvm_object_utils(ral_reg_xa0_xbus_rf_ro_reg)

endclass : ral_reg_xa0_xbus_rf_ro_reg


class ral_reg_xa0_xbus_rf_wo_reg extends uvm_ral_reg;

        `uvm_register_cb(ral_reg_xa0_xbus_rf_wo_reg, uvm_ral_reg_cbs)
        `uvm_set_super_type(ral_reg_xa0_xbus_rf_wo_reg, uvm_ral_reg)
   
	rand uvm_ral_field value;

	function new(string name = "xa0_xbus_rf_wo_reg");
		super.new(name,8,uvm_ral::NO_COVERAGE);
	endfunction: new

   virtual function void build();
		value = uvm_ral_field::type_id::create("value");
		value.configure(this, 8, 0, "WO", 8'h55, `UVM_RAL_DATA_WIDTH'hx, 0, 1);
	endfunction: build

	`uvm_object_utils(ral_reg_xa0_xbus_rf_wo_reg)

endclass : ral_reg_xa0_xbus_rf_wo_reg


class ral_mem_xa0_xbus_rf_mem extends uvm_ral_mem;

        `uvm_register_cb(ral_mem_xa0_xbus_rf_mem, uvm_ral_mem_cbs)
        `uvm_set_super_type(ral_mem_xa0_xbus_rf_mem, uvm_ral_mem)
   
	function new(string name = "xa0_xbus_rf_mem");
		super.new(name,'h100,8,"RW",uvm_ral::NO_COVERAGE);
	endfunction: new


   virtual function void build();
	endfunction: build

	`uvm_object_utils(ral_mem_xa0_xbus_rf_mem)

endclass : ral_mem_xa0_xbus_rf_mem


class ral_block_xa0_xbus_rf extends uvm_ral_block;
	rand ral_reg_xa0_xbus_rf_addr_reg          addr_reg;
	rand ral_reg_xa0_xbus_rf_config_reg        config_reg;
	rand ral_reg_xa0_xbus_rf_user_acp_reg      user_acp_reg;
	rand ral_reg_xa0_xbus_rf_swr_reg           swr_reg;
	rand ral_reg_xa0_xbus_rf_srd_reg           srd_reg;
	rand ral_reg_xa0_xbus_rf_data_reg          data_reg;
	rand ral_reg_xa0_xbus_rf_xbus_indirect_reg xbus_indirect_reg[8];
	rand ral_reg_xa0_xbus_rf_rw_reg            rw_reg[4];
	rand ral_reg_xa0_xbus_rf_ro_reg            ro_reg[4];
	rand ral_reg_xa0_xbus_rf_wo_reg            wo_reg[4];
	rand ral_mem_xa0_xbus_rf_mem               mem;

        // optional field aliases
	rand uvm_ral_field addr_reg_addr;
	rand uvm_ral_field addr;
	rand uvm_ral_field config_reg_destination;
	rand uvm_ral_field destination;
	rand uvm_ral_field config_reg_frame_kind;
	rand uvm_ral_field frame_kind;
	rand uvm_ral_field config_reg_rsvd0;
	rand uvm_ral_field rsvd0;
	rand uvm_ral_field user_acp_reg_data_msb;
	rand uvm_ral_field data_msb;
	rand uvm_ral_field user_acp_reg_data_lsb;
	rand uvm_ral_field data_lsb;
	rand uvm_ral_field swr_reg_wdata_msb;
	rand uvm_ral_field wdata_msb;
	rand uvm_ral_field swr_reg_wdata_lsb;
	rand uvm_ral_field wdata_lsb;
	uvm_ral_field srd_reg_rdata_msb;
	uvm_ral_field rdata_msb;
	uvm_ral_field srd_reg_rdata_lsb;
	uvm_ral_field rdata_lsb;
	rand uvm_ral_field data_reg_value;
	rand uvm_ral_field xbus_indirect_reg_value[8];
	rand uvm_ral_field rw_reg_value[4];
	uvm_ral_field ro_reg_value[4];
	rand uvm_ral_field wo_reg_value[4];

	function new(string name = "xa0_xbus_rf");
		super.new(name,uvm_ral::NO_COVERAGE);
	endfunction: new

   virtual function void build();
                
                // create
		addr_reg     = ral_reg_xa0_xbus_rf_addr_reg::type_id::create("addr_reg");
		config_reg   = ral_reg_xa0_xbus_rf_config_reg::type_id::create("config_reg");
		user_acp_reg = ral_reg_xa0_xbus_rf_user_acp_reg::type_id::create("user_acp_reg");
		swr_reg      = ral_reg_xa0_xbus_rf_swr_reg::type_id::create("swr_reg");
		srd_reg      = ral_reg_xa0_xbus_rf_srd_reg::type_id::create("srd_reg");
		data_reg     = ral_reg_xa0_xbus_rf_data_reg::type_id::create("data_reg");


                // build - set parent and optional hdl_path
                addr_reg.build();
                addr_reg.configure(this, null, "addr_reg");
              config_reg.build();
              config_reg.configure(this, null, "config_reg");
            user_acp_reg.build();
            user_acp_reg.configure(this, null, "user_acp_reg");
                 swr_reg.build();
                 swr_reg.configure(this, null, "swr_reg");
                 srd_reg.build();
                 srd_reg.configure(this, null, "srd_reg");
                data_reg.build();
                data_reg.configure(this, null, "data_reg");


                // define address map
                default_map = create_map("default_map", 'h0, 1, uvm_ral::LITTLE_ENDIAN);
                default_map.add_reg(addr_reg,     'h8, "RW");
                default_map.add_reg(config_reg,   'h9, "RW");
                default_map.add_reg(user_acp_reg, 'hA, "RW");
                default_map.add_reg(swr_reg,      'hB, "RW");
                default_map.add_reg(srd_reg,      'hB, "RW");
                default_map.add_reg(data_reg,     'hC, "RW");


                // optional field handle aliases
		addr_reg_addr = addr_reg.addr;
		addr          = addr_reg.addr;

		config_reg_destination = config_reg.destination;
		destination            = config_reg.destination;
		config_reg_frame_kind  = config_reg.frame_kind;
		frame_kind             = config_reg.frame_kind;
		config_reg_rsvd0       = config_reg.rsvd0;
		rsvd0                  = config_reg.rsvd0;

		user_acp_reg_data_msb = user_acp_reg.data_msb;
		data_msb              = user_acp_reg.data_msb;
		user_acp_reg_data_lsb = user_acp_reg.data_lsb;
		data_lsb              = user_acp_reg.data_lsb;

		swr_reg_wdata_msb = swr_reg.wdata_msb;
		wdata_msb         = swr_reg.wdata_msb;
		swr_reg_wdata_lsb = swr_reg.wdata_lsb;
		wdata_lsb         = swr_reg.wdata_lsb;

		srd_reg_rdata_msb = srd_reg.rdata_msb;
		rdata_msb         = srd_reg.rdata_msb;
		srd_reg_rdata_lsb = srd_reg.rdata_lsb;
		rdata_lsb         = srd_reg.rdata_lsb;

		data_reg_value = data_reg.value;



		foreach (xbus_indirect_reg[i]) begin
			string name = $sformatf("xbus_indirect_reg[%0d]",i);
			xbus_indirect_reg[i] = ral_reg_xa0_xbus_rf_xbus_indirect_reg::type_id::create(name);
	     	        xbus_indirect_reg[i].build();
                        xbus_indirect_reg[i].configure(this, null, name);
                        default_map.add_reg(xbus_indirect_reg[i],-1, "RW",1);
			xbus_indirect_reg_value[i] = xbus_indirect_reg[i].value;
		end
		foreach (rw_reg[i]) begin
			string name = $sformatf("rw_reg[%0d]",i);
			rw_reg[i] = ral_reg_xa0_xbus_rf_rw_reg::type_id::create(name);
			rw_reg[i].build();
			rw_reg[i].configure(this, null, name);
                        default_map.add_reg(rw_reg[i], 'h10 + i, "RW");
			rw_reg_value[i] = rw_reg[i].value;
		end
		foreach (ro_reg[i]) begin
			string name = $sformatf("ro_reg[%0d]",i);
			ro_reg[i] = ral_reg_xa0_xbus_rf_ro_reg::type_id::create(name);
			ro_reg[i].build();
			ro_reg[i].configure(this, null, name);
                        default_map.add_reg(ro_reg[i], 'h14 + i, "RW");
			ro_reg_value[i] = ro_reg[i].value;
		end
		foreach (wo_reg[i]) begin
			string name = $sformatf("wo_reg[%0d]",i);
			wo_reg[i] = ral_reg_xa0_xbus_rf_wo_reg::type_id::create(name);
			wo_reg[i].build();
			wo_reg[i].configure(this, null, name);
                        default_map.add_reg(wo_reg[i], 'h18 + i, "RW");
			wo_reg_value[i] = wo_reg[i].value;
		end

		mem = ral_mem_xa0_xbus_rf_mem::type_id::create("mem");
		mem.build();
		mem.configure(this, "mem");
                default_map.add_mem(mem, 'h100, "RW");

		Xlock_modelX();
	endfunction : build

	`uvm_object_utils(ral_block_xa0_xbus_rf)

endclass : ral_block_xa0_xbus_rf


   
class ral_sys_xa0 extends uvm_ral_block;
	rand ral_block_xa0_xbus_rf xbus_rf;

	function new(string name = "xa0");
		super.new(name, uvm_ral::NO_COVERAGE);
	endfunction: new

   function void build();

		xbus_rf = ral_block_xa0_xbus_rf::type_id::create("xbus_rf");
		xbus_rf.build();
		xbus_rf.configure(this, "regfile");

                default_map = create_map("default_map", 'h0, 1, uvm_ral::LITTLE_ENDIAN);
		default_map.add_submap(xbus_rf.default_map, 'h1000);

		//
		// Setting up backdoor access...
		//
		begin
			ral_reg_xa0_xbus_rf_addr_reg_bkdr bkdr = new(xbus_rf.addr_reg);
			xbus_rf.addr_reg.set_backdoor(bkdr);
		end
		begin
			ral_reg_xa0_xbus_rf_config_reg_bkdr bkdr = new(xbus_rf.config_reg);
			xbus_rf.config_reg.set_backdoor(bkdr);
		end
		begin
			ral_reg_xa0_xbus_rf_user_acp_reg_bkdr bkdr = new(xbus_rf.user_acp_reg);
			xbus_rf.user_acp_reg.set_backdoor(bkdr);
		end
		begin
			ral_reg_xa0_xbus_rf_swr_reg_bkdr bkdr = new(xbus_rf.swr_reg);
			xbus_rf.swr_reg.set_backdoor(bkdr);
		end
		begin
			ral_reg_xa0_xbus_rf_srd_reg_bkdr bkdr = new(xbus_rf.srd_reg);
			xbus_rf.srd_reg.set_backdoor(bkdr);
		end
		foreach (xbus_rf.xbus_indirect_reg[i0]) begin
			ral_reg_xa0_xbus_rf_xbus_indirect_reg_bkdr bkdr = new(xbus_rf.xbus_indirect_reg[i0], i0);
			xbus_rf.xbus_indirect_reg[i0].set_backdoor(bkdr);
		end
		foreach (xbus_rf.rw_reg[i0]) begin
			ral_reg_xa0_xbus_rf_rw_reg_bkdr bkdr = new(xbus_rf.rw_reg[i0], i0);
			xbus_rf.rw_reg[i0].set_backdoor(bkdr);
		end
		foreach (xbus_rf.ro_reg[i0]) begin
			ral_reg_xa0_xbus_rf_ro_reg_bkdr bkdr = new(xbus_rf.ro_reg[i0], i0);
			xbus_rf.ro_reg[i0].set_backdoor(bkdr);
		end
		foreach (xbus_rf.wo_reg[i0]) begin
			ral_reg_xa0_xbus_rf_wo_reg_bkdr bkdr = new(xbus_rf.wo_reg[i0], i0);
			xbus_rf.wo_reg[i0].set_backdoor(bkdr);
		end
		begin
			ral_mem_xa0_xbus_rf_mem_bkdr bkdr = new(xbus_rf.mem);
			xbus_rf.mem.set_backdoor(bkdr);
		end


		Xlock_modelX();
	endfunction : build

	`uvm_object_utils(ral_sys_xa0)
endclass : ral_sys_xa0



`endif
