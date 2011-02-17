//
//------------------------------------------------------------------------------
//   Copyright 2011 (Authors)
//   All Rights Reserved Worldwide
//
//   Licensed under the Apache License, Version 2.0 (the
//   "License"); you may not use this file except in
//   compliance with the License.  You may obtain a copy of
//   the License at
//
//       http://www.apache.org/licenses/LICENSE-2.0
//
//   Unless required by applicable law or agreed to in
//   writing, software distributed under the License is
//   distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
//   CONDITIONS OF ANY KIND, either express or implied.  See
//   the License for the specific language governing
//   permissions and limitations under the License.
//------------------------------------------------------------------------------

`ifndef RDB_SV
`define RDB_SV

// Input File: ipxact_example.spirit

// Number of addrMaps = 1
// Number of regFiles = 1
// Number of registers = 10
// Number of memories = 0

package my_pkg;

  import uvm_pkg::*;
  `include "uvm_macros.svh"


//////////////////////////////////////////////////////////////////////////////
// Register definition
//////////////////////////////////////////////////////////////////////////////
// Line Number: 18

class ureg0_t extends uvm_reg;

  typedef enum logic [1:0] {
    k0=0, k1=1, k2=2, k3=3
  } framek_enum;

  rand uvm_reg_field destination;
  rand uvm_reg_field frame_kind;
  rand uvm_reg_field rsvd;

  constraint frame_kind_enum {
    frame_kind.value inside { k0, k1, k2, k3 };
  }
  virtual function void build();
    destination = uvm_reg_field::type_id::create("destination");
    destination.configure(this, 14, 0, "RW", 0, `UVM_REG_DATA_WIDTH'h0>>0, 1, 1, 0);
    frame_kind = uvm_reg_field::type_id::create("frame_kind");
    frame_kind.configure(this, 2, 14, "RW", 0, `UVM_REG_DATA_WIDTH'h0>>14, 1, 1, 0);
    rsvd = uvm_reg_field::type_id::create("rsvd");
    rsvd.configure(this, 16, 16, "RW", 0, `UVM_REG_DATA_WIDTH'h0>>16, 1, 1, 0);
  endfunction

  `uvm_register_cb(ureg0_t, uvm_reg_cbs) 
  `uvm_set_super_type(ureg0_t, uvm_reg)
  `uvm_object_utils(ureg0_t)
  function new(input string name="unnamed-ureg0_t");super.new(name, 32, UVM_NO_COVERAGE);
  endfunction : new
endclass : ureg0_t


//////////////////////////////////////////////////////////////////////////////
// Register definition
//////////////////////////////////////////////////////////////////////////////
// Line Number: 70

class ureg1_t extends uvm_reg;

  typedef enum logic [1:0] {
    k0=0, k1=1, k2=2, k3=3
  } framek_enum;

  rand uvm_reg_field destination;
  rand uvm_reg_field frame_kind;
  rand uvm_reg_field rsvd;

  constraint frame_kind_enum {
    frame_kind.value inside { k0, k1, k2, k3 };
  }
  virtual function void build();
    destination = uvm_reg_field::type_id::create("destination");
    destination.configure(this, 14, 0, "RW", 0, `UVM_REG_DATA_WIDTH'h0>>0, 1, 1, 0);
    frame_kind = uvm_reg_field::type_id::create("frame_kind");
    frame_kind.configure(this, 2, 14, "RW", 0, `UVM_REG_DATA_WIDTH'h0>>14, 1, 1, 0);
    rsvd = uvm_reg_field::type_id::create("rsvd");
    rsvd.configure(this, 16, 16, "RW", 0, `UVM_REG_DATA_WIDTH'h0>>16, 1, 1, 0);
  endfunction

  `uvm_register_cb(ureg1_t, uvm_reg_cbs) 
  `uvm_set_super_type(ureg1_t, uvm_reg)
  `uvm_object_utils(ureg1_t)
  function new(input string name="unnamed-ureg1_t");super.new(name, 32, UVM_NO_COVERAGE);
  endfunction : new
endclass : ureg1_t


//////////////////////////////////////////////////////////////////////////////
// Register definition
//////////////////////////////////////////////////////////////////////////////
// Line Number: 122

class ureg2_t extends uvm_reg;

  typedef enum logic [1:0] {
    k0=0, k1=1, k2=2, k3=3
  } framek_enum;

  rand uvm_reg_field destination;
  rand uvm_reg_field frame_kind;
  rand uvm_reg_field rsvd;

  constraint frame_kind_enum {
    frame_kind.value inside { k0, k1, k2, k3 };
  }
  virtual function void build();
    destination = uvm_reg_field::type_id::create("destination");
    destination.configure(this, 14, 0, "RW", 0, `UVM_REG_DATA_WIDTH'h0>>0, 1, 1, 0);
    frame_kind = uvm_reg_field::type_id::create("frame_kind");
    frame_kind.configure(this, 2, 14, "RW", 0, `UVM_REG_DATA_WIDTH'h0>>14, 1, 1, 0);
    rsvd = uvm_reg_field::type_id::create("rsvd");
    rsvd.configure(this, 16, 16, "RW", 0, `UVM_REG_DATA_WIDTH'h0>>16, 1, 1, 0);
  endfunction

  `uvm_register_cb(ureg2_t, uvm_reg_cbs) 
  `uvm_set_super_type(ureg2_t, uvm_reg)
  `uvm_object_utils(ureg2_t)
  function new(input string name="unnamed-ureg2_t");super.new(name, 32, UVM_NO_COVERAGE);
  endfunction : new
endclass : ureg2_t


//////////////////////////////////////////////////////////////////////////////
// Register definition
//////////////////////////////////////////////////////////////////////////////
// Line Number: 174

class ureg3_t extends uvm_reg;

  typedef enum logic [1:0] {
    k0=0, k1=1, k2=2, k3=3
  } framek_enum;

  rand uvm_reg_field destination;
  rand uvm_reg_field frame_kind;
  rand uvm_reg_field rsvd;

  constraint frame_kind_enum {
    frame_kind.value inside { k0, k1, k2, k3 };
  }
  virtual function void build();
    destination = uvm_reg_field::type_id::create("destination");
    destination.configure(this, 14, 0, "RW", 0, `UVM_REG_DATA_WIDTH'h0>>0, 1, 1, 0);
    frame_kind = uvm_reg_field::type_id::create("frame_kind");
    frame_kind.configure(this, 2, 14, "RW", 0, `UVM_REG_DATA_WIDTH'h0>>14, 1, 1, 0);
    rsvd = uvm_reg_field::type_id::create("rsvd");
    rsvd.configure(this, 16, 16, "RW", 0, `UVM_REG_DATA_WIDTH'h0>>16, 1, 1, 0);
  endfunction

  `uvm_register_cb(ureg3_t, uvm_reg_cbs) 
  `uvm_set_super_type(ureg3_t, uvm_reg)
  `uvm_object_utils(ureg3_t)
  function new(input string name="unnamed-ureg3_t");super.new(name, 32, UVM_NO_COVERAGE);
  endfunction : new
endclass : ureg3_t


//////////////////////////////////////////////////////////////////////////////
// Register definition
//////////////////////////////////////////////////////////////////////////////
// Line Number: 226

class ureg4_t extends uvm_reg;

  typedef enum logic [1:0] {
    k0=0, k1=1, k2=2, k3=3
  } framek_enum;

  rand uvm_reg_field destination;
  rand uvm_reg_field frame_kind;
  rand uvm_reg_field rsvd;

  constraint frame_kind_enum {
    frame_kind.value inside { k0, k1, k2, k3 };
  }
  virtual function void build();
    destination = uvm_reg_field::type_id::create("destination");
    destination.configure(this, 14, 0, "RW", 0, `UVM_REG_DATA_WIDTH'h0>>0, 1, 1, 0);
    frame_kind = uvm_reg_field::type_id::create("frame_kind");
    frame_kind.configure(this, 2, 14, "RW", 0, `UVM_REG_DATA_WIDTH'h0>>14, 1, 1, 0);
    rsvd = uvm_reg_field::type_id::create("rsvd");
    rsvd.configure(this, 16, 16, "RW", 0, `UVM_REG_DATA_WIDTH'h0>>16, 1, 1, 0);
  endfunction

  `uvm_register_cb(ureg4_t, uvm_reg_cbs) 
  `uvm_set_super_type(ureg4_t, uvm_reg)
  `uvm_object_utils(ureg4_t)
  function new(input string name="unnamed-ureg4_t");super.new(name, 32, UVM_NO_COVERAGE);
  endfunction : new
endclass : ureg4_t


//////////////////////////////////////////////////////////////////////////////
// Register definition
//////////////////////////////////////////////////////////////////////////////
// Line Number: 278

class ureg5_t extends uvm_reg;

  typedef enum logic [1:0] {
    k0=0, k1=1, k2=2, k3=3
  } framek_enum;

  rand uvm_reg_field destination;
  rand uvm_reg_field frame_kind;
  rand uvm_reg_field rsvd;

  constraint frame_kind_enum {
    frame_kind.value inside { k0, k1, k2, k3 };
  }
  virtual function void build();
    destination = uvm_reg_field::type_id::create("destination");
    destination.configure(this, 14, 0, "RW", 0, `UVM_REG_DATA_WIDTH'h0>>0, 1, 1, 0);
    frame_kind = uvm_reg_field::type_id::create("frame_kind");
    frame_kind.configure(this, 2, 14, "RW", 0, `UVM_REG_DATA_WIDTH'h0>>14, 1, 1, 0);
    rsvd = uvm_reg_field::type_id::create("rsvd");
    rsvd.configure(this, 16, 16, "RW", 0, `UVM_REG_DATA_WIDTH'h0>>16, 1, 1, 0);
  endfunction

  `uvm_register_cb(ureg5_t, uvm_reg_cbs) 
  `uvm_set_super_type(ureg5_t, uvm_reg)
  `uvm_object_utils(ureg5_t)
  function new(input string name="unnamed-ureg5_t");super.new(name, 32, UVM_NO_COVERAGE);
  endfunction : new
endclass : ureg5_t


//////////////////////////////////////////////////////////////////////////////
// Register definition
//////////////////////////////////////////////////////////////////////////////
// Line Number: 330

class ureg6_t extends uvm_reg;

  typedef enum logic [1:0] {
    k0=0, k1=1, k2=2, k3=3
  } framek_enum;

  rand uvm_reg_field destination;
  rand uvm_reg_field frame_kind;
  rand uvm_reg_field rsvd;

  constraint frame_kind_enum {
    frame_kind.value inside { k0, k1, k2, k3 };
  }
  virtual function void build();
    destination = uvm_reg_field::type_id::create("destination");
    destination.configure(this, 14, 0, "RW", 0, `UVM_REG_DATA_WIDTH'h0>>0, 1, 1, 0);
    frame_kind = uvm_reg_field::type_id::create("frame_kind");
    frame_kind.configure(this, 2, 14, "RW", 0, `UVM_REG_DATA_WIDTH'h0>>14, 1, 1, 0);
    rsvd = uvm_reg_field::type_id::create("rsvd");
    rsvd.configure(this, 16, 16, "RW", 0, `UVM_REG_DATA_WIDTH'h0>>16, 1, 1, 0);
  endfunction

  `uvm_register_cb(ureg6_t, uvm_reg_cbs) 
  `uvm_set_super_type(ureg6_t, uvm_reg)
  `uvm_object_utils(ureg6_t)
  function new(input string name="unnamed-ureg6_t");super.new(name, 32, UVM_NO_COVERAGE);
  endfunction : new
endclass : ureg6_t


//////////////////////////////////////////////////////////////////////////////
// Register definition
//////////////////////////////////////////////////////////////////////////////
// Line Number: 382

class ureg7_t extends uvm_reg;

  typedef enum logic [1:0] {
    k0=0, k1=1, k2=2, k3=3
  } framek_enum;

  rand uvm_reg_field destination;
  rand uvm_reg_field frame_kind;
  rand uvm_reg_field rsvd;

  constraint frame_kind_enum {
    frame_kind.value inside { k0, k1, k2, k3 };
  }
  virtual function void build();
    destination = uvm_reg_field::type_id::create("destination");
    destination.configure(this, 14, 0, "RW", 0, `UVM_REG_DATA_WIDTH'h0>>0, 1, 1, 0);
    frame_kind = uvm_reg_field::type_id::create("frame_kind");
    frame_kind.configure(this, 2, 14, "RW", 0, `UVM_REG_DATA_WIDTH'h0>>14, 1, 1, 0);
    rsvd = uvm_reg_field::type_id::create("rsvd");
    rsvd.configure(this, 16, 16, "RW", 0, `UVM_REG_DATA_WIDTH'h0>>16, 1, 1, 0);
  endfunction

  `uvm_register_cb(ureg7_t, uvm_reg_cbs) 
  `uvm_set_super_type(ureg7_t, uvm_reg)
  `uvm_object_utils(ureg7_t)
  function new(input string name="unnamed-ureg7_t");super.new(name, 32, UVM_NO_COVERAGE);
  endfunction : new
endclass : ureg7_t


//////////////////////////////////////////////////////////////////////////////
// Register definition
//////////////////////////////////////////////////////////////////////////////
// Line Number: 434

class ureg8_t extends uvm_reg;

  typedef enum logic [1:0] {
    k0=0, k1=1, k2=2, k3=3
  } framek_enum;

  rand uvm_reg_field destination;
  rand uvm_reg_field frame_kind;
  rand uvm_reg_field rsvd;

  constraint frame_kind_enum {
    frame_kind.value inside { k0, k1, k2, k3 };
  }
  virtual function void build();
    destination = uvm_reg_field::type_id::create("destination");
    destination.configure(this, 14, 0, "RW", 0, `UVM_REG_DATA_WIDTH'h0>>0, 1, 1, 0);
    frame_kind = uvm_reg_field::type_id::create("frame_kind");
    frame_kind.configure(this, 2, 14, "RW", 0, `UVM_REG_DATA_WIDTH'h0>>14, 1, 1, 0);
    rsvd = uvm_reg_field::type_id::create("rsvd");
    rsvd.configure(this, 16, 16, "RW", 0, `UVM_REG_DATA_WIDTH'h0>>16, 1, 1, 0);
  endfunction

  `uvm_register_cb(ureg8_t, uvm_reg_cbs) 
  `uvm_set_super_type(ureg8_t, uvm_reg)
  `uvm_object_utils(ureg8_t)
  function new(input string name="unnamed-ureg8_t");super.new(name, 32, UVM_NO_COVERAGE);
  endfunction : new
endclass : ureg8_t


//////////////////////////////////////////////////////////////////////////////
// Register definition
//////////////////////////////////////////////////////////////////////////////
// Line Number: 486

class ureg9_t extends uvm_reg;

  typedef enum logic [1:0] {
    k0=0, k1=1, k2=2, k3=3
  } framek_enum;

  rand uvm_reg_field destination;
  rand uvm_reg_field frame_kind;
  rand uvm_reg_field rsvd;

  constraint frame_kind_enum {
    frame_kind.value inside { k0, k1, k2, k3 };
  }
  virtual function void build();
    destination = uvm_reg_field::type_id::create("destination");
    destination.configure(this, 14, 0, "RW", 0, `UVM_REG_DATA_WIDTH'h0>>0, 1, 1, 0);
    frame_kind = uvm_reg_field::type_id::create("frame_kind");
    frame_kind.configure(this, 2, 14, "RW", 0, `UVM_REG_DATA_WIDTH'h0>>14, 1, 1, 0);
    rsvd = uvm_reg_field::type_id::create("rsvd");
    rsvd.configure(this, 16, 16, "RW", 0, `UVM_REG_DATA_WIDTH'h0>>16, 1, 1, 0);
  endfunction

  `uvm_register_cb(ureg9_t, uvm_reg_cbs) 
  `uvm_set_super_type(ureg9_t, uvm_reg)
  `uvm_object_utils(ureg9_t)
  function new(input string name="unnamed-ureg9_t");super.new(name, 32, UVM_NO_COVERAGE);
  endfunction : new
endclass : ureg9_t


class rfile0_t extends uvm_reg_block;

  rand ureg0_t ureg0;
  rand ureg1_t ureg1;
  rand ureg2_t ureg2;
  rand ureg3_t ureg3;
  rand ureg4_t ureg4;
  rand ureg5_t ureg5;
  rand ureg6_t ureg6;
  rand ureg7_t ureg7;
  rand ureg8_t ureg8;
  rand ureg9_t ureg9;

  virtual function void build();
    
// Now create all registers

    ureg0 = ureg0_t::type_id::create("ureg0", , get_full_name());
    ureg1 = ureg1_t::type_id::create("ureg1", , get_full_name());
    ureg2 = ureg2_t::type_id::create("ureg2", , get_full_name());
    ureg3 = ureg3_t::type_id::create("ureg3", , get_full_name());
    ureg4 = ureg4_t::type_id::create("ureg4", , get_full_name());
    ureg5 = ureg5_t::type_id::create("ureg5", , get_full_name());
    ureg6 = ureg6_t::type_id::create("ureg6", , get_full_name());
    ureg7 = ureg7_t::type_id::create("ureg7", , get_full_name());
    ureg8 = ureg8_t::type_id::create("ureg8", , get_full_name());
    ureg9 = ureg9_t::type_id::create("ureg9", , get_full_name());

    // Now build the registers. Set parent and hdl_paths

    ureg0.build();
    ureg0.configure(this, null, "myreg[0]");
    ureg1.build();
    ureg1.configure(this, null, "myreg[1]");
    ureg2.build();
    ureg2.configure(this, null, "myreg[2]");
    ureg3.build();
    ureg3.configure(this, null, "myreg[3]");
    ureg4.build();
    ureg4.configure(this, null, "myreg[4]");
    ureg5.build();
    ureg5.configure(this, null, "myreg[5]");
    ureg6.build();
    ureg6.configure(this, null, "myreg[6]");
    ureg7.build();
    ureg7.configure(this, null, "myreg[7]");
    ureg8.build();
    ureg8.configure(this, null, "myreg[8]");
    ureg9.build();
    ureg9.configure(this, null, "myreg[9]");

    // Now define address mappings

    default_map = create_map("default_map", 0, 4, UVM_LITTLE_ENDIAN);
    default_map.add_reg(ureg0, `UVM_REG_ADDR_WIDTH'h0, "RW");
    default_map.add_reg(ureg1, `UVM_REG_ADDR_WIDTH'h4, "RW");
    default_map.add_reg(ureg2, `UVM_REG_ADDR_WIDTH'h8, "RW");
    default_map.add_reg(ureg3, `UVM_REG_ADDR_WIDTH'hc, "RW");
    default_map.add_reg(ureg4, `UVM_REG_ADDR_WIDTH'h10, "RW");
    default_map.add_reg(ureg5, `UVM_REG_ADDR_WIDTH'h14, "RW");
    default_map.add_reg(ureg6, `UVM_REG_ADDR_WIDTH'h18, "RW");
    default_map.add_reg(ureg7, `UVM_REG_ADDR_WIDTH'h1c, "RW");
    default_map.add_reg(ureg8, `UVM_REG_ADDR_WIDTH'h20, "RW");
    default_map.add_reg(ureg9, `UVM_REG_ADDR_WIDTH'h24, "RW");
    lock_model();
  endfunction

  `uvm_object_utils(rfile0_t)
  function new(input string name="unnamed-rfile0");
    super.new(name, UVM_NO_COVERAGE);
  endfunction : new
endclass : rfile0_t


//////////////////////////////////////////////////////////////////////////////
// Address_map definition
//////////////////////////////////////////////////////////////////////////////

class mmap0_type extends uvm_reg_block;

  rand rfile0_t rfile0;

  function void build();
    // Now define address mappings
    default_map = create_map("default_map", 0, 4, UVM_LITTLE_ENDIAN);
    rfile0 = rfile0_t::type_id::create("rfile0", , get_full_name());
    rfile0.build();
    rfile0.configure(this, "dut");
    default_map.add_submap(rfile0.default_map, `UVM_REG_ADDR_WIDTH'h0);
    set_hdl_path_root("testm");
    this.lock_model();
  endfunction

  `uvm_object_utils(mmap0_type)
  function new(input string name="unnamed-mmap0_type");
    super.new(name, UVM_NO_COVERAGE);
  endfunction
endclass : mmap0_type

 
endpackage //my_pkg


`endif // RDB_SV
