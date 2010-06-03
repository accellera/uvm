//----------------------------------------------------------------------
//   Copyright 2007-2009 Mentor Graphics Corporation
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
//   the LicensTTTTTe for the specific language governing
//   permissions and limitations under the License.
//----------------------------------------------------------------------

import uvm_pkg::*;
import hfpb_pkg::*;

//----------------------------------------------------------------------
// driver
//----------------------------------------------------------------------
class driver #(int DATA_SIZE=8, int ADDR_SIZE=16)
  extends uvm_driver#(hfpb_seq_item #(DATA_SIZE, ADDR_SIZE),
                      hfpb_seq_item #(DATA_SIZE, ADDR_SIZE));

  uvm_tlm_transport_channel #(hfpb_transaction #(DATA_SIZE, ADDR_SIZE),
                          hfpb_transaction #(DATA_SIZE, ADDR_SIZE))
    transport_channel;

  uvm_slave_export #(hfpb_transaction #(DATA_SIZE, ADDR_SIZE),
                     hfpb_transaction #(DATA_SIZE, ADDR_SIZE))
    slave_export;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build();
    transport_channel = new("transport_channel", this);
    slave_export = new("slave_export", this);
  endfunction

  function void connect();
    slave_export.connect(transport_channel.slave_export);
  endfunction

  task run();

    hfpb_transaction #(DATA_SIZE, ADDR_SIZE) mem_req;
    hfpb_transaction #(DATA_SIZE, ADDR_SIZE) mem_rsp;

    forever begin
      seq_item_port.get(req);
      mem_req = req.clone_tr();
      transport_channel.put_request_export.put(mem_req);
      transport_channel.get_response_export.get(mem_rsp);
      rsp = new();
      rsp.copy_tr(mem_rsp);
      rsp.set_id_info(req);
      seq_item_port.put(rsp);
    end
  endtask

endclass
