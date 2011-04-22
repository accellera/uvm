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

//
// Class: uvm_post_reset_phase
//
// After reset is de-asserted.
//
// <uvm_task_phase> that calls the
// <uvm_component::post_reset_phase> method.
//
// Upon Entry:
// - Indicates that the DUT reset signal has been de-asserted.
//
// Typical Uses:
// - Components should start behavior appropriate for reset being inactive.
//   For example, components may start to transmit idle transactions
//   or interface training and rate negotiation.
//   This behavior typically continues beyond the end of this phase.
//
// Exit Criteria:
// - The testbench and the DUT are in a known, active state.
//
class uvm_post_reset_phase extends uvm_task_phase; 
   virtual task exec_task(uvm_component comp, uvm_phase phase); 
      uvm_component comp_; 
      if ($cast(comp_,comp)) 
        comp_.post_reset_phase(phase); 
   endtask : exec_task
   local static uvm_post_reset_phase m_inst; 
   static const string type_name = "uvm_post_reset_phase"; 
   static function uvm_post_reset_phase get(); 
      if(m_inst == null) begin 
         m_inst = new; 
            end 
      return m_inst; 
   endfunction : get
   `_protected function new(string name="post_reset"); 
      super.new(name); 
   endfunction : new
   virtual function string get_type_name(); 
      return type_name; 
   endfunction : get_type_name
endclass : uvm_post_reset_phase
