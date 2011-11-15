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

module top;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  class header extends uvm_object;
    rand int addr, data, size;
    `uvm_object_utils_begin(header)
       `uvm_field_int(addr, UVM_DEFAULT)
       `uvm_field_int(data, UVM_DEFAULT)
       `uvm_field_int(size, UVM_DEFAULT)
    `uvm_object_utils_end

  function new(string name="header");
     super.new(name);
  endfunction

  endclass

  class data extends uvm_object;
    rand header hdr;
    rand byte payload[];
    `uvm_object_utils_begin(data)
       `uvm_field_object(hdr, UVM_DEFAULT)
       `uvm_field_array_int(payload, UVM_DEFAULT)
    `uvm_object_utils_end

  function new(string name="data");
     super.new(name);
  endfunction

  endclass

  class test extends uvm_component;
    `uvm_component_utils(test)
    function new(string name, uvm_component parent);
      super.new(name,parent);
    endfunction

    task run;
      data d1, d2;
      d1 = new; d1.set_name("d1");
      d1.hdr = new;

      void'(d1.randomize());
      $cast(d2, d1.clone());

      d2.hdr = null;

      if(d1.compare(d2)) begin
        uvm_report_error("FAILURE", "**** UVM TEST FAILED  (objects compared as equal) ****");
        return;
      end
      uvm_report_info("SUCCESS", "**** UVM TEST PASSED ****", UVM_NONE);
    endtask
  endclass

  initial run_test();
endmodule
