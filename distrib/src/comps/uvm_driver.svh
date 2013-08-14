//
//------------------------------------------------------------------------------
//   Copyright 2007-2011 Mentor Graphics Corporation
//   Copyright 2007-2010 Cadence Design Systems, Inc. 
//   Copyright 2010-2013 Synopsys, Inc.
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
//------------------------------------------------------------------------------

typedef class uvm_sequence_item;

//------------------------------------------------------------------------------
//
// CLASS: uvm_driver_base
//
// The base class for drivers components.
//
//------------------------------------------------------------------------------

class uvm_driver_base extends uvm_component;


  local bit m_auto_item_recording;

  // Function: new
  //
  // Creates and initializes an instance of this class using the normal
  // constructor arguments for <uvm_component>: ~name~ is the name of the
  // instance, and ~parent~ is the handle to the hierarchical parent, if any.

  function new (string name, uvm_component parent);
    super.new(name, parent);
    `ifdef UVM_DISABLE_AUTO_ITEM_RECORDING
    m_auto_item_recording = 0;
    `else
    m_auto_item_recording = 1;
    `endif
  endfunction // new

  virtual function string get_type_name ();
    return type_name;
  endfunction

  // Function: disable_auto_item_recording
  //
  // By default, item recording is performed automatically when
  // seq_item_port.get_next_item() and seq_item_port.finish_item() are called.
  // However, this works only for simple, in-order, blocking transaction
  // execution. For pipelined and out-of-order transaction execution, the
  // driver must turn off this automatic recording and call
  // uvm_transaction::accept_tr, uvm_transaction::begin_tr
  // and uvm_transaction::end_tr explicitly at appropriate points in time.
  //
  // Should be called in the constructor.
  // Once disabled, automatic recording cannot be re-enabled.
  //
  // For backward-compatibility, automatic item recording can be globally
  // turned off at compile time by defining UVM_DISABLE_AUTO_ITEM_RECORDING

  protected virtual function void disable_auto_item_recording();
    m_auto_item_recording = 0;
  endfunction

  // Function: is_auto_item_recording_enabled
  //
  // Return TRUE if automatic item recording is enabled for this instance.

  virtual function bit is_auto_item_recording_enabled();
    return m_auto_item_recording;
  endfunction

endclass

//------------------------------------------------------------------------------
//
// CLASS: uvm_driver #(REQ,RSP)
//
// The base class for drivers that initiate requests for new transactions via
// a uvm_seq_item_pull_port. The ports are typically connected to the exports of
// an appropriate sequencer component.
//
// This driver operates in pull mode. Its ports are typically connected to the
// corresponding exports in a pull sequencer as follows:
//
//|    driver.seq_item_port.connect(sequencer.seq_item_export);
//|    driver.rsp_port.connect(sequencer.rsp_export);
//
// The ~rsp_port~ needs connecting only if the driver will use it to write
// responses to the analysis export in the sequencer.
//
//------------------------------------------------------------------------------

class uvm_driver #(type REQ=uvm_sequence_item,
                   type RSP=REQ) extends uvm_driver_base;


  // Port: seq_item_port
  //
  // Derived driver classes should use this port to request items from the
  // sequencer. They may also use it to send responses back.

  uvm_seq_item_pull_port #(REQ, RSP) seq_item_port;

  uvm_seq_item_pull_port #(REQ, RSP) seq_item_prod_if; // alias

  // Port: rsp_port
  //
  // This port provides an alternate way of sending responses back to the
  // originating sequencer. Which port to use depends on which export the
  // sequencer provides for connection.

  uvm_analysis_port #(RSP) rsp_port;

  REQ req;
  RSP rsp;

  // Function: new
  //
  // Creates and initializes an instance of this class using the normal
  // constructor arguments for <uvm_component>: ~name~ is the name of the
  // instance, and ~parent~ is the handle to the hierarchical parent, if any.

  function new (string name, uvm_component parent);
    super.new(name, parent);
    seq_item_port    = new("seq_item_port", this);
    rsp_port         = new("rsp_port", this);
    seq_item_prod_if = seq_item_port;
  endfunction // new

  const static string type_name = "uvm_driver #(REQ,RSP)";

endclass

