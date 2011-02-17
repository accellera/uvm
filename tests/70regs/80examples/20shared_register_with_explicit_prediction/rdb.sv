//
//------------------------------------------------------------------------------
//   Copyright 2011 (Authors)
//   Copyright 2011 Cadence Design Systems, Inc.
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
// Number of registers = 2
// Number of memories = 0

package my_pkg;

  import uvm_pkg::*;
  `include "uvm_macros.svh"


//////////////////////////////////////////////////////////////////////////////
// Register definition
//////////////////////////////////////////////////////////////////////////////
// Line Number: 19

class swr_reg_type extends uvm_reg;

  rand uvm_reg_field wdata_lsb;
  rand uvm_reg_field wdata_msb;

  virtual function void build();
    wdata_lsb = uvm_reg_field::type_id::create("wdata_lsb");
    wdata_lsb.configure(this, 16, 0, "WO", 0, 0, 0, 1, 1);
    wdata_msb = uvm_reg_field::type_id::create("wdata_msb");
    wdata_msb.configure(this, 16, 16, "WO", 0, 0, 0, 1, 1);
  endfunction

  covergroup value_cg;
    option.per_instance=1;
    coverpoint wdata_lsb.value[15:0];
    coverpoint wdata_msb.value[15:0];
  endgroup
  
  virtual function void sample_values();
    super.sample_values();
    value_cg.sample();
  endfunction

  `uvm_register_cb(swr_reg_type, uvm_reg_cbs) 
  `uvm_set_super_type(swr_reg_type, uvm_reg)
  `uvm_object_utils(swr_reg_type)
  function new(input string name="unnamed-swr_reg_type");
    super.new(name, 32, build_coverage(UVM_CVR_FIELD_VALS));
    value_cg=new;
  endfunction : new
endclass : swr_reg_type


//////////////////////////////////////////////////////////////////////////////
// Register definition
//////////////////////////////////////////////////////////////////////////////
// Line Number: 39

class srd_reg_type extends uvm_reg;

  uvm_reg_field rdata_lsb;
  uvm_reg_field rdata_msb;

  virtual function void build();
    rdata_lsb = uvm_reg_field::type_id::create("rdata_lsb");
    rdata_lsb.configure(this, 16, 0, "RO", 0, `UVM_REG_DATA_WIDTH'ha5a5a5a5>>0, 1, 0, 1);
    rdata_msb = uvm_reg_field::type_id::create("rdata_msb");
    rdata_msb.configure(this, 16, 16, "RO", 0, `UVM_REG_DATA_WIDTH'ha5a5a5a5>>16, 1, 0, 1);
  endfunction

  covergroup value_cg;
    option.per_instance=1;
    coverpoint rdata_lsb.value[15:0];
    coverpoint rdata_msb.value[15:0];
  endgroup
  
  virtual function void sample_values();
    super.sample_values();
    value_cg.sample();
  endfunction

  `uvm_register_cb(srd_reg_type, uvm_reg_cbs) 
  `uvm_set_super_type(srd_reg_type, uvm_reg)
  `uvm_object_utils(srd_reg_type)
  function new(input string name="unnamed-srd_reg_type");
    super.new(name, 32, build_coverage(UVM_CVR_FIELD_VALS));
    value_cg=new;
  endfunction : new
endclass : srd_reg_type


class my_rf_type extends uvm_reg_block;

  rand swr_reg_type swr_reg;
  rand srd_reg_type srd_reg;

  virtual function void build();

    // Now create all registers

    swr_reg = swr_reg_type::type_id::create("swr_reg", , get_full_name());
    srd_reg = srd_reg_type::type_id::create("srd_reg", , get_full_name());

    // Now build the registers. Set parent and hdl_paths

    swr_reg.configure(this, null, "swr");
    swr_reg.build();
    srd_reg.configure(this, null, "srd");
    srd_reg.build();

    // Now define address mappings

    default_map = create_map("default_map", 0, 4, UVM_LITTLE_ENDIAN);
    default_map.add_reg(swr_reg, `UVM_REG_ADDR_WIDTH'h4, "WO");
    default_map.add_reg(srd_reg, `UVM_REG_ADDR_WIDTH'h4, "RO");
  endfunction

  `uvm_object_utils(my_rf_type)
  function new(input string name="unnamed-my_rf");
    super.new(name, UVM_NO_COVERAGE);
  endfunction : new
endclass : my_rf_type


//////////////////////////////////////////////////////////////////////////////
// Address_map definition
//////////////////////////////////////////////////////////////////////////////

class my_map_type extends uvm_reg_block;

  rand my_rf_type my_rf;

  function void build();
    // Now define address mappings
    default_map = create_map("default_map", 0, 4, UVM_LITTLE_ENDIAN);
    my_rf = my_rf_type::type_id::create("my_rf", , get_full_name());
    my_rf.build();
    my_rf.configure(this, "dut");
    my_rf.lock_model();
    default_map.add_submap(my_rf.default_map, `UVM_REG_ADDR_WIDTH'h1000);
    set_hdl_path_root("testm");
    this.lock_model();
  endfunction

  `uvm_object_utils(my_map_type)
  function new(input string name="unnamed-my_map_type");
    super.new(name, UVM_NO_COVERAGE);
  endfunction
endclass : my_map_type

 
endpackage //my_pkg


`endif // RDB_SV
