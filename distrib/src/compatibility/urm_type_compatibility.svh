// $Id: urm_type_compatibility.svh,v 1.13 2009/05/01 14:34:38 redelman Exp $
//----------------------------------------------------------------------
//   Copyright 2007-2009 Mentor Graphics Corporation
//   Copyright 2007-2009 Cadence Design Systems, Inc.
//   Copyright 2010 Synopsys, Inc.
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
//----------------------------------------------------------------------
`ifndef URM_TYPE_COMPATIBILITY_SVH
`define URM_TYPE_COMPATIBILITY_SVH

typedef uvm_object             urm_object;
typedef uvm_transaction        urm_transaction;
typedef uvm_event              urm_event;
typedef uvm_event_pool         urm_event_pool;
typedef uvm_component          urm_named_object;
typedef uvm_component          urm_unit_base;
typedef uvm_component          urm_unit;
typedef uvm_printer            urm_printer;
typedef uvm_comparer           urm_comparer;
typedef uvm_recorder           urm_recorder;
typedef uvm_factory            urm_factory;
typedef uvm_object_wrapper     urm_object_wrapper;

`ifdef URM_GLOBALS

parameter NONE = int'(UVM_NONE);
parameter LOW = int'(UVM_LOW);
parameter MEDIUM = int'(UVM_MEDIUM);
parameter HIGH = int'(UVM_HIGH);
parameter FULL = int'(UVM_FULL);
parameter STREAMBITS = int'(UVM_STREAMBITS);
parameter RADIX = int'(UVM_RADIX);
parameter BIN = int'(UVM_BIN);
parameter DEC = int'(UVM_DEC);
parameter UNSIGNED = int'(UVM_UNSIGNED);
parameter OCT = int'(UVM_OCT);
parameter HEX = int'(UVM_HEX);
parameter STRING = int'(UVM_STRING);
parameter TIME = int'(UVM_TIME);
parameter ENUM = int'(UVM_ENUM);
parameter NORADIX = int'(UVM_NORADIX);
parameter DEFAULT_POLICY = int'(UVM_DEFAULT_POLICY);
parameter DEEP = int'(UVM_DEEP);
parameter SHALLOW = int'(UVM_SHALLOW);
parameter REFERENCE = int'(UVM_REFERENCE);
parameter DEFAULT = int'(UVM_DEFAULT);
parameter ALL_ON = int'(UVM_ALL_ON);
parameter COPY = int'(UVM_COPY);
parameter NOCOPY = int'(UVM_NOCOPY);
parameter COMPARE = int'(UVM_COMPARE);
parameter NOCOMPARE = int'(UVM_NOCOMPARE);
parameter PRINT = int'(UVM_PRINT);
parameter NOPRINT = int'(UVM_NOPRINT);
parameter RECORD = int'(UVM_RECORD);
parameter NORECORD = int'(UVM_NORECORD);
parameter PACK = int'(UVM_PACK);
parameter NOPACK = int'(UVM_NOPACK);
parameter PHYSICAL = int'(UVM_PHYSICAL);
parameter ABSTRACT = int'(UVM_ABSTRACT);
parameter READONLY = int'(UVM_READONLY);
parameter NODEFPRINT = int'(UVM_NODEFPRINT);

typedef uvm_radix_enum radix_enum;
typedef uvm_bitstream_t bitstream_t;

function void print_topology();
   uvm_print_topology();
endfunction
function bit is_match(string e, string m);
  return uvm_is_match(e,m);
endfunction
function logic[UVM_LARGE_STRING:0] string_to_bits(string str);
  return uvm_string_to_bits(str);
endfunction
function string bits_to_string(logic[UVM_LARGE_STRING:0] str);
  return uvm_bits_to_string(str);
endfunction
function uvm_component get_unit(string name);
  return uvm_top.find(name);
endfunction
function automatic void get_units(string name, ref urm_unit_base cq[$]);
  uvm_top.find_all(name, cq);
endfunction

uvm_printer default_printer = uvm_default_printer;
uvm_tree_printer default_tree_printer = uvm_default_tree_printer;
uvm_line_printer default_line_printer = uvm_default_line_printer;
uvm_table_printer default_table_printer = uvm_default_table_printer;

`endif

`endif
