import uvm_pkg::*;

`include "uvm_macros.svh"

package P;

import uvm_pkg::*;

class  packet extends uvm_object;
   `uvm_object_utils_begin(packet)
   `uvm_object_utils_end
endclass
endpackage
import P::*;
module top;


class  packet extends uvm_object;
   `uvm_object_utils_begin(packet)
   `uvm_object_utils_end
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
    global_stop_request();
  endtask 
endclass

initial run_test();

endmodule

