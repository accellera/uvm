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

// Class: uvm_report_phase
//
// Report results of the test.
//
// <uvm_bottomup_phase> that calls the
// <uvm_component::report_phase> method.
//
// Upon Entry:
// - Test is known to have passed or failed.
//
// Typical Uses:
// - Report test results.
// - Write results to file.
//
// Exit Criteria:
// - End of test.
//
class uvm_report_phase extends uvm_bottomup_phase;
   virtual function void exec_func(uvm_component comp, uvm_phase phase);
      uvm_component comp_;
      if ($cast(comp_,comp)) 
        comp_.report_phase(phase); 
   endfunction : exec_func
   local static uvm_report_phase m_inst;
   static const string type_name = "uvm_report_phase";
   static function uvm_report_phase get();
      if(m_inst == null) begin 
         m_inst = new();
      end
      return m_inst; 
   endfunction : get
   `_protected function new(string name="report");
      super.new(name); 
   endfunction : new
   virtual function string get_type_name();
      return type_name;
   endfunction : get_type_name
endclass : uvm_report_phase
