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


class uvm_ral extends uvm_component;
   typedef enum {
      IS_OK,
      ERROR,
      HAS_X
   } status_e;

   typedef enum {
      BFM,
      BACKDOOR,
      DEFAULT
   } path_e;

   typedef enum {
      NO_CHECK,
      CHECK
   } check_e;

   typedef enum {
      NO_ENDIAN,
      LITTLE_ENDIAN,
      BIG_ENDIAN,
      LITTLE_FIFO,
      BIG_FIFO
   } endianness_e;

   typedef enum {
      HARD,
      SOFT
   } reset_e;

   typedef enum {
      REG,
      FIELD,
      MEM
   } elem_kind_e;

   typedef enum {
      READ,
      WRITE
   } access_e;

   typedef enum {
      PREDICT_DIRECT,
      PREDICT_READ,
      PREDICT_WRITE
   } predict_e;

   typedef enum {
      NO_COVERAGE  = 'h0000,
      REG_BITS     = 'h0001,
      ADDR_MAP     = 'h0002,
      FIELD_VALS   = 'h0004,
      ALL_COVERAGE = 'h0007
   } coverage_model_e;

   // Singleton root component for the RAL root sequencers
   local function new(string name, uvm_component parent);
      super.new(name, parent);
   endfunction
   static local uvm_ral m_root = null;
   static function uvm_component get_root();
      if (m_root == null) m_root = new("rals", uvm_top);
      return m_root;
   endfunction

   local static bit banner = display_banner();
   local static function bit display_banner();
      $display("----------------------------------------------------------------");
      $display("UVM RAL");
      $display("(C) 2006-2010 Synopsys, Inc.");
      $display("(C) 2010 Mentor Graphics, Inc.");
      return 1;
   endfunction

endclass: uvm_ral


`ifndef UVM_RAL_ADDR_WIDTH
  `ifdef UVM_RAL_ADDR_WIDTH
    `define UVM_RAL_ADDR_WIDTH `UVM_RAL_ADDR_WIDTH
  `else
    `define UVM_RAL_ADDR_WIDTH 64
  `endif
`endif
`ifndef UVM_RAL_DATA_WIDTH
  `ifdef UVM_RAL_DATA_WIDTH
    `define UVM_RAL_DATA_WIDTH `UVM_RAL_DATA_WIDTH
  `else
    `define UVM_RAL_DATA_WIDTH 64
  `endif
`endif

`ifndef UVM_RAL_BYTENABLE_WIDTH 
  `define UVM_RAL_BYTENABLE_WIDTH ((`UVM_RAL_DATA_WIDTH-1)/8+1) 
`endif

typedef  bit [`UVM_RAL_ADDR_WIDTH-1:0]  uvm_ral_addr_t ;
typedef  bit [`UVM_RAL_DATA_WIDTH-1:0]  uvm_ral_data_t ;
typedef  logic [`UVM_RAL_ADDR_WIDTH-1:0]  uvm_ral_addr_logic_t ;
typedef  logic [`UVM_RAL_DATA_WIDTH-1:0]  uvm_ral_data_logic_t ;

typedef  bit [`UVM_RAL_BYTENABLE_WIDTH-1:0]  uvm_ral_byte_en_t ;


//------------------------------------------------------------------------------
// TYPE: uvm_ral_hdl_path_slice
//
// Slice of a HDL variable

typedef struct {
   string path;
   int offset;
   int size;
} uvm_ral_hdl_path_slice;


//------------------------------------------------------------------------------
// TYPE: uvm_ral_hdl_path_slice
//
// Slice of a HDL variable

typedef uvm_ral_hdl_path_slice uvm_ral_hdl_path_concat[];


// concat2string

function string uvm_ral_concat2string(uvm_ral_hdl_path_concat slices);
   string image = "{";
   
   if (slices.size() == 1) return slices[0].path;

   foreach (slices[i]) begin
      uvm_ral_hdl_path_slice slice;
      slice = slices[i];

      image = { image, (i == 0) ? "" : ", ", slice.path };
      if (slice.offset >= 0)
         image = { image, "@", $psprintf("[%0d +: %0d]", slice.offset, slice.size) };
   end

   image = { image, "}" };

   return image;
endfunction


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

`include "ral/uvm_backdoor_dpi.svh"


`endif // UVM_RAL__SV
