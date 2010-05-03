//
//----------------------------------------------------------------------
//   Copyright 2007-2010 Mentor Graphics Corporation
//   Copyright 2007-2010 Cadence Design Systems, Inc. 
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

`define uvm_phase_type_name_decl(NAME) \
    virtual function string get_type_name (); \
      return `"NAME``_phase #(PARENT)`"; \
    endfunction

`define uvm_phase_func_decl(NAME,TOP_DOWN) \
  class NAME``_phase #(type PARENT=int) extends uvm_phase; \
    function new(); \
      super.new(`"NAME`",TOP_DOWN,0); \
    endfunction \
    `uvm_phase_type_name_decl(NAME) \
    virtual function void call_func(uvm_component parent); \
      PARENT m_parent; \
      super.call_func(parent); \
      if($cast(m_parent,parent)) begin \
        if(has_executed(parent)) begin \
          parent.uvm_report_warning("PHSEXEC", { "The phase ", get_name(), \
            " has already executed. Either the phase was not reset, or there", \
            " there is an invalid phase alias for this phase."}); \
          return; \
        end \
        set_executed(parent); \
        m_parent.NAME(); \
      end \
    endfunction \
  endclass

  
`define uvm_phase_task_decl(NAME,TOP_DOWN) \
  class NAME``_phase #(type PARENT=int) extends uvm_phase; \
    function new(); \
      super.new(`"NAME`",TOP_DOWN,1); \
    endfunction \
    `uvm_phase_type_name_decl(NAME) \
    virtual task call_task(uvm_component parent); \
      PARENT m_parent; \
      super.call_task(parent); \
      if($cast(m_parent,parent)) begin \
        if(has_executed(parent)) begin \
          parent.uvm_report_warning("PHSEXEC", { "The phase ", get_name(), \
            " has already executed. Either the phase was not reset, or there", \
            " there is an invalid phase alias for this phase."}); \
          return; \
        end \
        set_executed(parent); \
        m_parent.NAME(); \
      end \
    endtask \
  endclass


`define uvm_phase_func_topdown_decl(NAME)  `uvm_phase_func_decl(NAME,1)
`define uvm_phase_func_bottomup_decl(NAME) `uvm_phase_func_decl(NAME,0)
`define uvm_phase_task_topdown_decl(NAME)  `uvm_phase_task_decl(NAME,1)
`define uvm_phase_task_bottomup_decl(NAME) `uvm_phase_task_decl(NAME,0)
  
