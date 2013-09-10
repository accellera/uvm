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

class my_dynamic_range_constraint extends uvm_dynamic_range_constraint;
  constraint my_constraint
  { value inside {[1:5]};}
endclass: my_dynamic_range_constraint

class rnd_class extends uvm_component;
  rand uvm_dynamic_range_constraint drc1;
  rand uvm_dynamic_range_constraint drc2;
  rand uvm_dynamic_range_constraint drc3;
  `uvm_component_utils_begin(rnd_class)
    `uvm_field_object(drc1, UVM_DEFAULT|UVM_SETSTR|UVM_SETOBJ)
    `uvm_field_object(drc2, UVM_DEFAULT|UVM_SETSTR|UVM_SETOBJ)
    `uvm_field_object(drc3, UVM_DEFAULT|UVM_SETSTR|UVM_SETOBJ)
  `uvm_component_utils_end

//  function new(string name="");
//    super.new(name);
//    drc1 = uvm_dynamic_range_constraint::type_id::create({get_full_name(),".RANDINT1"});
//    drc2 = my_dynamic_range_constraint::type_id::create({get_full_name(),".RANDINT2"});
//    drc3 = uvm_dynamic_range_constraint::type_id::create({get_full_name(),".RANDINT3"});
//  endfunction: new
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction: new

  function void build_phase(uvm_phase phase);
    drc1 = uvm_dynamic_range_constraint::type_id::create("RANDINT1");
    drc2 = uvm_dynamic_range_constraint::type_id::create("RANDINT2");
    drc3 = uvm_dynamic_range_constraint::type_id::create("RANDINT3");
    super.build_phase(phase);
  endfunction
endclass: rnd_class

class test extends uvm_test;
   rnd_class rnd;
   `uvm_component_utils(test)

   function new(string name, uvm_component parent = null);
      super.new(name, parent);
   endfunction: new

   virtual task run();
      uvm_top.stop_request();
   endtask: run

   function void build_phase(uvm_phase phase);
     super.build_phase(phase);
     rnd = rnd_class::type_id::create("top.@us", this);
   endfunction

   virtual function void report();
     int weight[string][int];
     int check_weight[string][int];
     string check_param[3];
     int temp;
     int index;
     int error = 0;
     
     //set the hardcoded check weight for "0xF:0x10:1; 2:3:2"
     check_param[0] = "RANDINT1";
     check_weight["RANDINT1"]['hF] = 17;
     check_weight["RANDINT1"]['h10] = 17;
     check_weight["RANDINT1"][2] = 33;
     check_weight["RANDINT1"][3] = 33;
     //set the hardcoded check weight for "1:5"
     check_param[1] = "RANDINT2";
     check_weight["RANDINT2"][5] = 100;
     //set the hardcoded check weight for "1:4"
     check_param[2] = "RANDINT3";
     check_weight["RANDINT3"][1] = 25;
     check_weight["RANDINT3"][2] = 25;
     check_weight["RANDINT3"][3] = 25;
     check_weight["RANDINT3"][4] = 25;

     for(int unsigned index = 0; index != 100; ++index)
     begin
       void'(rnd.randomize());
       weight["RANDINT1"][rnd.drc1.value]++;
       weight["RANDINT2"][rnd.drc2.value]++;
       weight["RANDINT3"][rnd.drc3.value]++;
     end
     
     foreach(check_param[param_index])
     begin
       string param = check_param[param_index];
       int unsigned u_index;
       $write("\n\nStatistics for 100 randomizations of constraint %s:", param);
       if(weight[param].first(index))
         do
         begin
           $cast(u_index, index);
           $write("\n  %0d was chosen %0d times", u_index, weight[param][index]);
           if(!check_weight[param].exists(index))
           begin
             $write(",out of the expecting times, [0,0]");
             error = 1;
           end
           else if(weight[param][index] < check_weight[param][index] - 15 || weight[param][index] > check_weight[param][index] + 15)
           begin
             $write(",out of the expecting times, [%0d, %0d]", check_weight[param][index]-15, check_weight[param][index]+15 );
             error = 1;
           end
         end
         while(weight[param].next(index));
      end

     //check the correctness
     
     if(error)
       $write("\n** UVM TEST FAILED **\n");
     else
       $write("\n** UVM TEST PASSED **\n");
   endfunction: report

endclass: test

initial run_test();

endprogram: top
