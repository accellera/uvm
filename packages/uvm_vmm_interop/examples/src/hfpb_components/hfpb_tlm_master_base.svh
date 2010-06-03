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
//   the License for the specific language governing
//   permissions and limitations under the License.
//----------------------------------------------------------------------

import float_pkg::*;
import fpu_util_pkg::*;

//----------------------------------------------------------------------
// calc
//----------------------------------------------------------------------
class hfbp_uvm_tlm_master_base #(int DATA_SIZE=8, int ADDR_SIZE=16)
  extends uvm_threaded_component;

  uvm_transport_port #(hfpb_transaction #(DATA_SIZE, ADDR_SIZE),
                       hfpb_transaction #(DATA_SIZE, ADDR_SIZE))
        transport_port;

  localparam OPSIZE = 32;
  localparam WORDS = (OPSIZE / DATA_SIZE) +
                     ((OPSIZE - ((OPSIZE / DATA_SIZE) * DATA_SIZE)) > 0);

  typedef bit [DATA_SIZE-1:0] data_t;
  typedef bit [ADDR_SIZE-1:0] addr_t;
  typedef bit [OPSIZE-1:0] operand_t;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build();
    transport_port = new("transport_port", this);
  endfunction

  //--------------------------------------------------------------------
  // write_word
  //
  // write a single word to the bus
  //--------------------------------------------------------------------
  task write_word(input data_t d, input addr_t a);

    hfpb_transaction #(DATA_SIZE, ADDR_SIZE) req;
    hfpb_transaction #(DATA_SIZE, ADDR_SIZE) rsp;

    req = new();
    req.set_addr(a);
    req.set_wdata(d);
    req.set_write();

    transport_port.transport(req,rsp);

  endtask

  //--------------------------------------------------------------------
  // read_word
  //
  // read a single word from the bus
  //--------------------------------------------------------------------
  task read_word(output data_t d, input addr_t a);

    hfpb_transaction #(DATA_SIZE, ADDR_SIZE) req;
    hfpb_transaction #(DATA_SIZE, ADDR_SIZE) rsp;

    req = new();
    req.set_addr(a);
    req.set_read();

    transport_port.transport(req,rsp);

    d = rsp.get_rdata();

  endtask

  //--------------------------------------------------------------------
  // write_operand
  //
  // send an operand that consists of OPSIZE bits
  //--------------------------------------------------------------------
  task write_operand(input operand_t t, input addr_t a);

    data_t d;

    for(int unsigned i = WORDS; i > 0; i--) begin
      d = t[(i*DATA_SIZE)-1 -: DATA_SIZE];
      write_word(d, a);
      a++;
    end   

  endtask

  //--------------------------------------------------------------------
  // read_operand
  //
  // read an operand that consists of OPSIZE bits
  //--------------------------------------------------------------------
  task read_operand(output operand_t t, input addr_t a);

    data_t d;

    for(int unsigned i = WORDS; i > 0; i--) begin
      read_word(d, a);
      t[(i*DATA_SIZE)-1 -: DATA_SIZE] = d;
      a++;
    end   

  endtask

endclass
