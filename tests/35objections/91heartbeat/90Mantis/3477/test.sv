module top;
    import uvm_pkg::*;
    `include "uvm_macros.svh"

    class test extends uvm_test;
        `uvm_component_utils(test)
        uvm_heartbeat hb;
        uvm_callbacks_objection myobj;
        int failed = 0;     

        function new(string name, uvm_component parent);
            super.new(name,parent);
            myobj = new("heartbeat-objection-source");
            hb = new("this-heartbeat", this, myobj);
            hb.add(this);      
        endfunction
        task run_phase(uvm_phase phase);
            uvm_event e = new("e");
            super.run_phase(phase);

            phase.raise_objection(this);
    
            failed = 1;
            hb.start(e);
            failed = 0;
            #1;
            hb.stop();
            hb.start();
            #1;

            phase.drop_objection(this);
        endtask
        function void report_phase(uvm_phase phase);
            super.report_phase(phase);
            $write("** UVM TEST PASSED **\n");
        endfunction
    endclass
  
    initial run_test();
endmodule

