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

// Class: uvm_connect_phase
//
// Establish cross-component connections.
//
// <uvm_bottomup_phase> that calls the
// <uvm_component::connect_phase> method.
//
// Upon Entry:
// - All components have been instantiated.
// - Current simulation time is still equal to 0
//   but some "delta cycles" may have occurred.
//
// Typical Uses:
// - Connect TLM ports and exports.
// - Connect TLM initiator sockets and target sockets.
// - Connect register model to adapter components.
// - Setup explicit phase domains.
//
// Exit Criteria:
// - All cross-component connections have been established.
// - All independent phase domains are set.
//

class uvm_connect_phase extends uvm_bottomup_phase;
   virtual function void exec_func(uvm_component comp, uvm_phase phase);
      uvm_component comp_;
      if ($cast(comp_,comp)) 
        comp_.connect_phase(phase); 
   endfunction : exec_func
   local static uvm_connect_phase m_inst;
   static const string type_name = "uvm_connect_phase";
   static function uvm_connect_phase get();
      if(m_inst == null) begin 
         m_inst = new();
      end
      return m_inst; 
   endfunction : get
   `_protected function new(string name="connect");
      super.new(name); 
   endfunction : new
   virtual function string get_type_name();
      return type_name;
   endfunction : get_type_name
endclass : uvm_connect_phase
