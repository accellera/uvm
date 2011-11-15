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

import uvm_pkg::*;

`include "uvm_macros.svh"

package P;

import uvm_pkg::*;

class  packet extends uvm_object;
   `uvm_object_utils_begin(packet)
   `uvm_object_utils_end

  function new(string name="packet");
     super.new(name);
  endfunction

endclass
endpackage
import P::*;
module top;


class  packet extends uvm_object;
   `uvm_object_utils_begin(packet)
   `uvm_object_utils_end

  function new(string name="packet");
     super.new(name);
  endfunction

endclass

packet p1;
P::packet p2;

class test extends uvm_test;
  `uvm_new_func
  `uvm_component_utils(test)
  task run;
    p1 = new;
    p2 = new;

    //If it gets to here, it is okay because it didn't have a null pointer
    $display("*** UVM TEST PASSED ***");
  endtask 
endclass

initial run_test();

endmodule

