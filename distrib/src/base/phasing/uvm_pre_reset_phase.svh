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

// Class: uvm_pre_reset_phase
//
// Before reset is asserted.
//
// <uvm_task_phase> that calls the
// <uvm_component::pre_reset_phase> method. This phase starts at the
// same time as the <uvm_run_ph> unless a user defined phase is inserted
// in front of this phase.
//
// Upon Entry:
// - Indicates that power has been applied but not necessarily valid or stable.
// - There should not have been any active clock edges
//   before entry into this phase.
//
// Typical Uses:
// - Wait for power good.
// - Components connected to virtual interfaces should initialize
//   their output to X's or Z's.
// - Initialize the clock signals to a valid value
// - Assign reset signals to X (power-on reset).
// - Wait for reset signal to be asserted
//   if not driven by the verification environment.
//
// Exit Criteria:
// - Reset signal, if driven by the verification environment,
//   is ready to be asserted.
// - Reset signal, if not driven by the verification environment, is asserted.
//
class uvm_pre_reset_phase extends uvm_task_phase; 
   virtual task exec_task(uvm_component comp, uvm_phase phase); 
      uvm_component comp_; 
      if ($cast(comp_,comp)) 
        comp_.pre_reset_phase(phase); 
   endtask : exec_task
   local static uvm_pre_reset_phase m_inst; 
   static const string type_name = "uvm_pre_reset_phase"; 
   static function uvm_pre_reset_phase get(); 
      if(m_inst == null) begin 
         m_inst = new; 
            end 
      return m_inst; 
   endfunction : get
   `_protected function new(string name="pre_reset"); 
      super.new(name); 
   endfunction : new
   virtual function string get_type_name(); 
      return type_name; 
   endfunction : get_type_name
endclass : uvm_pre_reset_phase
