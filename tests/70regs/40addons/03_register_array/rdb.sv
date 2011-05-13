`ifndef RDB_SV
`define RDB_SV

// Input File: ipxact_example.spirit

// Number of addrMaps = 1
// Number of regFiles = 1
// Number of registers = 3
// Number of memories = 0

package my_pkg;

  import uvm_pkg::*;
  `include "uvm_macros.svh"


//////////////////////////////////////////////////////////////////////////////
// Register definition
//////////////////////////////////////////////////////////////////////////////
// Line Number: 17


class reg_table_a_t extends uvm_reg;

  rand uvm_reg_field data;

  virtual function void build();
    data = uvm_reg_field::type_id::create("data");
    data.configure(this, 64, 0, "RW", 0, `UVM_REG_DATA_WIDTH'ha5a5a5a5a5a5a5a5>>0, 1, 1, 1);
  endfunction

  `uvm_register_cb(reg_table_a_t, uvm_reg_cbs) 
  `uvm_set_super_type(reg_table_a_t, uvm_reg)
  `uvm_object_utils(reg_table_a_t)
  function new(input string name="unnamed-reg_table_a_t");
    super.new(name, 64, UVM_NO_COVERAGE);
  endfunction : new
endclass : reg_table_a_t

//////////////////////////////////////////////////////////////////////////////
// Register definition
//////////////////////////////////////////////////////////////////////////////
// Line Number: 35


class reg_table_b_t extends uvm_reg;

  rand uvm_reg_field data;

  virtual function void build();
    data = uvm_reg_field::type_id::create("data");
    data.configure(this, 32, 0, "RW", 0, `UVM_REG_DATA_WIDTH'h5a5a5a5a>>0, 1, 1, 1);
  endfunction

  `uvm_register_cb(reg_table_b_t, uvm_reg_cbs) 
  `uvm_set_super_type(reg_table_b_t, uvm_reg)
  `uvm_object_utils(reg_table_b_t)
  function new(input string name="unnamed-reg_table_b_t");
    super.new(name, 32, UVM_NO_COVERAGE);
  endfunction : new
endclass : reg_table_b_t

//////////////////////////////////////////////////////////////////////////////
// Register definition
//////////////////////////////////////////////////////////////////////////////
// Line Number: 55


class reg_table_c_t extends uvm_reg;

  rand uvm_reg_field data;

  virtual function void build();
    data = uvm_reg_field::type_id::create("data");
    data.configure(this, 32, 0, "RW", 0, `UVM_REG_DATA_WIDTH'ha5a5a5a5>>0, 1, 1, 1);
  endfunction

  `uvm_register_cb(reg_table_c_t, uvm_reg_cbs) 
  `uvm_set_super_type(reg_table_c_t, uvm_reg)
  `uvm_object_utils(reg_table_c_t)
  function new(input string name="unnamed-reg_table_c_t");
    super.new(name, 32, UVM_NO_COVERAGE);
  endfunction : new
endclass : reg_table_c_t

class my_rf0_t extends uvm_reg_block;

  rand reg_table_a_t reg_table_a[1:16];
  rand reg_table_b_t reg_table_b[0:7][0:1];
  rand reg_table_c_t reg_table_c[1:4];

  virtual function void build();

    // Now create all registers

    for(int x=1; x<=16; x++)
    begin
      reg_table_a[x] = reg_table_a_t::type_id::create(
        $sformatf("reg_table_a[%0d]", x), , get_full_name());
    end
    for(int y=0; y<=1; y++)
    begin
      for(int x=0; x<=7; x++)
      begin
          reg_table_b[x][y] = reg_table_b_t::type_id::create(
          $sformatf("reg_table_b[%0d][%0d]", x, y), , get_full_name());
      end
    end
    for(int x=1; x<=4; x++)
    begin
      reg_table_c[x] = reg_table_c_t::type_id::create(
        $sformatf("reg_table_c[%0d]", x), , get_full_name());
    end

    // Now build the registers. Set parent and hdl_paths

    for(int x=1; x<=16; x++)
    begin
      uvm_reg_addr_t laddr='h11+((x-1)*8)-1;
      reg_table_a[x].configure(this, null, $sformatf("reg_a[%0d]", x));
      reg_table_a[x].build();
    end
    for(int y=0; y<=1; y++)
    begin
      for(int x=0; x<=7; x++)
      begin
        uvm_reg_addr_t laddr='h200*(y+1)+((x)*4);
        reg_table_b[x][y].configure(this, null, $sformatf("reg_b[%0d][%0d]", y, x));
        reg_table_b[x][y].build();
      end
    end
    for(int x=1; x<=4; x++)
    begin
      uvm_reg_addr_t laddr='h1001+((x-1)*4)-1;
      reg_table_c[x].configure(this, null, $sformatf("reg_c%0d",x));
      reg_table_c[x].build();
    end
    // Now define address mappings
    default_map = create_map("default_map", 0, 8, UVM_LITTLE_ENDIAN);
    for(int x=1; x<=16; x++)
    begin
      uvm_reg_addr_t laddr='h11+((x-1)*8)-1;
      default_map.add_reg(reg_table_a[x], laddr, "RW");
    end
    for(int y=0; y<=1; y++)
    begin
      for(int x=0; x<=7; x++)
      begin
        uvm_reg_addr_t laddr='h200*(y+1)+((x)*4);
        default_map.add_reg(reg_table_b[x][y], laddr, "RW");
      end
    end
    for(int x=1; x<=4; x++)
    begin
      uvm_reg_addr_t laddr='h1001+((x-1)*4)-1;
      default_map.add_reg(reg_table_c[x], laddr, "RW");
    end
  endfunction

  `uvm_object_utils(my_rf0_t)
  function new(input string name="unnamed-my_rf0");
    super.new(name, UVM_NO_COVERAGE);
  endfunction : new
endclass : my_rf0_t

//////////////////////////////////////////////////////////////////////////////
// Address_map definition
//////////////////////////////////////////////////////////////////////////////
class mmap0_t extends uvm_reg_block;

  rand my_rf0_t my_rf0;

  function void build();
    // Now define address mappings
    default_map = create_map("default_map", 0, 8, UVM_LITTLE_ENDIAN);
    my_rf0 = my_rf0_t::type_id::create("my_rf0", , get_full_name());
    my_rf0.configure(this, "dut");
    my_rf0.build();
    my_rf0.lock_model();
    default_map.add_submap(my_rf0.default_map, `UVM_REG_ADDR_WIDTH'h10000);
    set_hdl_path_root("top");
    this.lock_model();
  endfunction
  `uvm_object_utils(mmap0_t)
  function new(input string name="unnamed-mmap0_t");
    super.new(name, UVM_NO_COVERAGE);
  endfunction
endclass : mmap0_t
 
endpackage //my_pkg


`endif // RDB_SV
