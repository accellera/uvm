`ifndef UVM_PHASE_DEFINES_SVH
`define UVM_PHASE_DEFINES_SVH
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


// uvm_root.svh uses these macros to simplify creation of all the phases.
// they are only to be used for UVM builtin phases, because they are simple
// delegate imps that call the corresponding methods on uvm_component.
// Also, they declare classes and singleton instances with the uvm_ prefix.

// If you require more complex phase functors for your custom phase, code your
// own imp class extending uvm_task/topdown/bottomup_phase base classes, following
// the pattern of the macros below, but customize the exec_task() or exec_func()
// contents to suit your enhanced functionality or derived component type/methods.

`define m_uvm_task_phase(PHASE,COMP,PREFIX) \
        class PREFIX``PHASE``_phase extends uvm_task_phase(`"PHASE`"); \
          task exec_task(uvm_component comp, uvm_phase phase); \
            COMP comp_; \
            if ($cast(comp_,comp)) \
              comp_.``PHASE``_phase(phase); \
          endtask \
          static PREFIX``PHASE``_phase m_inst = get(); \
          static function PREFIX``PHASE``_phase get(); \
            if(m_inst == null) m_inst = new; \
            return m_inst; \
          endfunction \
        endclass \
        PREFIX``PHASE``_phase PREFIX``PHASE``_ph = PREFIX``PHASE``_phase::get();

`define m_uvm_topdown_phase(PHASE,COMP,PREFIX) \
        class PREFIX``PHASE``_phase extends uvm_topdown_phase(`"PHASE`"); \
          function void exec_func(uvm_component comp, uvm_phase phase); \
            COMP comp_; \
            if ($cast(comp_,comp)) \
              comp_.``PHASE``_phase(phase); \
          endfunction \
          static PREFIX``PHASE``_phase m_inst = get(); \
          static function PREFIX``PHASE``_phase get(); \
            if(m_inst == null) m_inst = new; \
            return m_inst; \
          endfunction \
        endclass \
        PREFIX``PHASE``_phase PREFIX``PHASE``_ph = PREFIX``PHASE``_phase::get();

`define m_uvm_bottomup_phase(PHASE,COMP,PREFIX) \
        class PREFIX``PHASE``_phase extends uvm_bottomup_phase(`"PHASE`"); \
          function void exec_func(uvm_component comp, uvm_phase phase); \
            COMP comp_; \
            if ($cast(comp_,comp)) \
              comp_.``PHASE``_phase(phase); \
          endfunction \
          static PREFIX``PHASE``_phase m_inst = get(); \
          static function PREFIX``PHASE``_phase get(); \
            if(m_inst == null) m_inst = new; \
            return m_inst; \
          endfunction \
        endclass \
        PREFIX``PHASE``_phase PREFIX``PHASE``_ph = PREFIX``PHASE``_phase::get();


`define uvm_builtin_task_phase(PHASE) \
        `m_uvm_task_phase(PHASE,uvm_component,uvm_)

`define uvm_builtin_topdown_phase(PHASE) \
        `m_uvm_topdown_phase(PHASE,uvm_component,uvm_)

`define uvm_builtin_bottomup_phase(PHASE) \
        `m_uvm_bottomup_phase(PHASE,uvm_component,uvm_)


`define uvm_user_task_phase(PHASE,COMP,PREFIX) \
        `m_uvm_task_phase(PHASE,COMP,PREFIX)

`define uvm_user_topdown_phase(PHASE,COMP) \
        `m_uvm_topdown_phase(PHASE,COMP,PREFIX)

`define uvm_user_bottomup_phase(PHASE,COMP) \
        `m_uvm_bottomup_phase(PHASE,COMP,PREFIX)

`endif
