//
// -------------------------------------------------------------
//    Copyright 2004-2009 Synopsys, Inc.
//    Copyright 2010 Mentor Graphics Corp.
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
//    permissions and limitations under the License.
// -------------------------------------------------------------
//

`ifndef UVM_RAL__SV
`define UVM_RAL__SV


`ifndef UVM_RAL_ADDR_WIDTH
`define UVM_RAL_ADDR_WIDTH 64
`endif

`ifndef UVM_RAL_DATA_WIDTH
`define UVM_RAL_DATA_WIDTH 64
`endif


typedef class uvm_ral_field;
typedef class uvm_ral_vfield;
typedef class uvm_ral_reg;
typedef class uvm_ral_regfile;
typedef class uvm_ral_vreg;
typedef class uvm_ral_block;
typedef class uvm_ral_mem;
typedef class uvm_ral_item;
typedef class uvm_ral_map;
typedef class uvm_ral_map_info;
typedef class uvm_ral_sequence;
typedef class uvm_ral_adapter;


class uvm_ral;

//------------------------------------------------------------------------------
//
// Enum: uvm_ral::status_e
//
// Return status for register operations
//
// IS_OK      - Operation completed successfully
// ERROR      - Operation completed with error
// HAS_X      - Operation completed successfully bit had unknown bits.
//
   typedef enum {
      IS_OK,
      ERROR,
      HAS_X
   } status_e;


//------------------------------------------------------------------------------
//
// Enum: uvm_ral::path_e
//
// Path used for register operation
//
// BFM        - Use the front door
// BACKDOOR   - Use the back door
// DEFAULT    - Operation specified by the context
//
   typedef enum {
      BFM,
      BACKDOOR,
      DEFAULT
   } path_e;


//------------------------------------------------------------------------------
//
// Enum: uvm_ral::check_e
//
// Read-only or read-and-check
//
// NO_CHECK   - Read only
// CHECK      - Read and check
//   
   typedef enum {
      NO_CHECK,
      CHECK
   } check_e;


//------------------------------------------------------------------------------
//
// Enum: uvm_ral::endianness_e
//
// Specifies byte ordering
//
// NO_ENDIAN      - Byte ordering not applicable
// LITTLE_ENDIAN  - Least-significant bytes first in consecutive addresses
// BIG_ENDIAN     - Most-significant bytes first in consecutive addresses
// LITTLE_FIFO    - Least-significant bytes first at the same address
// BIG_FIFO       - Most-significant bytes first at the same address
//   
   typedef enum {
      NO_ENDIAN,
      LITTLE_ENDIAN,
      BIG_ENDIAN,
      LITTLE_FIFO,
      BIG_FIFO
   } endianness_e;


//------------------------------------------------------------------------------
//
// Enum: uvm_ral::reset_e
//
// DUT reset type
//
// HARD      - Hard reset
// SOFT      - Software reset
//
   typedef enum {
      HARD,
      SOFT
   } reset_e;


//------------------------------------------------------------------------------
//
// Enum: uvm_ral::elem_kind_e
//
// Type of element being read or written
//
// REG      - Register
// FIELD    - Field
// MEM      - Memory location
//
   typedef enum {
      REG,
      FIELD,
      MEM
   } elem_kind_e;


//------------------------------------------------------------------------------
//
// Enum: uvm_ral::access_e
//
// Type of operation begin performed
//
// READ     - Read operation
// WRITE    - Write operation
//
   typedef enum {
      READ,
      WRITE
   } access_e;


//------------------------------------------------------------------------------
//
// Enum: uvm_ral::predict_e
//
// How the mirror is to be updated
//
// PREDICT_DIRECT  - Predicted value is as-is
// PREDICT_READ    - Predict based on the specified value having been read
// PREDICT_WRITE   - Predict based on the specified value having been written
//
   typedef enum {
      PREDICT_DIRECT,
      PREDICT_READ,
      PREDICT_WRITE
   } predict_e;


//------------------------------------------------------------------------------
//
// Enum: uvm_ral::coverage_model_e
//
// Coverage models available or desired.
// Multiple models may be specified by adding individual model identifiers.
//
// NO_COVERAGE   - None
// REG_BITS      - Individual register bits
// ADDR_MAP      - Individual register and memory addresses
// FIELD_VALS    - Field values
// ALL_COVERAGE  - All of the above
//
   typedef enum {
      NO_COVERAGE  = 'h0000,
      REG_BITS     = 'h0001,
      ADDR_MAP     = 'h0002,
      FIELD_VALS   = 'h0004,
      ALL_COVERAGE = 'h0007
   } coverage_model_e;

endclass: uvm_ral


//------------------------------------------------------------------------------
//
// Macro: `UVM_RAL_ADDR_WIDTH
//
// Maximum address width in bits
//
// Default value is 64.
//
`ifndef UVM_RAL_ADDR_WIDTH
  `ifdef UVM_RAL_ADDR_WIDTH
    `define UVM_RAL_ADDR_WIDTH `UVM_RAL_ADDR_WIDTH
  `else
    `define UVM_RAL_ADDR_WIDTH 64
  `endif
`endif


//------------------------------------------------------------------------------
//
// Macro: `UVM_RAL_DATA_WIDTH
//
// Maximum data width in bits
//
// Default value is 64.
//
`ifndef UVM_RAL_DATA_WIDTH
  `ifdef UVM_RAL_DATA_WIDTH
    `define UVM_RAL_DATA_WIDTH `UVM_RAL_DATA_WIDTH
  `else
    `define UVM_RAL_DATA_WIDTH 64
  `endif
`endif

