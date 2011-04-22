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

// Class: uvm_extract_phase
//
// Extract data from different points of the verficiation environment.
//
// <uvm_bottomup_phase> that calls the
// <uvm_component::extract_phase> method.
//
// Upon Entry:
// - The DUT no longer needs to be simulated.
// - Simulation time will no longer advance.
//
// Typical Uses:
// - Extract any remaining data and final state information
//   from scoreboard and testbench components
// - Probe the DUT (via zero-time hierarchical references
//   and/or backdoor accesses) for final state information.
// - Compute statistics and summaries.
// - Display final state information
// - Close files.
//
// Exit Criteria:
// - All data has been collected and summarized.
//
class uvm_extract_phase extends uvm_bottomup_phase;
   virtual function void exec_func(uvm_component comp, uvm_phase phase);
      uvm_component comp_;
      if ($cast(comp_,comp)) 
        comp_.extract_phase(phase); 
   endfunction : exec_func
   local static uvm_extract_phase m_inst;
   static const string type_name = "uvm_extract_phase";
   static function uvm_extract_phase get();
      if(m_inst == null) begin 
         m_inst = new();
      end
      return m_inst; 
   endfunction : get
   `_protected function new(string name="extract");
      super.new(name); 
   endfunction : new
   virtual function string get_type_name();
      return type_name;
   endfunction : get_type_name
endclass : uvm_extract_phase
