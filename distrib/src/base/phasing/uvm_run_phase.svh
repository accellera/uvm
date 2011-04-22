//
//----------------------------------------------------------------------
//   Copyright 2007-2011 Mentor Graphics Corporation
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

// Class: uvm_run_phase
//
// Stimulate the DUT.
//
// This <uvm_task_phase> calls the
// <uvm_component::run_phase> virtual method. This phase runs in
// parallel to the runtime phases, <uvm_pre_reset_phase> through
// <uvm_post_shutdown_phase>. All components in the testbench
// are synchronized with respect to the run phase regardles of
// the phase domain they belong to.
//
// Upon Entry:
// - Indicates that power has been applied.
// - There should not have been any active clock edges before entry
//   into this phase (e.g. x->1 transitions via initial blocks).
// - Current simulation time is still equal to 0
//   but some "delta cycles" may have occurred.
//
// Typical Uses:
// - Components implement behavior that is exhibited for the entire
//   run-time, across the various run-time phases.
// - Backward compatibility with OVM.
//
// Exit Criteria:
// - The DUT no longer needs to be simulated, and 
// - The <uvm_post_shutdown_ph> is ready to end
//
// The run phase terminates in one of two ways.
//
// 1. All run_phase objections are dropped:
//
//   When all objections on the run_phase objection have been dropped,
//   the phase ends and all of its threads are killed.
//   If no component raises a run_phase objection immediately upon
//   entering the phase, the phase ends immediately.
//   
//
// 2. Timeout:
//
//   The phase ends if the timeout expires before all objections are dropped.
//   By default, the timeout is set to 9200 seconds.
//   You may override this via <set_global_timeout>.
//
//   If a timeout occurs in your simulation, or if simulation never
//   ends despite completion of your test stimulus, then it usually indicates
//   that a component continues to object to the end of a phase.
//
class uvm_run_phase extends uvm_task_phase; 
   virtual task exec_task(uvm_component comp, uvm_phase phase); 
      uvm_component comp_; 
      if ($cast(comp_,comp)) 
        comp_.run_phase(phase); 
   endtask : exec_task
   local static uvm_run_phase m_inst; 
   static const string type_name = "uvm_run_phase"; 
   static function uvm_run_phase get(); 
      if(m_inst == null) begin 
         m_inst = new; 
            end 
      return m_inst; 
   endfunction : get
   `_protected function new(string name="run"); 
      super.new(name); 
   endfunction : new
   virtual function string get_type_name(); 
      return type_name; 
   endfunction : get_type_name
endclass : uvm_run_phase
