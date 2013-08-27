//----------------------------------------------------------------------
//   Copyright 2013 Synopsys, Inc.
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

`ifndef PIPED_DRIVER_SV
`define PIPED_DRIVER_SV


//------------------------------------------------------------------------------
//
// CLASS: piped_driver
//
// declaration
//------------------------------------------------------------------------------


class piped_driver extends simple_driver;

  // Provide implementations of virtual methods such as get_type_name and create
  `uvm_component_utils(piped_driver)

  // Constructor
  function new (string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new

  task run_phase(uvm_phase phase);
    seq_item_port.disable_auto_item_recording();

    while(1) begin
      uvm_sequence_base pseq;
      seq_item_port.get_next_item(req);
      `uvm_info("Driver", "Received item :", UVM_MEDIUM)
      req.print();
      pseq = req.get_parent_sequence();
      accept_tr(req);
      #2;
      begin_child_tr(req, (pseq == null) ? 0 : pseq.get_tr_handle(),
                     req.get_root_sequence_name());

      #3;
      fork
        automatic simple_item tr = req;
        begin
          #12;
          `uvm_info("Driver", "Completed item :", UVM_MEDIUM)
          tr.print();
          end_tr(tr);
        end
      join_none
      seq_item_port.item_done();
    end
  endtask: run_phase

endclass : piped_driver


`endif // PIPED_DRIVER_SV
