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
  extends uvm_port_base #(uvm_sqr_if_base #(REQ, RSP));

`ifdef UVM_DISABLE_AUTO_ITEM_RECORDING
  local bit m_auto_item_recording = 0;
`else
  local bit m_auto_item_recording = 1;
`endif
  local uvm_sequence_item m_prev_req = null;


  // Function: disable_auto_item_recording
  //
  // By default, item recording is performed automatically when
  // get_next_item() and finish_item() are called.
  // However, this works only for simple, in-order, blocking transaction
  // execution. For pipelined and out-of-order transaction execution, the
  // consumer must turn off this automatic recording and call
  // uvm_transaction::accept_tr, uvm_transaction::begin_tr
  // and uvm_transaction::end_tr explicitly at appropriate points in time.
  //
  // Should be called in the consumer's constructor, after the sequencer port has been instantiated.
  // Once disabled, automatic recording cannot be re-enabled.
  //
  // For backward-compatibility, automatic item recording can be globally
  // turned off at compile time by defining UVM_DISABLE_AUTO_ITEM_RECORDING

  virtual function void disable_auto_item_recording();
    m_auto_item_recording = 0;
  endfunction

  // Function: is_auto_item_recording_enabled
  //
  // Return TRUE if automatic item recording is enabled for this port instance.

  virtual function bit is_auto_item_recording_enabled();
    return m_auto_item_recording;
  endfunction

  local function void m_begin_tr(uvm_sequence_item req);
    uvm_sequencer_base sqr = req.get_sequencer();
    if (m_auto_item_recording && sqr != null) begin
      uvm_sequence_base pseq = req.get_parent_sequence();
      sqr.begin_child_tr(req, (pseq == null) ? 0 : pseq.get_tr_handle(),
                         req.get_root_sequence_name());
      m_prev_req = req;
    end
  endfunction
  
  local function void m_end_tr();
    if (m_prev_req != null) begin
      uvm_sequencer_base sqr = m_prev_req.get_sequencer();
      if (m_auto_item_recording && sqr != null && m_prev_req != null) begin
        sqr.end_tr(m_prev_req);
        m_prev_req = null;
      end
    end
  endfunction

  `UVM_SEQ_PORT(`UVM_SEQ_ITEM_PULL_MASK, "uvm_seq_item_pull_port")
  `UVM_SEQ_ITEM_PULL_IMP(this.m_if, REQ, RSP, t, t)

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

  local function void m_begin_tr(uvm_sequence_item req);
  endfunction
  
  local function void m_end_tr();
  endfunction

   // Function: new
  `UVM_IMP_COMMON(`UVM_SEQ_ITEM_PULL_MASK, "uvm_seq_item_pull_imp",IMP)
  `UVM_SEQ_ITEM_PULL_IMP(m_imp, REQ, RSP, t, t)

endclass
