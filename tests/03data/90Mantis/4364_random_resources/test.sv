//---------------------------------------------------------------------- 
//   Copyright 2011 Synopsys, Inc. 
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

`include "uvm_macros.svh"
program top;

import uvm_pkg::*;

// ----------------  DMA  ------------------
class dma_channel;
   bit [2:0] channel_num;
   bit [1:0] controller_num;

   function new(bit [1:0] controller, bit [2:0] channel);
      channel_num=channel;
      controller_num = controller;
   endfunction
endclass

class dma_converter extends uvm_converter#(dma_channel, bit[4:0]);
  virtual function bit[4:0] serialize(dma_channel object);
    return {object.controller_num,object.channel_num};
  endfunction: serialize
  virtual function dma_channel deserialize(bit[4:0] item);
    dma_channel object;

    object = new(item[4:3],item[2:0]);
    return object;
  endfunction: deserialize
  
endclass // uvm_serializer
   
class dma_policy extends uvm_item_alloc_policy#(dma_channel, bit[4:0]);

   constraint is_valid {
      item >= 0 && item <= 4'hf;
   }

  function new();
    dma_converter conv = new;
    converter = conv;
  endfunction
   // item[4:3] => controller number
   // item[2:0] => channel number
endclass // dma_policy

class even_odd_policy extends dma_policy;

   constraint even_odd {
      item[3] == 0 -> item[0] == 0;
      item[3] == 1 -> item[0] == 1;
      
   }
endclass


class top_seq extends uvm_sequence;
   `uvm_object_utils(top_seq)

   function new(string name = "");
      super.new(name);
   endfunction
   
   task body();
     uvm_item_allocator#(dma_channel, bit[4:0]) dma_allocator;
     even_odd_policy eo_policy;
     dma_channel allocated_channels[$];
     longint db[];
     eo_policy = new;
     
     if (starting_phase != null) starting_phase.raise_objection(this);


     if (uvm_config_db#(uvm_item_allocator#(dma_channel, bit[4:0]))::
         get( null, get_full_name(),"dma_allocator", dma_allocator) == 0)
       `uvm_error("DMA_ERROR", "can not locate DMA allocator")

     dma_allocator.is_local = 1;
         
     for (int i = 0; i < 4; i++) begin
       dma_channel my_dma_channel;

       bit[4:0] item;
       bit      allocated;
       if(dma_allocator.request_item(eo_policy, my_dma_channel)) begin
         `uvm_info("DMA alloc", $sformatf("allocated item %0d", eo_policy.item), UVM_MEDIUM)
         allocated_channels.push_back(my_dma_channel);
       end
       else
         `uvm_error("DMA_ERROR", "can not allocate channel")
     end

     dma_allocator.release_all_items();
     allocated_channels.delete();
     /*foreach (allocated_channels[j]) begin
       `uvm_info("II", "going to release item", UVM_LOW)
       dma_allocator.release_item(allocated_channels[j]);
     end
     */
     if (starting_phase != null) starting_phase.drop_objection(this);
   endtask
endclass


class test extends uvm_test;

   `uvm_component_utils(test)

   uvm_sequencer sqr;
   uvm_seq_item_pull_port#(uvm_sequence_item) seq_item_port;
  
   function new(string name, uvm_component parent = null);
      super.new(name, parent);
   endfunction

   virtual function void build_phase(uvm_phase phase);
      sqr = new("sqr", this);
      seq_item_port = new("seq_item_port", this);

      uvm_config_db#(uvm_object_wrapper)::set(this, "sqr.main_phase",
                                              "default_sequence",
                                              top_seq::get_type());

   endfunction
   
   function void connect_phase(uvm_phase phase);
      seq_item_port.connect(sqr.seq_item_export);
   endfunction

  function void start_of_simulation_phase(uvm_phase phase);
    uvm_item_allocator#(dma_channel, bit[4:0]) dma_allocator;
    dma_policy policy;
    
    policy = new;
    dma_allocator = new("dma_allocator", "DMA channel");
    dma_allocator.alloc_policy = policy;
    
    uvm_config_db#(uvm_item_allocator#(dma_channel, bit[4:0]))::
      set(null, "*", "dma_allocator", 
          dma_allocator);
  endfunction

  function void report_phase(uvm_phase phase);
    uvm_report_server svr;
    svr = _global_reporter.get_report_server();
    
    if (svr.get_severity_count(UVM_FATAL) +
        svr.get_severity_count(UVM_ERROR) == 0)
      $write("** UVM TEST PASSED **\n");
    else
      $write("!! UVM TEST FAILED !!\n");
  endfunction
endclass

  initial run_test("test");

endprogram
