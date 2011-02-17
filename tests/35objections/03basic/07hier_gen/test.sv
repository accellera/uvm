//
//------------------------------------------------------------------------------
//   Copyright 2011 (Authors)
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

`include "uvm_macros.svh"
import uvm_pkg::*;

`define NUM_LOOPS 10
`define MAX_WIDTH 3
`define MAX_DEPTH 4

int objection_counter = 0;

class bus_trans extends uvm_sequence_item;
  int a;
endclass

class my_comp extends uvm_component;

  `uvm_component_utils(my_comp)

  my_comp my_comp_h[`MAX_WIDTH];
  int depth;

  function new(string name="", uvm_component parent);
    super.new(name, parent);
    if (parent == null)
      depth=1;
    else begin
     my_comp tmp;
     if($cast(tmp,parent))
       depth = tmp.depth + 1;
    end
    if (depth <= `MAX_DEPTH)
      for (int i = 0; i < `MAX_WIDTH; i++)
        my_comp_h[i] = new ($sformatf("comp_%0d_%0d",depth,i), this);
  endfunction

  task run();
    for (int i = 0; i < `NUM_LOOPS; i++) begin
      objection_counter++;
      uvm_test_done.raise_objection(this);
      #1;
      uvm_test_done.drop_objection(this);
      #1;
    end
    #100;
    uvm_top.stop_request();
  endtask

  function void report();
    if (depth==1)
      $display("Max depth=%0d  Max width=%0d  Objections=%0d", 
               `MAX_DEPTH, `MAX_WIDTH, objection_counter);
  endfunction
endclass

class test extends uvm_component;
  int counter = 0;
  my_comp comp;

  `uvm_component_utils(test)
  function new(string name="", uvm_component parent);
    super.new(name, parent);
    comp = new("comp", this);
  endfunction
  function void raised (uvm_objection objection, 
    uvm_object source_obj, string description, int count);
    if (objection == uvm_test_done) begin
      counter++;
    end
  endfunction
  function void dropped (uvm_objection objection, 
    uvm_object source_obj, string description, int count);
    if (objection == uvm_test_done) begin
      counter++;
    end
  endfunction
  task run;
    uvm_test_done.raise_objection(this);
    #20;
    uvm_test_done.drop_objection(this);
  endtask
  function void report();
    //Run time for all components is `NUM_LOOPS * 2
    if($time != 20)
      $display("** UVM TEST FAILED time: %0t expected: %0t **", $time, 20);
  
`ifdef FLAT
    if(counter != 0) begin
      $display("** UVM TEST FAILED count: %0d expected: 2 **", counter);
      return;
    end
`else 
    if(counter != (objection_counter*2 + 2)) begin
      $display("** UVM TEST FAILED count: %0d expected: %0d **", counter, objection_counter*2 + 2);
      return;
    end
`endif
    $display("** UVM TEST PASSED with count: %0d **", counter);
  endfunction 
endclass

module top;
  initial begin
    `ifdef FLAT
    uvm_test_done.hier_mode(0);
    `endif
    run_test();
  end
endmodule