//------------------------------------------------------------------------------
//
// Macro: `UVM_RAL_BYTENABLE_WIDTH
//
// Maximum number of byte enable bits
//
// Default value is one per byte in `UVM_RAL_DATA_WIDTH
//
`ifndef UVM_RAL_BYTENABLE_WIDTH 
  `define UVM_RAL_BYTENABLE_WIDTH ((`UVM_RAL_DATA_WIDTH-1)/8+1) 
`endif


//------------------------------------------------------------------------------
//
// Type: uvm_ral_addr_t
//
// Address value
//
// Type: uvm_ral_addr_logic_t
//
// 4-state address value
//
typedef  bit [`UVM_RAL_ADDR_WIDTH-1:0]  uvm_ral_addr_t ;
typedef  logic [`UVM_RAL_ADDR_WIDTH-1:0]  uvm_ral_addr_logic_t ;


//------------------------------------------------------------------------------
//
// Type: uvm_ral_data_t
//
// Data value
//
// Type: uvm_ral_data_logic_t
//
// 4-state data value
//
typedef  bit [`UVM_RAL_DATA_WIDTH-1:0]  uvm_ral_data_t ;
typedef  logic [`UVM_RAL_DATA_WIDTH-1:0]  uvm_ral_data_logic_t ;

//------------------------------------------------------------------------------
//
// Type: uvm_ral_byte_en_t
//
// Byte enable vector
//
typedef  bit [`UVM_RAL_BYTENABLE_WIDTH-1:0]  uvm_ral_byte_en_t ;


//------------------------------------------------------------------------------
// CLASS: uvm_utils #(TYPE)
//
// This class contains useful template functions.


class uvm_utils #(type TYPE=int, string FIELD="config");

  typedef TYPE types_t[$];

  // Function: find_all
  //
  // Recursively finds all component instances of the parameter type ~TYPE~,
  // starting with the component given by ~start~. Uses <uvm_root::find_all>.

  static function types_t find_all(uvm_component start);
    uvm_component list[$];
    types_t types;
    uvm_top.find_all("*",list,start);
    foreach (list[i]) begin
      TYPE typ;
      if ($cast(typ,list[i]))
        types.push_back(typ);
    end
    if (types.size() == 0) begin
      `uvm_warning("find_type-no match",{"Instance of type '",TYPE::type_name,
         " not found in component hierarchy beginning at ",start.get_full_name()})
    end
    return types;
  endfunction

  static function TYPE find(uvm_component start);
    types_t types = find_all(start);
    if (types.size() == 0)
      return null;
    if (types.size() > 1) begin
      `uvm_warning("find_type-multi match",{"More than one instance of type '",TYPE::type_name,
         " found in component hierarchy beginning at ",start.get_full_name()})
      return null;
    end
    return types[0];
  endfunction

  static function TYPE create_type_by_name(string type_name, string contxt);
    uvm_object obj;
    TYPE  typ;
    obj = factory.create_object_by_name(type_name,contxt,type_name);
       if (!$cast(typ,obj))
         uvm_report_error("WRONG_TYPE",{"The type_name given '",type_name,
                "' with context '",contxt,"' did not produce the expected type."});
    return typ;
  endfunction


  // Function: get_config
  //
  // This method gets the any_config associated with component c.
  // We check for the two kinds of error which may occur with this kind of 
  // operation.

  static function TYPE get_config(uvm_component comp, bit is_fatal);
    uvm_object obj;
    TYPE cfg;

    if (!comp.get_config_object(FIELD, obj, 0)) begin
      if (is_fatal)
        comp.uvm_report_fatal("NO_SET_CFG", {"no set_config to field '", FIELD,
                           "' for component '",comp.get_full_name(),"'"},
                           UVM_MEDIUM, `uvm_file , `uvm_line  );
      else
        comp.uvm_report_warning("NO_SET_CFG", {"no set_config to field '", FIELD,
                           "' for component '",comp.get_full_name(),"'"},
                           UVM_MEDIUM, `uvm_file , `uvm_line  );
      return null;
    end

    if (!$cast(cfg, obj)) begin
      if (is_fatal)
        comp.uvm_report_fatal( "GET_CFG_TYPE_FAIL",
                          {"set_config_object with field name ",FIELD,
                          " is not of type '",TYPE::type_name,"'"},
                          UVM_NONE , `uvm_file , `uvm_line );
      else
        comp.uvm_report_warning( "GET_CFG_TYPE_FAIL",
                          {"set_config_object with field name ",FIELD,
                          " is not of type '",TYPE::type_name,"'"},
                          UVM_NONE , `uvm_file , `uvm_line );
    end

    return cfg;
  endfunction

endclass


`include "ral/uvm_hdl.svh"

`include "ral/uvm_ral_adapter.svh"
`include "ral/uvm_ral_sequence.svh"
`include "ral/uvm_ral_field.svh"
`include "ral/uvm_ral_vfield.svh"
`include "ral/uvm_ral_backdoor.svh"
`include "ral/uvm_ral_reg.svh"
`include "ral/uvm_ral_regfile.svh"
`include "ral/uvm_mam.svh"
`include "ral/uvm_ral_mem.svh"
`include "ral/uvm_ral_vreg.svh"
`include "ral/uvm_ral_map.svh"
`include "ral/uvm_ral_block.svh"

`include "ral/uvm_ral_test_hw_reset.svh"
`include "ral/uvm_ral_test_bit_bash.svh"
`include "ral/uvm_ral_test_mem_walk.svh"
`include "ral/uvm_ral_test_mem_access.svh"
`include "ral/uvm_ral_test_reg_access.svh"
`include "ral/uvm_ral_test_shared_access.svh"
`include "ral/uvm_ral_test_all.svh"

`endif // UVM_RAL__SV
