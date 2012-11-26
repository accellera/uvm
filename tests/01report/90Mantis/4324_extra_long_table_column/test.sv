//---------------------------------------------------------------------- 
//   Copyright 2012 Cadence Inc
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

module test;
  import uvm_pkg::*;
  `include "uvm_macros.svh"


  class myobject extends uvm_sequence_item;
    string s;
     int   i;
     

    `uvm_object_utils_begin(myobject)
      `uvm_field_string(s, UVM_DEFAULT)
      `uvm_field_int(i,UVM_DEFAULT)
    `uvm_object_utils_end

    function new(string name="myobject_inst");
      super.new(name);
       
      s = "1x2";
    endfunction

  endclass
  class test extends uvm_test;
    `uvm_new_func
    `uvm_component_utils(test)
    myobject obj = new("3nnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnn4");

    task run;
       uvm_default_printer.knobs.show_root=1;
       $display("GOLD-FILE-START");
       obj.print();
       $display("GOLD-FILE-END");
    endtask
  endclass

  initial begin
    run_test();
  end

endmodule
