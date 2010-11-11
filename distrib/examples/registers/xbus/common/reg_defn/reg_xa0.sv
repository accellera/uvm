`ifndef REG_XA0
`define REG_XA0

class xa0_xbus_rf_addr_reg_bkdr extends uvm_reg_backdoor;

   function new(string name = "xa0_xbus_rf_addr_reg_bkdr");
      super.new(name);
   endfunction

   virtual task read(uvm_reg_item rw);
      do_pre_read(rw);
      rw.value[0] = `XA0_TOP_PATH.reg_file.addr_reg;
      rw.status = UVM_IS_OK;
      do_post_read(rw);
   endtask

   virtual task write(uvm_reg_item rw);
      do_pre_write(rw);
      `XA0_TOP_PATH.reg_file.addr_reg = rw.value[0];
      rw.status = UVM_IS_OK;
      do_post_write(rw);
   endtask
endclass


class xa0_xbus_rf_addr_reg extends uvm_reg;

   `uvm_register_cb(xa0_xbus_rf_addr_reg, uvm_reg_cbs)
   `uvm_set_super_type(xa0_xbus_rf_addr_reg, uvm_reg)
   
   rand uvm_reg_field addr;

   function new(string name = "xa0_xbus_rf_addr_reg");
      super.new(name,8,UVM_NO_COVERAGE);
   endfunction: new

   virtual function void build();
      addr = uvm_reg_field::type_id::create("addr",,get_full_name());
      addr.configure(this, 3, 0, "RW", 0, 3'h1, 1, 0, 1);
      addr.set_reset('h0, "SOFT");
   endfunction: build

   `uvm_object_utils(xa0_xbus_rf_addr_reg)

endclass : xa0_xbus_rf_addr_reg


class reg_fld_xa0_xbus_rf_config_reg_frame_kind;
   typedef enum bit[1:0] { 
      k0 = 0, 
      k1 = 1, 
      k2 = 2, 
      k3 = 3
   } frame_kind_values;
endclass : reg_fld_xa0_xbus_rf_config_reg_frame_kind


class xa0_xbus_rf_config_reg extends uvm_reg;

   `uvm_register_cb(xa0_xbus_rf_config_reg, uvm_reg_cbs)
   `uvm_set_super_type(xa0_xbus_rf_config_reg, uvm_reg)
   
   rand uvm_reg_field destination;
   rand uvm_reg_field frame_kind;
   rand uvm_reg_field rsvd0;

   constraint frame_kind_c1 {
      frame_kind.value inside {reg_fld_xa0_xbus_rf_config_reg_frame_kind::k1,
                               reg_fld_xa0_xbus_rf_config_reg_frame_kind::k3};   }

   function new(string name = "xa0_xbus_rf_config_reg");
      super.new(name,8,UVM_NO_COVERAGE);
   endfunction: new

   virtual function void build();
      destination = uvm_reg_field::type_id::create("destination",,get_full_name());
      destination.configure(this, 2, 0, "RW", 0, 2'h0, 1, 0, 0);
      frame_kind = uvm_reg_field::type_id::create("frame_kind",,get_full_name());
      frame_kind.configure(this, 2, 2, "RW", 0, 2'h0, 1, 1, 0);
      rsvd0 = uvm_reg_field::type_id::create("rsvd0",,get_full_name());
      rsvd0.configure(this, 4, 4, "RW", 0, 4'hf, 1, 0, 0);
      rsvd0.set_reset('hf, "SOFT");
   endfunction: build

   `uvm_object_utils(xa0_xbus_rf_config_reg)

endclass : xa0_xbus_rf_config_reg


class xa0_xbus_rf_user_acp_reg extends uvm_reg;

   `uvm_register_cb(xa0_xbus_rf_user_acp_reg, uvm_reg_cbs)
   `uvm_set_super_type(xa0_xbus_rf_user_acp_reg, uvm_reg)
   
   rand uvm_reg_field data_msb;
   rand uvm_reg_field data_lsb;

   function new(string name = "xa0_xbus_rf_user_acp_reg");
      super.new(name,8,UVM_NO_COVERAGE);
   endfunction: new

   virtual function void build();
      data_msb = uvm_reg_field::type_id::create("data_msb",,get_full_name());
      data_msb.configure(this, 4, 4, "DC", 0, 4'h0, 1, 0, 0);
      data_msb.set_reset('h0, "SOFT");
      data_lsb = uvm_reg_field::type_id::create("data_lsb",,get_full_name());
      data_lsb.configure(this, 4, 0, "DC", 0, 4'h0, 1, 0, 0);
      data_lsb.set_reset('h0, "SOFT");
      set_attribute("NO_BIT_BASH_TEST", "1");
      set_attribute("NO_REG_ACCESS_TEST", "1");
   endfunction: build

   `uvm_object_utils(xa0_xbus_rf_user_acp_reg)

endclass : xa0_xbus_rf_user_acp_reg


class xa0_xbus_rf_swr_reg extends uvm_reg;

   `uvm_register_cb(xa0_xbus_rf_swr_reg, uvm_reg_cbs)
   `uvm_set_super_type(xa0_xbus_rf_swr_reg, uvm_reg)
   
   rand uvm_reg_field wdata_msb;
   rand uvm_reg_field wdata_lsb;

   function new(string name = "xa0_xbus_rf_swr_reg");
      super.new(name,8,UVM_NO_COVERAGE);
   endfunction: new

   virtual function void build();
      wdata_msb = uvm_reg_field::type_id::create("wdata_msb",,get_full_name());
      wdata_msb.configure(this, 4, 4, "WO", 0, 4'h0, 1, 0, 0);
      wdata_lsb = uvm_reg_field::type_id::create("wdata_lsb",,get_full_name());
      wdata_lsb.configure(this, 4, 0, "WO", 0, 4'h0, 1, 0, 0);
      set_attribute("NO_REG_TESTS", "1");
   endfunction: build

   `uvm_object_utils(xa0_xbus_rf_swr_reg)

endclass : xa0_xbus_rf_swr_reg


class xa0_xbus_rf_srd_reg extends uvm_reg;

   `uvm_register_cb(xa0_xbus_rf_srd_reg, uvm_reg_cbs)
   `uvm_set_super_type(xa0_xbus_rf_srd_reg, uvm_reg)
   
   uvm_reg_field rdata_msb;
   uvm_reg_field rdata_lsb;

   function new(string name = "xa0_xbus_rf_srd_reg");
      super.new(name,8,UVM_NO_COVERAGE);
   endfunction: new

   virtual function void build();
      rdata_msb = uvm_reg_field::type_id::create("rdata_msb",,get_full_name());
      rdata_msb.configure(this, 4, 4, "RO", 0, 4'ha, 1, 0, 0);
      rdata_lsb = uvm_reg_field::type_id::create("rdata_lsb",,get_full_name());
      rdata_lsb.configure(this, 4, 0, "RO", 0, 4'h5, 1, 0, 0);
   endfunction: build

   `uvm_object_utils(xa0_xbus_rf_srd_reg)

endclass : xa0_xbus_rf_srd_reg

class xa0_xbus_rf_data_reg extends uvm_reg_indirect_data;

   `uvm_register_cb(xa0_xbus_rf_data_reg, uvm_reg_cbs)
   `uvm_set_super_type(xa0_xbus_rf_data_reg, uvm_reg)
   
   function new(string name = "xa0_xbus_rf_data_reg");
      super.new(name,8,UVM_NO_COVERAGE);
   endfunction: new

   virtual function void build();
      super.build();
   endfunction: build

   `uvm_object_utils(xa0_xbus_rf_data_reg)

endclass : xa0_xbus_rf_data_reg


class xa0_xbus_rf_xbus_indirect_reg extends uvm_reg;

   `uvm_register_cb(xa0_xbus_rf_xbus_indirect_reg, uvm_reg_cbs)
   `uvm_set_super_type(xa0_xbus_rf_xbus_indirect_reg, uvm_reg)
   
   rand uvm_reg_field value;

   function new(string name = "xa0_xbus_rf_xbus_indirect_reg");
      super.new(name,8,UVM_NO_COVERAGE);
   endfunction: new

   virtual function void build();
      value = uvm_reg_field::type_id::create("value",,get_full_name());
      value.configure(this, 8, 0, "RW", 0, 8'h0, 1, 0, 1);
   endfunction: build

   `uvm_object_utils(xa0_xbus_rf_xbus_indirect_reg)

endclass : xa0_xbus_rf_xbus_indirect_reg


class xa0_xbus_rf_rw_reg extends uvm_reg;

   `uvm_register_cb(xa0_xbus_rf_rw_reg, uvm_reg_cbs)
   `uvm_set_super_type(xa0_xbus_rf_rw_reg, uvm_reg)
   
   rand uvm_reg_field value;

   function new(string name = "xa0_xbus_rf_rw_reg");
      super.new(name,8,UVM_NO_COVERAGE);
   endfunction: new

   virtual function void build();
      value = uvm_reg_field::type_id::create("value",,get_full_name());
      value.configure(this, 8, 0, "RW", 0, 8'h5a, 1, 0, 1);
   endfunction: build

   `uvm_object_utils(xa0_xbus_rf_rw_reg)

endclass : xa0_xbus_rf_rw_reg


class xa0_xbus_rf_ro_reg extends uvm_reg;

   `uvm_register_cb(xa0_xbus_rf_ro_reg, uvm_reg_cbs)
   `uvm_set_super_type(xa0_xbus_rf_ro_reg, uvm_reg)
   
   uvm_reg_field value;

   function new(string name = "xa0_xbus_rf_ro_reg");
      super.new(name,8,UVM_NO_COVERAGE);
   endfunction: new

   virtual function void build();
      value = uvm_reg_field::type_id::create("value",,get_full_name());
      value.configure(this, 8, 0, "RO", 0, 8'ha5, 1, 0, 1);
   endfunction: build

   `uvm_object_utils(xa0_xbus_rf_ro_reg)

endclass : xa0_xbus_rf_ro_reg


class xa0_xbus_rf_wo_reg extends uvm_reg;

        `uvm_register_cb(xa0_xbus_rf_wo_reg, uvm_reg_cbs)
        `uvm_set_super_type(xa0_xbus_rf_wo_reg, uvm_reg)
   
   rand uvm_reg_field value;

   function new(string name = "xa0_xbus_rf_wo_reg");
      super.new(name,8,UVM_NO_COVERAGE);
   endfunction: new

   virtual function void build();
      value = uvm_reg_field::type_id::create("value",,get_full_name());
      value.configure(this, 8, 0, "WO", 0, 8'h55, 1, 0, 1);
   endfunction: build

   `uvm_object_utils(xa0_xbus_rf_wo_reg)

endclass : xa0_xbus_rf_wo_reg


class reg_mem_xa0_xbus_rf_mem extends uvm_mem;

        `uvm_register_cb(reg_mem_xa0_xbus_rf_mem, uvm_reg_cbs)
        `uvm_set_super_type(reg_mem_xa0_xbus_rf_mem, uvm_mem)
   
   function new(string name = "xa0_xbus_rf_mem");
      super.new(name,'h100,8,"RW",UVM_NO_COVERAGE);
   endfunction: new


   virtual function void build();
   endfunction: build

   `uvm_object_utils(reg_mem_xa0_xbus_rf_mem)

endclass : reg_mem_xa0_xbus_rf_mem


class reg_block_xa0_xbus_rf extends uvm_reg_block;
   rand xa0_xbus_rf_addr_reg          addr_reg;
   rand xa0_xbus_rf_config_reg        config_reg;
   rand xa0_xbus_rf_user_acp_reg      user_acp_reg;
   rand xa0_xbus_rf_swr_reg           swr_reg;
   rand xa0_xbus_rf_srd_reg           srd_reg;
   rand xa0_xbus_rf_data_reg          data_reg;
   rand uvm_reg                       xbus_indirect_reg[8];
   rand xa0_xbus_rf_rw_reg            rw_reg[4];
   rand xa0_xbus_rf_ro_reg            ro_reg[4];
   rand xa0_xbus_rf_wo_reg            wo_reg[4];
   rand reg_mem_xa0_xbus_rf_mem               mem;

        // optional field aliases
   rand uvm_reg_field addr_reg_addr;
   rand uvm_reg_field addr;
   rand uvm_reg_field config_reg_destination;
   rand uvm_reg_field destination;
   rand uvm_reg_field config_reg_frame_kind;
   rand uvm_reg_field frame_kind;
   rand uvm_reg_field config_reg_rsvd0;
   rand uvm_reg_field rsvd0;
   rand uvm_reg_field user_acp_reg_data_msb;
   rand uvm_reg_field data_msb;
   rand uvm_reg_field user_acp_reg_data_lsb;
   rand uvm_reg_field data_lsb;
   rand uvm_reg_field swr_reg_wdata_msb;
   rand uvm_reg_field wdata_msb;
   rand uvm_reg_field swr_reg_wdata_lsb;
   rand uvm_reg_field wdata_lsb;
   uvm_reg_field srd_reg_rdata_msb;
   uvm_reg_field rdata_msb;
   uvm_reg_field srd_reg_rdata_lsb;
   uvm_reg_field rdata_lsb;
   rand uvm_reg_field data_reg_value;
   rand uvm_reg_field rw_reg_value[4];
   uvm_reg_field ro_reg_value[4];
   rand uvm_reg_field wo_reg_value[4];

   function new(string name = "xa0_xbus_rf");
      super.new(name,UVM_NO_COVERAGE);
   endfunction: new

   virtual function void build();
                
      default_map = create_map("default_map", 'h0, 1, UVM_LITTLE_ENDIAN);

      addr_reg = xa0_xbus_rf_addr_reg::type_id::create("addr_reg",,get_full_name());
      addr_reg.configure(this, null, "addr_reg");
      addr_reg.build();

      config_reg = xa0_xbus_rf_config_reg::type_id::create("config_reg",,get_full_name());
      config_reg.configure(this, null);
      config_reg.build();

      config_reg.add_hdl_path_slice("rsvd", 4, 4);
      config_reg.add_hdl_path_slice("kind", 2, 2);
      config_reg.add_hdl_path_slice("dest", 0, 2);

        /* same as
      config_reg.add_hdl_path('{ '{"rsvd", 4, 4},
                                 '{"kind", 2, 2},
                                 '{"dest", 0, 2} });
         */ 

      user_acp_reg = xa0_xbus_rf_user_acp_reg::type_id::create("user_acp_reg",,get_full_name());
      user_acp_reg.configure(this, null, "user_reg");
      user_acp_reg.build();

      swr_reg = xa0_xbus_rf_swr_reg::type_id::create("swr_reg",,get_full_name());
      swr_reg.configure(this, null, "shared_wr_reg");
      swr_reg.build();

      srd_reg = xa0_xbus_rf_srd_reg::type_id::create("srd_reg",,get_full_name());
      srd_reg.configure(this, null, "shared_rd_reg");
      srd_reg.build();

      foreach (xbus_indirect_reg[i]) begin
       	 xa0_xbus_rf_xbus_indirect_reg r_;
         string name = $sformatf("xbus_indirect_reg[%0d]",i);
         r_ = xa0_xbus_rf_xbus_indirect_reg::type_id::create(name,,get_full_name());
         xbus_indirect_reg[i]=r_;
         name = $sformatf("id_reg_values[%0d]",i);
         r_.configure(this, null, name);
         default_map.add_reg(r_, -1, "RW",0);
         r_.build();
      end

      data_reg = xa0_xbus_rf_data_reg::type_id::create("data_reg",,get_full_name());
      data_reg.build();
      data_reg.configure(addr_reg, xbus_indirect_reg, this, null);


      // define address map

      default_map.add_reg(addr_reg,      'h8, "RW");
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

      foreach (rw_reg[i]) begin
         string name = $sformatf("rw_reg[%0d]",i);
         rw_reg[i] = xa0_xbus_rf_rw_reg::type_id::create(name,,get_full_name());
         name = $sformatf("rw_regs[%0d]",i);
         rw_reg[i].configure(this, null, name);
         rw_reg[i].build();
         default_map.add_reg(rw_reg[i], 'h10 + i, "RW");
         rw_reg_value[i] = rw_reg[i].value;
      end
      foreach (ro_reg[i]) begin
         string name = $sformatf("ro_reg[%0d]",i);
         ro_reg[i] = xa0_xbus_rf_ro_reg::type_id::create(name,,get_full_name());
         name = $sformatf("ro_regs[%0d]",i);
         ro_reg[i].configure(this, null, name);
         ro_reg[i].build();
         default_map.add_reg(ro_reg[i], 'h14 + i, "RW");
         ro_reg_value[i] = ro_reg[i].value;
      end
      foreach (wo_reg[i]) begin
         string name = $sformatf("wo_reg[%0d]",i);
         wo_reg[i] = xa0_xbus_rf_wo_reg::type_id::create(name,,get_full_name());
         name = $sformatf("wo_regs[%0d]",i);
         wo_reg[i].build();
         wo_reg[i].configure(this, null, name);
         default_map.add_reg(wo_reg[i], 'h18 + i, "RW");
         wo_reg_value[i] = wo_reg[i].value;
      end

      mem = reg_mem_xa0_xbus_rf_mem::type_id::create("mem",,get_full_name());
      mem.configure(this, "mem");
      mem.build();
      default_map.add_mem(mem, 'h100, "RW");

      lock_model();
   endfunction : build

   `uvm_object_utils(reg_block_xa0_xbus_rf)

endclass : reg_block_xa0_xbus_rf


   
class reg_sys_xa0 extends uvm_reg_block;
   rand reg_block_xa0_xbus_rf xbus_rf;

   function new(string name = "xa0");
      super.new(name, UVM_NO_COVERAGE);
   endfunction: new

   function void build();

      xbus_rf = reg_block_xa0_xbus_rf::type_id::create("xbus_rf",,get_full_name());
      xbus_rf.build();
      xbus_rf.configure(this, "reg_file");

                default_map = create_map("default_map", 'h0, 1, UVM_LITTLE_ENDIAN);
      default_map.add_submap(xbus_rf.default_map, 'h1000);

      //
      // Setting up user-defined backdoor access...
      //
      begin
         xa0_xbus_rf_addr_reg_bkdr bkdr = new(xbus_rf.addr_reg.get_full_name());
         xbus_rf.addr_reg.set_backdoor(bkdr);
      end

      lock_model();
   endfunction : build

   `uvm_object_utils(reg_sys_xa0)
endclass : reg_sys_xa0



`endif
