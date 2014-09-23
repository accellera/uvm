//
//-----------------------------------------------------------------------------
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
//-----------------------------------------------------------------------------

//-----------------------------------------------------------------------------
// Title: Sequence Item Pull Ports
//
// This section defines the port, export, and imp port classes for
// communicating sequence items between <uvm_sequencer #(REQ,RSP)> and
// <uvm_driver #(REQ,RSP)>.
//-----------------------------------------------------------------------------

//-----------------------------------------------------------------------------
//
// Class: uvm_seq_item_pull_port #(REQ,RSP)
//
// UVM provides a port, export, and imp connector for use in sequencer-driver
// communication. All have standard port connector constructors, except that
// uvm_seq_item_pull_port's default min_size argument is 0; it can be left
// unconnected.
//
//-----------------------------------------------------------------------------

class uvm_seq_item_pull_port #(type REQ=int, type RSP=REQ)

// @DVT_EXPAND_MACRO_INLINE_START
//   extends uvm_port_base #(uvm_sqr_if_base #(REQ, RSP));
//   `UVM_SEQ_PORT(`UVM_SEQ_ITEM_PULL_MASK, "uvm_seq_item_pull_port")
//   `UVM_SEQ_ITEM_PULL_IMP(this.m_if, REQ, RSP, t, t)
// 
// @DVT_EXPAND_MACRO_INLINE_ORIGINAL
  extends uvm_port_base #(uvm_sqr_if_base #(REQ, RSP));
  
  function new (string name, uvm_component parent, 
                int min_size=0, int max_size=1); 
    super.new (name, parent, UVM_PORT, min_size, max_size); 
    m_if_mask = ((1<<0) | (1<<1) |                          (1<<2) | (1<<3) |                           (1<<4) | (1<<5) |                          (1<<6) | (1<<7) | (1<<8)); 
  endfunction 
  
  virtual function string get_type_name(); 
    return "uvm_seq_item_pull_port"; 
  endfunction
  
  function void disable_auto_item_recording(); this.m_if.disable_auto_item_recording(); endfunction 
  function bit is_auto_item_recording_enabled(); return this.m_if.is_auto_item_recording_enabled(); endfunction 
  task get_next_item(output REQ t); this.m_if.get_next_item(t); endtask 
  task try_next_item(output REQ t); this.m_if.try_next_item(t); endtask 
  function void item_done(input RSP t = null); this.m_if.item_done(t); endfunction 
  task wait_for_sequences(); this.m_if.wait_for_sequences(); endtask 
  function bit has_do_available(); return this.m_if.has_do_available(); endfunction 
  function void put_response(input RSP t); this.m_if.put_response(t); endfunction 
  task get(output REQ t); this.m_if.get(t); endtask 
  task peek(output REQ t); this.m_if.peek(t); endtask 
  task put(input RSP t); this.m_if.put(t); endtask

// @DVT_EXPAND_MACRO_INLINE_END

  bit print_enabled;
    
endclass


//-----------------------------------------------------------------------------
//
// Class: uvm_seq_item_pull_export #(REQ,RSP)
//
// This export type is used in sequencer-driver communication. It has the
// standard constructor for exports.
//
//-----------------------------------------------------------------------------

class uvm_seq_item_pull_export #(type REQ=int, type RSP=REQ)
  extends uvm_port_base #(uvm_sqr_if_base #(REQ, RSP));
  `UVM_EXPORT_COMMON(`UVM_SEQ_ITEM_PULL_MASK, "uvm_seq_item_pull_export")
  `UVM_SEQ_ITEM_PULL_IMP(this.m_if, REQ, RSP, t, t)
endclass


//-----------------------------------------------------------------------------
//
// Class: uvm_seq_item_pull_imp #(REQ,RSP,IMP)
//
// This imp type is used in sequencer-driver communication. It has the
// standard constructor for imp-type ports.
//
//-----------------------------------------------------------------------------

class uvm_seq_item_pull_imp #(type REQ=int, type RSP=REQ, type IMP=int)
  extends uvm_port_base #(uvm_sqr_if_base #(REQ, RSP));
   // Function: new
  `UVM_IMP_COMMON(`UVM_SEQ_ITEM_PULL_MASK, "uvm_seq_item_pull_imp",IMP)
  `UVM_SEQ_ITEM_PULL_IMP(m_imp, REQ, RSP, t, t)

endclass
