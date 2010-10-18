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

`ifndef UVM_REG_MEM__SV
`define UVM_REG_MEM__SV


`ifndef UVM_REG_MEM_ADDR_WIDTH
`define UVM_REG_MEM_ADDR_WIDTH 64
`endif

`ifndef UVM_REG_MEM_DATA_WIDTH
`define UVM_REG_MEM_DATA_WIDTH 64
`endif


typedef class uvm_reg_field;
typedef class uvm_vreg_field;
typedef class uvm_reg;
typedef class uvm_reg_file;
typedef class uvm_vreg;
typedef class uvm_reg_mem_block;
typedef class uvm_mem;
typedef class uvm_reg_item;
typedef class uvm_reg_mem_map;
typedef class uvm_reg_mem_map_info;
typedef class uvm_reg_sequence;
typedef class uvm_reg_adapter;


//------------------------------------------------------------------------------
//
// Enum: uvm_status_e
//
// Return status for register operations
//
// UVM_IS_OK      - Operation completed successfully
// UVM_NOT_OK      - Operation completed with error
// UVM_HAS_X      - Operation completed successfully bit had unknown bits.
//

   typedef enum {
      UVM_IS_OK,
      UVM_NOT_OK,
      UVM_HAS_X
   } uvm_status_e;


//------------------------------------------------------------------------------
//
// Enum: uvm_path_e
//
// Path used for register operation
//
// UVM_BFM        - Use the front door
// UVM_BACKDOOR   - Use the back door
// UVM_DEFAULT_PATH    - Operation specified by the context
//
   typedef enum {
      UVM_BFM,
      UVM_BACKDOOR,
      UVM_DEFAULT_PATH
   } uvm_path_e;


//------------------------------------------------------------------------------
//
// Enum: uvm_check_e
//
// Read-only or read-and-check
//
// UVM_NO_CHECK   - Read only
// UVM_CHECK      - Read and check
//   
   typedef enum {
      UVM_NO_CHECK,
      UVM_CHECK
   } uvm_check_e;


//------------------------------------------------------------------------------
//
// Enum: uvm_endianness_e
//
// Specifies byte ordering
//
// UVM_NO_ENDIAN      - Byte ordering not applicable
// UVM_LITTLE_ENDIAN  - Least-significant bytes first in consecutive addresses
// UVM_BIG_ENDIAN     - Most-significant bytes first in consecutive addresses
// UVM_LITTLE_FIFO    - Least-significant bytes first at the same address
// UVM_BIG_FIFO       - Most-significant bytes first at the same address
//   
   typedef enum {
      UVM_NO_ENDIAN,
      UVM_LITTLE_ENDIAN,
      UVM_BIG_ENDIAN,
      UVM_LITTLE_FIFO,
      UVM_BIG_FIFO
   } uvm_endianness_e;


//------------------------------------------------------------------------------
//
// Enum: uvm_reset_e
//
// DUT reset type
//
// UVM_HARD      - Hard reset
// UVM_SOFT      - Software reset
//
   typedef enum {
      UVM_HARD,
      UVM_SOFT
   } uvm_reset_e;


//------------------------------------------------------------------------------
//
// Enum: uvm_elem_kind_e
//
// Type of element being read or written
//
// UVM_REG      - Register
// UVM_FIELD    - Field
// UVM_MEM      - Memory location
//
   typedef enum {
      UVM_REG,
      UVM_FIELD,
      UVM_MEM
   } uvm_elem_kind_e;


//------------------------------------------------------------------------------
//
// Enum: uvm_access_e
//
// Type of operation begin performed
//
// UVM_READ     - Read operation
// UVM_WRITE    - Write operation
//
   typedef enum {
      UVM_READ,
      UVM_WRITE
   } uvm_access_e;


//------------------------------------------------------------------------------
//
// Enum: uvm_hier_e
//
// Whether to provide the requested information from a hierarchical context.
//
// UVM_NO_HIER - Provide info from the local context
// UVM_HIER    - Provide info based on the hierarchical context

   typedef enum {
      UVM_NO_HIER,
      UVM_HIER
   } uvm_hier_e;


//------------------------------------------------------------------------------
//
// Enum: uvm_predict_e
//
// How the mirror is to be updated
//
// UVM_PREDICT_DIRECT  - Predicted value is as-is
// UVM_PREDICT_READ    - Predict based on the specified value having been read
// UVM_PREDICT_WRITE   - Predict based on the specified value having been written
//
   typedef enum {
      UVM_PREDICT_DIRECT,
      UVM_PREDICT_READ,
      UVM_PREDICT_WRITE
   } uvm_predict_e;


