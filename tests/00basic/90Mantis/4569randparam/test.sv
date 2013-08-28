//----------------------------------------------------------------------
//   Copyright 2013 Freescale Semiconductor, Inc.
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

program top;

import uvm_pkg::*;
`include "uvm_macros.svh"


class test extends uvm_test;

   `uvm_component_utils(test)

   function new(string name, uvm_component parent = null);
      super.new(name, parent);
   endfunction: new

   virtual task run();
      uvm_top.stop_request();
   endtask: run

   virtual function void report();
     int weight[int];
     int check_weight[int];
     int temp;
     int index;
     int error = 0;
     uvm_dynamic_range_constraint#("RANDINT1") drc  = uvm_dynamic_range_constraint#("RANDINT1")::get_inst() ;
     uvm_dynamic_range_constraint#("RANDINT2") drc2 = uvm_dynamic_range_constraint#("RANDINT2")::get_inst() ;
     uvm_dynamic_range_constraint#("RANDINT3") drc3 = uvm_dynamic_range_constraint#("RANDINT3")::get_inst() ;
     uvm_dynamic_range_constraint#("RANDINT4") drc4 = uvm_dynamic_range_constraint#("RANDINT4")::get_inst() ;
     //set the hardcoded check weight for "0xF:0x10:1; 2:3:2"
     check_weight['hF] = 17;
     check_weight['h10] = 17;
     check_weight[2] = 33;
     check_weight[3] = 33;
     for(int unsigned index = 0; index != 100; ++index)
     begin
       temp = uvm_dynamic_range_constraint#("RANDINT1")::get_rand_value();
       weight[temp]++;
     end
     $write("Statistics for 100 randomizations of constraint RANDINT1:\n");
     if(weight.first(index))
       do
       begin
         $write("  %0d was chosen %0d times\n", index, weight[index]);
         if(weight[index] < check_weight[index] - 5 || weight[index] > check_weight[index] + 5)
         begin
           $write("  %0d was out of the expecting times, [%0d, %0d]", index, check_weight[index]-5, check_weight[index]+5 );
           error = 1;
         end
       end
       while(weight.next(index));

     //check the correctness
     
     if(error)
       $write("\n** UVM TEST FAILED **\n");
     else
       $write("\n** UVM TEST PASSED **\n");
   endfunction: report

endclass: test

initial run_test();

endprogram: top
