`ifndef RDB_SV
`define RDB_SV

class ureg_type extends uvm_reg;

  rand uvm_reg_field data;

  virtual function void build();
    data = uvm_reg_field::type_id::create("data");
    data.configure(this, 32, 0, "RW", 0, 0, 0, 1, 0);
  endfunction

  `uvm_register_cb(ureg_type, uvm_reg_cbs) 
  `uvm_set_super_type(ureg_type, uvm_reg)
  `uvm_object_utils(ureg_type)
  function new(input string name="unnamed-ureg_type");
    super.new(name, 32, UVM_NO_COVERAGE);
  endfunction : new
endclass : ureg_type

class ireg_type extends uvm_reg;

  rand uvm_reg_field data;

  virtual function void build();
    data = uvm_reg_field::type_id::create("data");
    data.configure(this, 32, 0, "RW", 0, 0, 0, 1, 0);
  endfunction

  `uvm_register_cb(ireg_type, uvm_reg_cbs) 
  `uvm_set_super_type(ireg_type, uvm_reg)
  `uvm_object_utils(ireg_type)
  function new(input string name="unnamed-ireg_type");
    super.new(name, 32, UVM_NO_COVERAGE);
  endfunction : new
endclass : ireg_type


class uart_rf_type extends uvm_reg_block;

  rand ureg_type ureg[1:10];
  rand ireg_type ireg[1:10];
  uvm_reg_map ahb_map;
  uvm_reg_map apb_map;

  virtual function void build();
    
// Now create all registers

    for(int x=1; x<=10; x++)
    begin
      ureg[x] = ureg_type::type_id::create(
        $sformatf("ureg[%0d]", x), , get_full_name());
      ireg[x] = ireg_type::type_id::create(
        $sformatf("ireg[%0d]", x), , get_full_name());
    end

    // Now build the registers. Set parent and hdl_paths

    for(int x=1; x<=10; x++)
    begin
      uvm_reg_addr_t laddr=4*x;
      ureg[x].build();
      ureg[x].configure(this, null, $sformatf("ureg[%0d]",x));
      ireg[x].build();
      ireg[x].configure(this, null, $sformatf("ireg[%0d]",x));
    end

    // Now define address mappings

    ahb_map = create_map("ahb_map", 0, 4, UVM_LITTLE_ENDIAN);    
    apb_map = create_map("apb_map", 0, 4, UVM_LITTLE_ENDIAN);    
    default_map = create_map("default_map", 0, 4, UVM_LITTLE_ENDIAN);
    for(int x=1; x<=10; x++)
    begin
      uvm_reg_addr_t laddr=4*x;
      ahb_map.add_reg(ureg[x], laddr, "RW");
      apb_map.add_reg(ureg[x], laddr, "RW");
      laddr='h100+4*x;
      ahb_map.add_reg(ireg[x], laddr, "RW");
      apb_map.add_reg(ireg[x], laddr, "RW");
    end
  endfunction

  `uvm_object_utils(uart_rf_type)
  function new(input string name="unnamed-uart_rf");
    super.new(name, UVM_NO_COVERAGE);
  endfunction : new

endclass : uart_rf_type


class rfile_type extends uvm_reg_block;

  rand uart_rf_type uart_rf;
  uvm_reg_map ahb_map;
  uvm_reg_map apb_map;

  virtual function void build();
    
// Now create all registers

    uart_rf = uart_rf_type::type_id::create("uart_rf", , get_full_name());

    // Now build the registers. Set parent and hdl_paths

    uart_rf.build();
    uart_rf.configure(this, "uart");
    uart_rf.lock_model();

    // Now define address mappings

    ahb_map = create_map("ahb_map", 0, 4, UVM_LITTLE_ENDIAN);    
    apb_map = create_map("apb_map", 0, 4, UVM_LITTLE_ENDIAN);    
    ahb_map.add_submap(uart_rf.ahb_map, 'h0);
    apb_map.add_submap(uart_rf.apb_map, 'h1000);
    `ifndef FAIL
    this.lock_model();
    `endif
  endfunction

  `uvm_object_utils(rfile_type)
  function new(input string name="unnamed-rfile");
    super.new(name, UVM_NO_COVERAGE);
  endfunction : new

endclass : rfile_type


`endif // RDB_SV
