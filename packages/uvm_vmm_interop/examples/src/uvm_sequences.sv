//------------------------------------------------------------------------------
// Copyright 2008 Mentor Graphics Corporation
// All Rights Reserved Worldwide
// 
// Licensed under the Apache License, Version 2.0 (the "License"); you may
// not use this file except in compliance with the License.  You may obtain
// a copy of the License at
// 
//        http://www.apache.org/licenses/LICENSE-2.0
// 
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
// WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.  See the
// License for the specific language governing permissions and limitations
// under the License.
//------------------------------------------------------------------------------


//------------------------------------------------------------------------------
// Title: UVM Sequences
//
// This file defines the following sequences.
//
//------------------------------------------------------------------------------


//------------------------------------------------------------------------------
//
// Group: uvm_apb_rw_sequence
//
// This simple APB transaction sequence generates ~num_trans~ sequence items
// (transactions). The convenience macos `uvm_do_with is not used in order
// that you see how to what the macro does behind the scenes. 
//------------------------------------------------------------------------------

// (begin inline source)
class uvm_apb_rw_sequence extends uvm_sequence #(uvm_apb_item);

  `uvm_object_utils(uvm_apb_rw_sequence)

  rand int unsigned num_trans = 5; 

  constraint max_count { num_trans <= m_sequencer.max_random_count; }

  function new(string name = "apb_random");
    super.new(name);
  endfunction

  task body();

    uvm_apb_tr req = super.req;

    uvm_report_info(get_full_name(), "Write sequence starting");

    for (int i = 0; i < num_trans; i++) begin

      `uvm_do_with(req, {
         addr[9:8] != 2'b11;
         addr[7:0] < 8'd100;
         addr[31:10] == 0;
         data < 8'd100;
      });

      uvm_report_info(get_type_name(),
         $psprintf("Got response: cmd=%s addr=%h data=%h",
	           req.cmd,req.addr,req.data));
    end
    uvm_report_info(get_full_name(), "Write sequence completing");

  endtask

endclass
// (end inline source)



//------------------------------------------------------------------------------
//
// Group: uvm_apb_rw_sequence_grab
//
// Defines a contrived sequence that exercises the ~grab~ and ~ungrab~ feature.
// A fixed address is used in order to better identify transactions coming from
// this sequence.
//------------------------------------------------------------------------------

// (begin inline source)
class uvm_apb_rw_sequence_grab extends uvm_sequence #(uvm_apb_item);

  `uvm_object_utils(uvm_apb_rw_sequence_grab)

  rand int unsigned fixed_addr;

  function new(string name = "apb_random");
    super.new(name);
  endfunction

  task body();

    uvm_apb_rw req;

    uvm_report_info(get_full_name(), "Write sequence starting");

    `uvm_do_with(req, { addr == fixed_addr; data < 8'd100; });
    `uvm_do_with(req, { addr == fixed_addr; data < 8'd100; });
    `uvm_do_with(req, { addr == fixed_addr; data < 8'd100; });
    `uvm_do_with(req, { addr == fixed_addr; data < 8'd100; });
    `uvm_do_with(req, { addr == fixed_addr; data < 8'd100; });

    uvm_report_info("UVM APB Grab Sequence", "\nSEQUENCE grabbing sequencer\n");
    grab();

    // use constant addresses to easily verify grab was successful
    `uvm_do_with(req, { addr == 4; data < 8'd100; });
    `uvm_do_with(req, { addr == 4; data < 8'd100; });
    `uvm_do_with(req, { addr == 4; data < 8'd100; });
    `uvm_do_with(req, { addr == 4; data < 8'd100; });

    uvm_report_info("UVM APB Grab Sequence", "\nSEQUENCE ungrabbing sequencer\n");
    ungrab();

    `uvm_do_with(req, { addr == fixed_addr; data < 8'd100; });
    `uvm_do_with(req, { addr == fixed_addr; data < 8'd100; });
    `uvm_do_with(req, { addr == fixed_addr; data < 8'd100; });
    `uvm_do_with(req, { addr == fixed_addr; data < 8'd100; });

    uvm_report_info(get_full_name(), "Write sequence completing");

  endtask

endclass
// (end inline source)


