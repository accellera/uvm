//------------------------------------------------------------------------------
// Copyright 2010-2011 Mentor Graphics Corporation
// Copyright 2011 Synopsys, Inc.
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


// shared memory (representing the DUT's registers)

uvm_reg_data_t mem[uvm_reg_addr_t];

//------------------------------------------------------------------------------
//
// CLASS: any_sequence
//
//------------------------------------------------------------------------------

virtual class any_item extends uvm_sequence_item;
  function new(string name="");
    super.new(name);
  endfunction
  event executed;
endclass


//------------------------------------------------------------------------------
//
// CLASS: any_sequence
//
//------------------------------------------------------------------------------

class any_sequence #(type REQ=int,RSP=REQ) extends uvm_sequence #(REQ,RSP);
  `uvm_object_param_utils(any_sequence #(REQ,RSP))
  function new(string name="");
    super.new(name);
  endfunction
  virtual task finish_item (uvm_sequence_item item,
                            int set_priority = -1);
    any_item t;
    super.finish_item(item,set_priority);
    // wait for driver to indicate actual done-ness
    if ($cast(t,item))
      @t.executed;
  endtask
endclass

//------------------------------------------------------------------------------
//
// CLASS: any_sequencer
//
//------------------------------------------------------------------------------

class any_sequencer #(type REQ=int,RSP=REQ) extends uvm_sequencer #(REQ,RSP);
  `uvm_component_param_utils(any_sequencer #(REQ,RSP))
  function new(string name, uvm_component parent=null);
    super.new(name,parent);
  endfunction
endclass


//------------------------------------------------------------------------------
//
// CLASS: any_monitor
//
//------------------------------------------------------------------------------

typedef class any_monitor;

class any_monitor #(type REQ=int,RSP=REQ) extends uvm_component;

  `uvm_component_param_utils(any_monitor #(REQ,RSP))

  uvm_analysis_port #(REQ) req_ap;

  function new(string name, uvm_component parent=null);
    super.new(name,parent);
  endfunction

  function void build_phase(uvm_phase phase);
    req_ap = new("req_ap",this);
  endfunction

  REQ req;

  virtual task run_phase(uvm_phase phase);
    fork
      forever begin
        @req;
        req_ap.write(req);
      end
    join
  endtask

endclass


//------------------------------------------------------------------------------
//
// CLASS: any_driver
//
// This driver's run task will continually retrieve, execute, and send back
// a response in one of three ways, chosen randomly-- either using peek/get,
// get/delay/put, or get_next_item/item_done.
//
// Used for the examples, the transaction type for REQ and RSP must define
//   addr - integral type $bits(uvm_reg_addr_t) or less
//   data - integral type $bits(uvm_reg_data_t) or less
//   read - bit 1=read operation, 0=write operation
//------------------------------------------------------------------------------

typedef class apb_item; // facilitate our hack of the address map for APB

class any_driver #(type REQ=int,RSP=REQ) extends uvm_component;

  `uvm_component_param_utils(any_driver #(REQ,RSP))

  static string type_name = {"any_driver#(",REQ::type_name,",",RSP::type_name,")"};
  virtual function string get_type_name();
    return type_name;
  endfunction

  uvm_seq_item_pull_port #(REQ) seqr_port;

  function new(string name, uvm_component parent=null);
    super.new(name,parent);
    seqr_port = new("seqr_port",this);
  endfunction

  uvm_reg_addr_t base_addr;

  virtual task do_req(REQ req);
    uvm_reg_addr_t addr = req.addr - base_addr;

    // *** just implement the fake "DUT" here rather than drive signals **

    // Address Map:
    //
    //         A   X   W
    // APB    10   0   -
    // WSH     -  10   0

    // remap APB so for APB: regA is at addr 1, regX is at addr 0
    // for WSH: shared regX is also at addr 0, regW is at addr 'h10
    apb_item item;
    if ($cast(item,req)) begin
       if (req.addr == 'h10)  // regX bus addr => mem[0]
         req.addr = 'h0;
       else if (req.addr == 'h0) // regA bus addr => mem[1]
         req.addr = 'h1;
    end

    if (!req.read) begin
      mem[req.addr] = req.data;
    end
    else begin
      if (mem.exists(req.addr))
        req.data = mem[req.addr];
      else
        req.data = 'h1;
    end
  endtask

  task run_phase(uvm_phase phase);

    REQ req;

    `uvm_info({"DRIVER-",get_type_name()},"Starting...",UVM_LOW);
    
    forever begin

      //seqr_port.peek(req); // aka 'get_next_item'
      seqr_port.get(req);

      if (!req.read)
        `uvm_info({"DRIVER-",req.get_type_name()},{"Received write request: ",req.convert2string()},UVM_HIGH)

      #10;

      do_req(req);

      if (req.read)
         `uvm_info({"DRIVER-",req.get_type_name()},{"Executed read request: ",req.convert2string()},UVM_HIGH)

      //seqr_port.get(req); // aka 'item_done'
      ->req.executed;

    end
  endtask

endclass


//------------------------------------------------------------------------------
//
// CLASS: any_sequencer
//
//------------------------------------------------------------------------------

class any_agent #(type REQ=int, RSP=REQ) extends uvm_component;

  `uvm_component_param_utils(any_agent #(REQ,RSP))

  function new(string name, uvm_component parent=null);
    super.new(name,parent);
  endfunction

  uvm_analysis_port #(REQ) req_ap;

  any_sequencer #(REQ,RSP) sqr;
  any_driver    #(REQ,RSP) drv;
  any_monitor   #(REQ,RSP) mon;

  virtual function void build_phase(uvm_phase phase);
    req_ap = new("req_ap",this);
    sqr = any_sequencer#(REQ,RSP)::type_id::create("sqr",this);
    drv =    any_driver#(REQ,RSP)::type_id::create("drv",this);
    mon =   any_monitor#(REQ,RSP)::type_id::create("mon",this);
  endfunction

  virtual function void connect_phase(uvm_phase phase);
    drv.seqr_port.connect(sqr.seq_item_export);
    mon.req_ap.connect(req_ap);
  endfunction

endclass
