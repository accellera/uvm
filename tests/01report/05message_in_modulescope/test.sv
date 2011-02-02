module test;
import uvm_pkg::*;
`include "uvm_macros.svh"

class a extends uvm_object;
    function new(string name="");
        super.new(name);
        `uvm_info("SB","some print",UVM_INFO) 
    endfunction
endclass

initial begin
        a my_a = new();
end
endmodule
