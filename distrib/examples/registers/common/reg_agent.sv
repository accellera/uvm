//------------------------------------------------------------------------------
// Copyright 2010 Synopsys, Inc.
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
//
// CLASS: reg_sequencer
//
//------------------------------------------------------------------------------

class reg_sequencer extends uvm_sequencer #(uvm_reg_bus_item);
  `uvm_component_param_utils(reg_sequencer)
  function new(string name, uvm_component parent=null);
    super.new(name,parent);
  endfunction
endclass


//------------------------------------------------------------------------------
//
// CLASS: reg_monitor
//
//------------------------------------------------------------------------------

typedef class reg_monitor;

class reg_monitor extends uvm_component;

  `uvm_component_param_utils(reg_monitor)

  uvm_analysis_port #(uvm_reg_bus_item) ap;

  function new(string name, uvm_component parent=null);
    super.new(name,parent);
  endfunction

  function void build();
    ap = new("ap",this);
  endfunction

  uvm_reg_bus_item item;
   
  virtual task run();
    fork
      forever begin
        @item;
        ap.write(item);
      end
    join
  endtask

endclass


//------------------------------------------------------------------------------
//
// CLASS: reg_driver
//
// This driver's run task will continually retrieve, execute, and send back
// a response in one of three ways, using get_next_item/item_done.
//
//------------------------------------------------------------------------------

class reg_driver #(type DO=int) extends uvm_component;

  `uvm_component_param_utils(reg_driver #(DO))

  uvm_seq_item_pull_port #(uvm_reg_bus_item) seqr_port;

  function new(string name, uvm_component parent=null);
    super.new(name,parent);
    seqr_port = new("seqr_port",this);
  endfunction


  task run();

    forever begin
      uvm_reg_bus_item item;
       
      seqr_port.peek(item); // aka 'get_next_item'

       DO::rw(item);
       
      seqr_port.get(item); // aka 'item_done'
    end
  endtask

endclass


//------------------------------------------------------------------------------
//
// CLASS: reg_agent
//
//------------------------------------------------------------------------------

class reg_agent #(type DO=int) extends uvm_component;

  `uvm_component_param_utils(reg_agent #(DO))

  function new(string name, uvm_component parent=null);
    super.new(name,parent);
  endfunction

  uvm_analysis_port #(uvm_reg_bus_item) ap;

  reg_sequencer       sqr;
  reg_driver    #(DO) drv;
  reg_monitor         mon;

  virtual function void build();
    ap = new("ap",this);

    sqr =   reg_sequencer::type_id::create("sqr",this);
    drv = reg_driver#(DO)::type_id::create("drv",this);
    mon =     reg_monitor::type_id::create("mon",this);
  endfunction

  virtual function void connect();
    drv.seqr_port.connect(sqr.seq_item_export);
    mon.ap.connect(ap);
  endfunction

endclass
