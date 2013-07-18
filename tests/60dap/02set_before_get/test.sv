// 
//------------------------------------------------------------------------------
//   Copyright 2013      NVIDIA Corporation
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

module test_mod();

   import uvm_pkg::*;
`include "uvm_macros.svh"

class catcher extends uvm_report_catcher;
   int seen = 0;

   function new(string name);
      super.new(name);
   endfunction : new
   
   virtual function action_e catch();

      if (get_severity() == UVM_ERROR) begin
         seen++;
         set_severity(UVM_INFO);
      end

      return THROW;
   endfunction : catch
endclass // catcher
   
class test extends uvm_component;

   uvm_set_before_get_dap#(int) idap;
   catcher ctchr;
   
   `uvm_component_utils_begin(test)
      `uvm_field_object(idap, UVM_DEFAULT)
   `uvm_component_utils_end

   function new(string name, uvm_component parent);
      super.new(name, parent);
      ctchr = new("ctchr");
   endfunction : new

   virtual task run_phase(uvm_phase phase);
      bit failed;
      int value;
      uvm_set_before_get_dap#(int) idap2;
      
      // Basics 
      idap = uvm_set_before_get_dap#(int)::type_id::create("idap", this);
      idap.set(1);
      idap.set(2);
      if (idap.get() != 2) begin
         failed = 1;
         `uvm_error("ERR_A", 
                    $sformatf("Expected '2', got '%0d'", idap.get()))
      end

      idap.print();

      idap2 = uvm_set_before_get_dap#(int)::type_id::create("idap2", this);
      // Would error, so we're catching it...
      uvm_report_cb::add(null, ctchr);
      value = idap2.get();
      if (ctchr.seen != 1) begin
         failed = 1;
         `uvm_error("ERR_B",
                    $sformatf("Expected error on 'get()'!"))
      end
      // Won't error...
      if (idap2.try_get(value)) begin
         failed = 1;
         `uvm_error("ERR_C",
                    $sformatf("Expected 'try_get()' to fail!"))
      end

      // Should error...
      $cast(idap2, idap.clone());

      if (ctchr.seen != 2) begin
         failed = 1;
         `uvm_error("ERR_D",
                    $sformatf("Expected error on 'clone'!"))
      end
          
      if (failed)
        $display("*** UVM TEST FAILED ***");
      else
        $display("*** UVM TEST PASSED ***");
      
   endtask // run_phase

endclass // test

initial begin
   run_test();
end
   
endmodule // test_mod

   

      
      
      
