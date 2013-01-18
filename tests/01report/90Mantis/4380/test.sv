//---------------------------------------------------------------------- 
//   Copyright 2013 Cadence Design Systems, Inc. 
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
import uvm_pkg::*;
`include "uvm_macros.svh"
class myitem extends uvm_sequence_item;

    string s;
    `uvm_object_utils_begin(myitem)
        `uvm_field_string( s, UVM_ALL_ON )
    `uvm_object_utils_end
    function new (string name = "myitem");
        super.new(name);
    endfunction

endclass

class myitem2 extends uvm_sequence_item;

    int s;
    `uvm_object_utils_begin(myitem2)
        `uvm_field_int( s, UVM_ALL_ON )
    `uvm_object_utils_end
    function new (string name = "myitem");
        super.new(name);
    endfunction

endclass

module top;
  myitem m=new;
  myitem2 m2=new;
  initial begin
     m.s="aa";
     $display("GOLD-FILE-START");
     $display(m.sprint);
     $display(m2.sprint);
     m.s="aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa";
     $display(m.sprint);
     m.s="aa";
     $display(m.sprint);
     $display(m2.sprint);
     $display("GOLD-FILE-ENDS");
     $display("*** UVM TEST PASSED ***");
  end
endmodule

