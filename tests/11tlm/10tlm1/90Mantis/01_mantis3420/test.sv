module test;
    import uvm_pkg::*;
`include "uvm_macros.svh"

    `uvm_non_blocking_transport_imp_decl(_foo)

    class test extends uvm_component;
        uvm_nonblocking_transport_imp_foo#(uvm_object, uvm_object, test) foo;
        `uvm_component_utils(test)
        function new(string name="", uvm_component parent=null);
            super.new(name,parent);
            foo = new("comp",this); 
        endfunction
        
        function bit nb_transport_foo( input uvm_object req_arg, output uvm_object rsp_arg); 
        endfunction
        
        function void report();
            `uvm_info("TLM","UVM TEST PASSED",UVM_INFO)
        endfunction
    endclass
    
    initial begin
        run_test(); 
    end
endmodule
