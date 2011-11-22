
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

     
    typename = uvm_type_utils#(foo#(bar#(xyz),88))::typename(f);

    // filter out spaces?

    `ifdef QUESTA
    exp_typename = "class foo #(class bar #(class xyz), 88)";
    `endif

    `ifdef VCS
    exp_typename = "class $unit::foo#(class $unit::bar#(class $unit::xyz),88)";
    `endif

    `ifdef INCA
    exp_typename = "class foo #(class bar #(class xyz), 88)";
    `endif

    $display("$typename output is '%s'", typename);
    if (typename == exp_typename)
      $display("** UVM TEST PASSED **");
    else begin
      `uvm_error("BAD_TYPENAME",{"Expected '",exp_typename,"', got '",typename,"'"})
      $display("** UVM TEST FAILED **");
    end

  endfunction
endclass

module top;
  initial
    run_test();
endmodule

