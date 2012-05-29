//---------------------------------------------------------------------- 
//   Copyright 2012 Synopsys, Inc
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

class my_class2 extends uvm_object;

   `uvm_object_utils(my_class2)

   function new(string name = "");
      super.new(name);
   endfunction : new
   
   virtual function bit do_compare(uvm_object rhs, uvm_comparer comparer);
      do_compare = super.do_compare(rhs, comparer);

      do_compare = 0;
//      do_compare &= comparer.compare_field_int("f1", 0, 1, 8);
//      comparer.result++;
      
      return do_compare;
   endfunction

endclass

class my_class1 extends uvm_object;
   rand my_class2 m_obj2;

   `uvm_object_utils_begin(my_class1)
      `uvm_field_object(m_obj2, UVM_ALL_ON)
   `uvm_object_utils_end
   
   function new(string name = "");
      super.new(name);
      m_obj2 = new("m_obj2");
   endfunction : new
endclass


initial
begin
   my_class1 o1 = my_class1::type_id::create("o1");
   my_class1 o2 = my_class1::type_id::create("o2");

   `uvm_info("TEST", "Checking that failing do_compare for sub-object fails parent comparison...", UVM_NONE)
   
   if (o1.compare(o2)) begin
      `uvm_error("TEST", "Objects compared succesfully")
   end

   begin
      uvm_report_server svr;
      svr = _global_reporter.get_report_server();

      if (svr.get_severity_count(UVM_FATAL) +
          svr.get_severity_count(UVM_ERROR) == 0)
         $write("** UVM TEST PASSED **\n");
      else
         $write("!! UVM TEST FAILED !!\n");
   end
end
endmodule
