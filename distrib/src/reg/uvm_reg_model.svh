//
// -------------------------------------------------------------
//    Copyright 2004-2009 Synopsys, Inc.
//    Copyright 2010 Mentor Graphics Corp.
//    Copyright 2010 Cadence Design Systems, Inc.
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

//
// TITLE: Global Declarations for the Register Layer
//
// Globally available types and enumerals.
//
// In addition to the declarations outlined in the summary below,
// the following classes are defined herein
//
// <uvm_hdl_path_concat>  : Concatenation of HDL paths
//
// <uvm_utils>            : Various type-specific utility functions
//

`ifndef UVM_REG_MODEL__SV
`define UVM_REG_MODEL__SV


`ifndef UVM_REG_ADDR_WIDTH
`define UVM_REG_ADDR_WIDTH 64
`endif

`ifndef UVM_REG_DATA_WIDTH
`define UVM_REG_DATA_WIDTH 64
`endif


typedef class uvm_reg_field;
typedef class uvm_vreg_field;
typedef class uvm_reg;
typedef class uvm_reg_file;
typedef class uvm_vreg;
typedef class uvm_reg_block;
typedef class uvm_mem;
typedef class uvm_reg_item;
typedef class uvm_reg_map;
typedef class uvm_reg_map_info;
typedef class uvm_reg_sequence;
typedef class uvm_reg_adapter;


