program top;

import uvm_pkg::*;
`include "uvm_macros.svh"


class test extends uvm_test;

   `uvm_component_utils(test)
   
//   rand int unsigned value;
//   constraint value_range
//   {
//     value dist {[1:2] := 2, [2:3] :=1};
//   };

   function new(string name, uvm_component parent = null);
      super.new(name, parent);
   endfunction

   virtual task run();
      uvm_top.stop_request();
   endtask

   virtual function void report();
     int weight[20];
     int temp;
     uvm_dynamic_range_constraint#("RANDINT1") drc = uvm_dynamic_range_constraint#("RANDINT1")::get_inst() ;
     uvm_dynamic_range_constraint#("RANDINT2") drc2 = uvm_dynamic_range_constraint#("RANDINT2")::get_inst() ;
     uvm_dynamic_range_constraint#("RANDINT3") drc3 = uvm_dynamic_range_constraint#("RANDINT3")::get_inst() ;
     for(int index =0; index < 100; index ++)
     begin
//       randomize();
//       temp = value;
//       drc.randomize();
//       temp = drc.value;
       temp = uvm_dynamic_range_constraint#("RANDINT1")::get_rand_value();
       weight[temp]++;
     end
     for(int index=1; index < 20; index ++)
     begin
       $write("weight of %0d is %0d\n", index, weight[index]);
     end  
     
     $write("** UVM TEST PASSED **\n");
   endfunction
endclass


initial
  begin
     run_test();
  end

endprogram
