//
//------------------------------------------------------------------------------
//   Copyright 2007-2010 Mentor Graphics Corporation
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
//------------------------------------------------------------------------------

`ifndef UVM_METH_SVH
`define UVM_METH_SVH

  `include "methodology/uvm_pair.svh"
  `include "methodology/uvm_policies.svh"
  `include "methodology/uvm_in_order_comparator.svh"
  `include "methodology/uvm_algorithmic_comparator.svh"
  `include "methodology/uvm_random_stimulus.svh"
  `include "methodology/uvm_subscriber.svh"

  `include "methodology/sequences/uvm_sequence_item.svh"
  `include "methodology/sequences/uvm_sequencer_base.svh"
  `include "methodology/sequences/uvm_sequencer_analysis_fifo.svh"
  `include "methodology/sequences/uvm_sequencer_param_base.svh"
  `include "methodology/sequences/uvm_sequencer.svh"
  `include "methodology/sequences/uvm_push_sequencer.svh"
  `include "methodology/sequences/uvm_sequence_base.svh"
  `include "methodology/sequences/uvm_sequence.svh"
  `include "methodology/sequences/uvm_sequence_builtin.svh"

  `include "methodology/uvm_meth_defines.svh"

  `include "methodology/uvm_monitor.svh"
  `include "methodology/uvm_driver.svh"
  `include "methodology/uvm_push_driver.svh"
  `include "methodology/uvm_scoreboard.svh" 
  `include "methodology/uvm_agent.svh"
  `include "methodology/uvm_env.svh"
  `include "methodology/uvm_test.svh"

  typedef uvm_sequence  #(uvm_sequence_item, uvm_sequence_item) uvm_default_sequence_type;
  typedef uvm_sequencer #(uvm_sequence_item, uvm_sequence_item) uvm_default_sequencer_type;
  typedef uvm_driver    #(uvm_sequence_item, uvm_sequence_item) uvm_default_driver_type;
  typedef uvm_sequencer_param_base #(uvm_sequence_item, uvm_sequence_item) uvm_default_sequencer_param_type;

`endif //UVM_METH_SVH