//------------------------------------------------------------------------------
//
// Enum: uvm_coverage_model_e
//
// Coverage models available or desired.
// Multiple models may be specified by adding individual model identifiers.
//
// UVM_NO_COVERAGE   - None
// UVM_REG_BITS      - Individual register bits
// UVM_ADDR_MAP      - Individual register and memory addresses
// UVM_FIELD_VALS    - Field values
// UVM_ALL_COVERAGE  - All of the above
//
   typedef enum {
      UVM_NO_COVERAGE  = 'h0000,
      UVM_REG_BITS     = 'h0001,
      UVM_ADDR_MAP     = 'h0002,
      UVM_FIELD_VALS   = 'h0004,
      UVM_ALL_COVERAGE = 'h0007
   } uvm_coverage_model_e;



//------------------------------------------------------------------------------
//
// Macro: `UVM_REG_MEM_ADDR_WIDTH
//
// Maximum address width in bits
//
// Default value is 64.
//
`ifndef UVM_REG_MEM_ADDR_WIDTH
  `ifdef UVM_REG_MEM_ADDR_WIDTH
    `define UVM_REG_MEM_ADDR_WIDTH `UVM_REG_MEM_ADDR_WIDTH
  `else
    `define UVM_REG_MEM_ADDR_WIDTH 64
  `endif
`endif


//------------------------------------------------------------------------------
//
// Macro: `UVM_REG_MEM_DATA_WIDTH
//
// Maximum data width in bits
//
// Default value is 64.
//
`ifndef UVM_REG_MEM_DATA_WIDTH
  `ifdef UVM_REG_MEM_DATA_WIDTH
    `define UVM_REG_MEM_DATA_WIDTH `UVM_REG_MEM_DATA_WIDTH
  `else
    `define UVM_REG_MEM_DATA_WIDTH 64
  `endif
`endif

//------------------------------------------------------------------------------
//
// Macro: `UVM_REG_MEM_BYTENABLE_WIDTH
//
// Maximum number of byte enable bits
//
// Default value is one per byte in `UVM_REG_MEM_DATA_WIDTH
//
`ifndef UVM_REG_MEM_BYTENABLE_WIDTH 
  `define UVM_REG_MEM_BYTENABLE_WIDTH ((`UVM_REG_MEM_DATA_WIDTH-1)/8+1) 
`endif


//------------------------------------------------------------------------------
//
// Type: uvm_reg_mem_addr_t
//
// Address value
//
// Type: uvm_reg_mem_addr_logic_t
//
// 4-state address value
//
typedef  bit [`UVM_REG_MEM_ADDR_WIDTH-1:0]  uvm_reg_mem_addr_t ;
typedef  logic [`UVM_REG_MEM_ADDR_WIDTH-1:0]  uvm_reg_mem_addr_logic_t ;

//------------------------------------------------------------------------------
//
// Type: uvm_reg_mem_data_t
//
// Data value
//
// Type: uvm_reg_mem_data_logic_t
//
// 4-state data value
//
typedef  bit [`UVM_REG_MEM_DATA_WIDTH-1:0]  uvm_reg_mem_data_t ;
typedef  logic [`UVM_REG_MEM_DATA_WIDTH-1:0]  uvm_reg_mem_data_logic_t ;

//------------------------------------------------------------------------------
//
// Type: uvm_reg_mem_byte_en_t
//
// Byte enable vector
//
typedef  bit [`UVM_REG_MEM_BYTENABLE_WIDTH-1:0]  uvm_reg_mem_byte_en_t ;


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


`include "reg_mem/uvm_hdl.svh"

`include "reg_mem/uvm_reg_adapter.svh"
`include "reg_mem/uvm_reg_sequence.svh"
`include "reg_mem/uvm_reg_field.svh"
`include "reg_mem/uvm_vreg_field.svh"
`include "reg_mem/uvm_reg_mem_backdoor.svh"
`include "reg_mem/uvm_reg.svh"
`include "reg_mem/uvm_reg_file.svh"
`include "reg_mem/uvm_mem_mam.svh"
`include "reg_mem/uvm_mem.svh"
`include "reg_mem/uvm_vreg.svh"
`include "reg_mem/uvm_reg_mem_map.svh"
`include "reg_mem/uvm_reg_mem_block.svh"

`include "reg_mem/uvm_reg_test_hw_reset.svh"
`include "reg_mem/uvm_reg_test_bit_bash.svh"
`include "reg_mem/uvm_mem_test_walk.svh"
`include "reg_mem/uvm_mem_test_access.svh"
`include "reg_mem/uvm_reg_test_access.svh"
`include "reg_mem/uvm_reg_mem_test_shared_access.svh"
`include "reg_mem/uvm_reg_mem_test_all.svh"

`endif // UVM_REG_MEM__SV