//------------------------------------------------------------------------------
//
// Enum: uvm_status_e
//
// Return status for register operations
//
// UVM_IS_OK      - Operation completed successfully
// UVM_NOT_OK     - Operation completed with error
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
// UVM_BFM          - Use the front door
// UVM_BACKDOOR     - Use the back door
// UVM_PREDICT      - Operation derived from observations by a bus monitor via
//                    the <uvm_reg_redictor> class.
// UVM_DEFAULT_PATH - Operation specified by the context
//
   typedef enum {
      UVM_BFM,
      UVM_BACKDOOR,
      UVM_PREDICT,
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
      UVM_WRITE,
      UVM_BURST_READ,
      UVM_BURST_WRITE
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
// UVM_NO_COVERAGE      - None
// UVM_CVR_REG_BITS     - Individual register bits
// UVM_CVR_ADDR_MAP     - Individual register and memory addresses
// UVM_CVR_FIELD_VALS   - Field values
// UVM_CVR_ALL          - All of the above
//
   typedef enum {
      UVM_NO_COVERAGE      = 'h0000,
      UVM_CVR_REG_BITS     = 'h0001,
      UVM_CVR_ADDR_MAP     = 'h0002,
      UVM_CVR_FIELD_VALS   = 'h0004,
      UVM_CVR_ALL          = 'h0007
   } uvm_coverage_model_e;



//------------------------------------------------------------------------------
//
// Macro: `UVM_REG_ADDR_WIDTH
//
// Maximum address width in bits
//
// Default value is 64.
//
`ifndef UVM_REG_ADDR_WIDTH
  `ifdef UVM_REG_ADDR_WIDTH
    `define UVM_REG_ADDR_WIDTH `UVM_REG_ADDR_WIDTH
  `else
    `define UVM_REG_ADDR_WIDTH 64
  `endif
`endif


//------------------------------------------------------------------------------
//
// Macro: `UVM_REG_DATA_WIDTH
//
// Maximum data width in bits
//
// Default value is 64.
//
`ifndef UVM_REG_DATA_WIDTH
  `ifdef UVM_REG_DATA_WIDTH
    `define UVM_REG_DATA_WIDTH `UVM_REG_DATA_WIDTH
  `else
    `define UVM_REG_DATA_WIDTH 64
  `endif
`endif

//------------------------------------------------------------------------------
//
// Macro: `UVM_REG_BYTENABLE_WIDTH
//
// Maximum number of byte enable bits
//
// Default value is one per byte in <`UVM_REG_DATA_WIDTH>
//
`ifndef UVM_REG_BYTENABLE_WIDTH 
  `define UVM_REG_BYTENABLE_WIDTH ((`UVM_REG_DATA_WIDTH-1)/8+1) 
`endif


//------------------------------------------------------------------------------
// Type: uvm_reg_data_t
//
// 2-state data value with <`UVM_REG_DATA_WIDTH> bits
//
typedef  bit [`UVM_REG_DATA_WIDTH-1:0]  uvm_reg_data_t ;

// Type: uvm_reg_data_logic_t
//
// 4-state data value with <`UVM_REG_DATA_WIDTH> bits
//
typedef  logic [`UVM_REG_DATA_WIDTH-1:0]  uvm_reg_data_logic_t ;

//------------------------------------------------------------------------------
// Type: uvm_reg_addr_t
//
// 2-state address value with <`UVM_REG_ADDR_WIDTH> bits
//
typedef  bit [`UVM_REG_ADDR_WIDTH-1:0]  uvm_reg_addr_t ;

// Type: uvm_reg_addr_logic_t
//
// 4-state address value with <`UVM_REG_ADDR_WIDTH> bits
//
typedef  logic [`UVM_REG_ADDR_WIDTH-1:0]  uvm_reg_addr_logic_t ;

//------------------------------------------------------------------------------
//
// Type: uvm_reg_byte_en_t
//
// 2-state byte_enable value with <`UVM_REG_BYTENABLE_WIDTH> bits
//
typedef  bit [`UVM_REG_BYTENABLE_WIDTH-1:0]  uvm_reg_byte_en_t ;


//------------------------------------------------------------------------------
// Type: uvm_hdl_path_slice
//
// Slice of an HDL path
//
// Struct that specifies the HDL variable that corresponds to all
// or a portion of a register.
//
// path    - Path to the HDL variable.
// offset  - Offset of the LSB in the register that this variable implements
// size    - Number of bits (toward the MSB) that this variable implements
//
// If the HDL variable implements all of the register, ~offset~ and ~size~
// are specified as -1. For example:
//|
//| r1.add_hdl_path('{ '{"r1", -1, -1} });
//|
//
//------------------------------------------------------------------------------

typedef struct {
   string path;
   int offset;
   int size;
} uvm_hdl_path_slice;



//------------------------------------------------------------------------------
// Class: uvm_hdl_path_concat
//
// Concatenation of HDL variables
//
// An dArray of <uvm_hdl_path_slice> specifing a concatenation
// of HDL variables that implement a register in the HDL.
//
// Slices must be specified in most-to-least significant order.
// Slices must not overlap. Gaps may exists in the concatentation
// if portions of the registers are not implemented.
//
// For example, the following register
//|
//|        1 1 1 1 1 1 0 0 0 0 0 0 0 0 0 0
//| Bits:  5 4 3 2 1 0 9 8 7 6 5 4 3 2 1 0
//|       +-+---+-------------+---+-------+
//|       |A|xxx|      B      |xxx|   C   |
//|       +-+---+-------------+---+-------+
//|
//
// If the register is implementd using a single HDL variable,
// The array should specify a single slice with its ~offset~ and ~size~
// specified as -1. For example:
//
//| concat.set('{ '{"r1", -1, -1} });
//
//------------------------------------------------------------------------------

class uvm_hdl_path_concat;

   // Variable: slices
   // Array of individual slices,
   // stored in most-to-least significant order
   uvm_hdl_path_slice slices[];

   // Function: set
   // Initialize the concatenation using an array literal
   function void set(uvm_hdl_path_slice t[]);
      slices = t;
   endfunction

   // Function: add_slice
   // Append the specified ~slice~ literal to the path concatenation
   function void add_slice(uvm_hdl_path_slice slice);
      slices = new [slices.size()+1] (slices);
      slices[slices.size()-1] = slice;
   endfunction

   // Function: add_path
   // Append the specified ~path~ to the path concatenation,
   // for the specified number of bits at the specified ~offset~.
   function void add_path(string path,
                          int unsigned offset = -1,
                          int unsigned size = -1);
      uvm_hdl_path_slice t;
      t.offset = offset;
      t.path   = path;
      t.size   = size;
      
      add_slice(t);
   endfunction
   
endclass


//------------------------------------------------------------------------------
// CLASS: uvm_utils
//
// This class contains useful template functions.
//
//------------------------------------------------------------------------------


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
  // This method gets the object config of type ~TYPE~
  // associated with component ~comp~.
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




// concat2string

function automatic string uvm_hdl_concat2string(uvm_hdl_path_concat concat);
   string image = "{";
   
   if (concat.slices.size() == 1 &&
       concat.slices[0].offset == -1 &&
       concat.slices[0].size == -1)
      return concat.slices[0].path;

   foreach (concat.slices[i]) begin
      uvm_hdl_path_slice slice=concat.slices[i];

      image = { image, (i == 0) ? "" : ", ", slice.path };
      if (slice.offset >= 0)
         image = { image, "@", $psprintf("[%0d +: %0d]", slice.offset, slice.size) };
   end

   image = { image, "}" };

   return image;
endfunction


typedef struct packed {
  uvm_reg_addr_t min;
  uvm_reg_addr_t max;
  int unsigned stride;
  } uvm_reg_map_addr_range;



`include "dpi/uvm_hdl.svh"

`include "reg/uvm_reg_item.svh"
`include "reg/uvm_reg_adapter.svh"
`include "reg/uvm_reg_sequence.svh"
`include "reg/uvm_reg_cbs.svh"
`include "reg/uvm_reg_backdoor.svh"
`include "reg/uvm_reg_field.svh"
`include "reg/uvm_vreg_field.svh"
`include "reg/uvm_reg.svh"
`include "reg/uvm_reg_indirect.svh"
`include "reg/uvm_reg_file.svh"
`include "reg/uvm_mem_mam.svh"
`include "reg/uvm_vreg.svh"
`include "reg/uvm_mem.svh"
`include "reg/uvm_reg_map.svh"
`include "reg/uvm_reg_block.svh"

`include "reg/sequences/uvm_reg_hw_reset_seq.svh"
`include "reg/sequences/uvm_reg_bit_bash_seq.svh"
`include "reg/sequences/uvm_mem_walk_seq.svh"
`include "reg/sequences/uvm_mem_access_seq.svh"
`include "reg/sequences/uvm_reg_access_seq.svh"
`include "reg/sequences/uvm_reg_mem_shared_access_seq.svh"
`include "reg/sequences/uvm_reg_mem_built_in_seq.svh"
// TODO `include "reg/sequences/uvm_reg_access_backdoor_check.svh"

`endif // UVM_REG_MODEL__SV
