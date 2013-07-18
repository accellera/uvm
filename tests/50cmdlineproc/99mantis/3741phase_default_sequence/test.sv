module test_mod();

    import uvm_pkg::*;
`include "uvm_macros.svh"

class my_seq extends uvm_sequence#();

    `uvm_object_utils(my_seq)

    function new(string name="unnamed-my_seq");
        super.new(name);
    endfunction : new

    virtual task body();
        $display("*** UVM TEST PASSED ***");
    endtask : body

endclass : my_seq // my_seq

class test extends uvm_component;

    uvm_sequencer#() seqr;

    `uvm_component_utils(test)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        seqr = uvm_sequencer#()::type_id::create("seqr", this);
    endfunction : build_phase

endclass : test

initial begin
    run_test();
end

endmodule // test_mod

