//------------------------------------------------------------------------------
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
//------------------------------------------------------------------------------

`define uvm_comp_task_phase(NAME) \
  virtual task NAME();  \
    super.NAME(); \
    uvm_report_info($psprintf("%m"),`"NAME begin`",UVM_MEDIUM); \
    #1000; \
    uvm_report_info($psprintf("%m"),`"NAME end`",UVM_MEDIUM); \
  endtask

`define uvm_comp_func_phase(NAME) \
  virtual function void NAME();  \
    super.NAME(); \
    uvm_report_info($psprintf("%m"),`"NAME`",UVM_MEDIUM); \
  endfunction


//------------------------------------------------------------------------------
// Class- my_uvm_comp
//
// Implements all the UVM phase callbacks with display statements to show
// when each phase is executed in a combined UVM / ENV environment. In UVM,
// all uvm_components possess phasing capability. This way, environments of
// today can become mere building block for larger environments without code
// rewrites. UVM environments are scalable for greater reuse potential.
//------------------------------------------------------------------------------

class uvm_comp_ext extends uvm_component;

  `uvm_component_utils(uvm_comp_ext)
  
  function new (string name, uvm_component parent=null);
    super.new(name,parent);
    enable_stop_interrupt = 1;
  endfunction

  // Implement each phase native to UVM
  `uvm_comp_func_phase(build)
  `uvm_comp_func_phase(connect)
  `uvm_comp_func_phase(end_of_elaboration)
  `uvm_comp_func_phase(start_of_simulation)
  `uvm_comp_task_phase(run)
  `uvm_comp_func_phase(extract)
  `uvm_comp_func_phase(check)
  `uvm_comp_func_phase(report)

  `ifdef INCLUDE_DEPRECATED
  `uvm_comp_func_phase(post_new)
  `uvm_comp_func_phase(export_connections)
  `uvm_comp_func_phase(import_connections)
  `uvm_comp_func_phase(configure)
  `uvm_comp_func_phase(pre_run)
  `endif

  virtual task stop(string ph_name); 
    uvm_report_info($psprintf("%m"),{get_full_name()," stop  Stopping phase ",ph_name},UVM_NONE);
    #1;
    uvm_report_info($psprintf("%m"),{get_full_name()," stop  Stopped phase ",ph_name},UVM_NONE);
  endtask

endclass

