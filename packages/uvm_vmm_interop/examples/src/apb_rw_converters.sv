//-----------------------------------------------------------------------------
// Copyright 2008 Mentor Graphics Corporation
// All Rights Reserved Worldwide
// 
// Licensed under the Apache License, Version 2.0 (the "License"); you may
// not use this file except in compliance with the License.  You may obtain
// a copy of the License at
// 
//        http://www.apache.org/licenses/LICENSE-2.0
// 
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
// WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.  See the
// License for the specific language governing permissions and limitations
// under the License.
//-----------------------------------------------------------------------------

`ifndef UVM_APB_RW_CONVERTERS_SV
`define UVM_APB_RW_CONVERTERS_SV


//-----------------------------------------------------------------------------
//
// Title: apb_rw converter classes
//
// This file defines the following converter classes
//
// Static methods allow conversion without object allocation and is compile-time
// compile-time type-safe. Each class handles one direction, as many
// applications require conversion in only one direction.  
//
// In addition to the converters, this section also defines typedefs
// to APB-specific specializations for all the adapters.
//
// (inline source)
//-----------------------------------------------------------------------------

//-----------------------------------------------------------------------------
//
// Group: apb_rw_convert_uvm2vmm
//
// Convert UVM apb transactions to VMM apb transactions.
//-----------------------------------------------------------------------------

class apb_rw_convert_uvm2vmm;

  // Function: convert
  //
  // Converts an UVM apb transaction to a VMM apb transaction,
  // including the transaction/data and sequence/scenario ids.
  //
  // If the ~to~ argument is provided, the UVM transaction
  // contents are copied into the existing ~to~ VMM transaction.
  // Otherwise, a new VMM transaction is allocated, copied into,
  // and returned.

  static function vmm_apb_rw convert(uvm_apb_rw from, vmm_apb_rw to=null);
    if (to == null)
      convert = new;
    else
      convert = to;
    case (from.cmd)
      uvm_apb_rw::RD : convert.kind = vmm_apb_rw::READ;
      uvm_apb_rw::WR : convert.kind = vmm_apb_rw::WRITE;
    endcase
    convert.addr = from.addr;
    convert.data = from.data;
    convert.data_id = from.get_transaction_id();
    convert.scenario_id = from.get_sequence_id();
  endfunction
endclass


//-----------------------------------------------------------------------------
//
// Group: apb_rw_convert_vmm2uvm
//
// Convert VMM apb transactions to UVM apb transactions.
//-----------------------------------------------------------------------------

class apb_rw_convert_vmm2uvm;

  typedef uvm_apb_rw uvm_apb_rw;

  // Function: convert
  //
  // Converts a VMM apb transaction to an UVM apb transaction,
  // including the transaction/data and sequence/scenario ids.
  //
  // If the ~to~ argument is provided, the VMM transaction
  // contents are copied into the existing ~to~ UVM transaction.
  // Otherwise, a new UVM transaction is allocated, copied into,
  // and returned.

  static function uvm_apb_rw convert(vmm_apb_rw from, uvm_apb_rw to=null);
    if (to == null)
      convert = new;
    else
      convert = to;
    case (from.kind)
      vmm_apb_rw::READ: convert.cmd = uvm_apb_rw::RD;
      vmm_apb_rw::WRITE: convert.cmd = uvm_apb_rw::WR;
    endcase
    convert.addr = from.addr;
    convert.data = from.data;
    convert.set_transaction_id(from.data_id);
    convert.set_sequence_id(from.scenario_id);
  endfunction

endclass


//-----------------------------------------------------------------------------
//
// Typedefs-  APB Converter Types
//
// Define alternative names for the converters for those who
// speak in terms of transactions or items. Using the 'tr'
// style can indicate you do not intend to ut
//
// uvm2vmm_apb_tr_converter - convert
// uvm2vmm_apb_item_converter
// vmm2uvm_apb_tr_converter
// vmm2uvm_apb_item_converter
//------------------------------------------------------------------------------


typedef apb_rw_convert_uvm2vmm uvm2vmm_apb_tr_converter;
typedef apb_rw_convert_uvm2vmm uvm2vmm_apb_item_converter;
typedef apb_rw_convert_vmm2uvm vmm2uvm_apb_tr_converter;
typedef apb_rw_convert_vmm2uvm vmm2uvm_apb_item_converter;


//------------------------------------------------------------------------------
//
// Group:  Adapter Types
//
// Define adapter specialization typedefs for the apb_rw transactions type.
//
//------------------------------------------------------------------------------

typedef avt_channel2uvm_tlm
           #(vmm_apb_rw,uvm_apb_rw,
             apb_rw_convert_vmm2uvm,
             uvm_apb_rw,vmm_apb_rw,
             apb_rw_convert_uvm2vmm) apb_channel2uvm_tlm;

typedef avt_uvm_tlm2channel
           #(uvm_apb_rw,vmm_apb_rw,
             apb_rw_convert_uvm2vmm,
             vmm_apb_rw,uvm_apb_rw,
             apb_rw_convert_vmm2uvm) apb_uvm_tlm2channel;

typedef avt_analysis_channel
           #(uvm_apb_rw,vmm_apb_rw,
             apb_rw_convert_uvm2vmm,
             apb_rw_convert_vmm2uvm) apb_analysis_channel;

typedef avt_analysis2notify
           #(uvm_apb_rw,vmm_apb_rw,
             apb_rw_convert_uvm2vmm) apb_analysis2notify;

typedef avt_notify2analysis
           #(vmm_apb_rw,uvm_apb_rw,
             apb_rw_convert_vmm2uvm) apb_notify2analysis;


`endif // UVM_APB_RW_CONVERTERS_SV


