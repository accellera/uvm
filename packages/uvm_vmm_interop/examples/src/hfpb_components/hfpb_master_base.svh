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

import hfpb_pkg::*;

//----------------------------------------------------------------------
// hfpb__master_base
//
// Base class for building HFPB masters. The class contains a transport
// port to send requests to and retrieving responses from an HPFB agent
// or driver. It also contains some convenience functions for writing
// words and operands.  An operand is one or more words.
//
// Other services this class provides to derived masters includes:
//  *  a barrier which can be used as an objection mechanism.
//  *  an address map
//  *  `includes hfpb_parametes which povides typedefs and constants
//     for using the HFPB protocol with the FPU
//----------------------------------------------------------------------
// begin codeblock master_base
class hfpb_master_base
  #(int DATA_SIZE=8, int ADDR_SIZE=16)
    extends uvm_component;

  typedef hfpb_master_base
    #(DATA_SIZE, ADDR_SIZE) this_type;
  typedef uvm_component_registry
    #(this_type) type_id;

  `include "hfpb_parameters.svh"

  uvm_transport_port
    #(hfpb_tr_t, hfpb_tr_t) transport_port;

  uvm_barrier objection;
  protected hfpb_addr_map #(ADDR_SIZE) addr_map;
// end codeblock master_base

  //--------------------------------------------------------------------
  // new
  //--------------------------------------------------------------------
  function new(string name, uvm_component parent);

    uvm_barrier_pool barrier_pool;

    super.new(name, parent);

    barrier_pool = uvm_barrier_pool::get_global_pool();
    objection = barrier_pool.get(objection_barrier);
  endfunction

  //--------------------------------------------------------------------
  // build
  //--------------------------------------------------------------------
  function void build();

    uvm_object dummy;

    // obtain the address map
    if(get_config_object("addr_map", dummy, 0)) begin
      if(!$cast(addr_map, dummy))
        uvm_report_warning("build", "address map is incorrect type");
    end
    else
      uvm_report_warning("build", "no address map specified");

    transport_port = new("transport_port", this);

  endfunction

  //--------------------------------------------------------------------
  // words
  //
  // utility function that computes the number of DATA_SIZE words in a
  // bit size whose size is opsize.
  //--------------------------------------------------------------------
  function int unsigned words(int unsigned opsize);
    return (opsize / DATA_SIZE) +
           ((opsize - ((opsize / DATA_SIZE) * DATA_SIZE)) > 0);
  endfunction

  //--------------------------------------------------------------------
  // idle
  //
  // execute an idle transaction on the bus
  //--------------------------------------------------------------------
  task idle();

    hfpb_tr_t req;
    hfpb_tr_t rsp;

    req = new();
    req.set_idle();

    transport_port.transport(req, rsp);

  endtask

  //--------------------------------------------------------------------
  // write_word
  //
  // write a single word to the bus
  //--------------------------------------------------------------------
  task write_word(input data_t d, input int unsigned a);

    hfpb_tr_t req;
    hfpb_tr_t rsp;

    req = new();
    req.set_addr(a);
    req.set_wdata(d);
    req.set_write();
 
    transport_port.transport(req, rsp);

  endtask

  //--------------------------------------------------------------------
  // read_word
  //
  // read a single word from the bus
  //--------------------------------------------------------------------
  task read_word(output data_t d, input int unsigned a);

    hfpb_tr_t req;
    hfpb_tr_t rsp;

    req = new();
    req.set_addr(a);
    req.set_read();

    transport_port.transport(req, rsp);

    d = rsp.get_rdata();

  endtask

  //--------------------------------------------------------------------
  // write_operand
  //
  // send an operand that consists of one or more words
  //--------------------------------------------------------------------
  task write_operand(input operand_t t, input int unsigned a, int unsigned w = `WORDS);

    data_t d;
    
    for(int unsigned i = w; i > 0; i--) begin
      d = t[(i*DATA_SIZE)-1 -: DATA_SIZE];
      write_word(d, a);
      a++;
    end   

  endtask

  //--------------------------------------------------------------------
  // read_operand
  //
  // read an operand that consists of one or more words
  //--------------------------------------------------------------------
  task read_operand(output operand_t t, input int unsigned a, int unsigned w = `WORDS);

    data_t d;

    for(int unsigned i = w; i > 0; i--) begin
      read_word(d, a);
      t[(i*DATA_SIZE)-1 -: DATA_SIZE] = d;
      a++;
    end   

  endtask

endclass
