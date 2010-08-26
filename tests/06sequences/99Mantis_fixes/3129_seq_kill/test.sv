`include "stop_started_seq_sv_side.sv"

`include "uvm_macros.svh"

module top;
   import uvm_pkg::*;
   import my_uvc::*;
  
   reg clk;
   initial clk = 0;
   always #10 clk = ~clk;
   

class test extends uvm_env;
   my_uvc_sequencer sequencer0;
   //ml_uvm_seq::ml_uvm_sequencer_stub sequencer_stub;
   my_uvc_driver driver0;
   
   `uvm_component_utils(test)
   
    function new (string name, uvm_component parent);
       super.new(name, parent);
    endfunction : new
   
   virtual function void build();
      super.build();
      set_config_string("sequencer0", "default_sequence", "root_seq");
      sequencer0 = my_uvc_sequencer::type_id::create("sequencer0", this);

      // Instatiate the seqer stub and associate it with the env's actual sequencer.
      //sequencer_stub = ml_uvm_seq::ml_uvm_sequencer_stub::type_id::create("sequencer_stub", this);
      //sequencer_stub.set_sv_seqr(sequencer0);
      
       driver0 = my_uvc_driver::type_id::create("driver0", this);
   endfunction 
   
   virtual function void connect();
      driver0.seq_item_port.connect(sequencer0.seq_item_export);
   endfunction 
   
   function void end_of_elaboration();
      this.print();
   endfunction 
   
   task run();
      #7000;
      global_stop_request();
   endtask
endclass
   
   initial run_test("test");
   
endmodule
