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
    while(1) begin
      seq_item_port.get_next_item(req);
      `uvm_info("Driver", "Received item :", UVM_MEDIUM)
      req.print();
      #5;
      fork
        begin
          #2;
          `uvm_info("Driver", "Completed item :", UVM_MEDIUM)
          req.print();
        end
      join_none
      seq_item_port.item_done();
    end
  endtask: run_phase

endclass : piped_driver


`endif // PIPED_DRIVER_SV
