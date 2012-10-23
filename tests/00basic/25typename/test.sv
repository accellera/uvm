
`include "uvm_macros.svh"
import uvm_pkg::*;


class xyz; endclass

class bar #(type T=int); endclass

class foo #(type T=int, int W=24) extends T; endclass

class test extends uvm_test;
  `uvm_component_utils(test)
  test list[2];

  function new(string name, uvm_component parent=null);
    string typename,exp_typename;
    foo #(bar#(xyz),88) f;
    bar #(xyz) b;
     
    super.new(name,parent);

    f = new;
    b = f;

     
    typename = `uvm_typename(f);

    $display("\nGOLD-FILE-START\n",typename,"\nGOLD-FILE-END\n");
  endfunction
endclass

module top;
  initial
    run_test();
endmodule

