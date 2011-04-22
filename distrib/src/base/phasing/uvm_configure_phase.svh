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

// Class: uvm_configure_phase
//
// The SW configures the DUT.
//
// <uvm_task_phase> that calls the
// <uvm_component::configure_phase> method.
//
// Upon Entry:
// - Indicates that the DUT is ready to be configured.
//
// Typical Uses:
// - Components required for DUT configuration execute transactions normally.
// - Set signals and program the DUT and memories
//   (e.g. read/write operations and sequences)
//   to match the desired configuration for the test and environment.
//
// Exit Criteria:
// - The DUT has been configured and is ready to operate normally.
//
class uvm_configure_phase extends uvm_task_phase; 
   virtual task exec_task(uvm_component comp, uvm_phase phase); 
      uvm_component comp_; 
      if ($cast(comp_,comp)) 
        comp_.configure_phase(phase); 
   endtask : exec_task
   local static uvm_configure_phase m_inst; 
   static const string type_name = "uvm_configure_phase"; 
   static function uvm_configure_phase get(); 
      if(m_inst == null) begin 
         m_inst = new; 
            end 
      return m_inst; 
   endfunction : get
   `_protected function new(string name="configure"); 
      super.new(name); 
   endfunction : new
   virtual function string get_type_name(); 
      return type_name; 
   endfunction : get_type_name
endclass : uvm_configure_phase
