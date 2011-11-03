`include "uvm_macros.svh"
 
package test_pkg;
 
   import uvm_pkg::*;
   
class item extends uvm_sequence_item;
   `uvm_object_utils( item );
   
   function new( string name = "" );
      super.new( name );
   endfunction
   
endclass
   
class item_driver extends uvm_driver #( item );
   `uvm_component_utils( item_driver );
   
   function new( string name , uvm_component parent );
      super.new( name , parent );
   endfunction
   
   task run_phase( uvm_phase phase );
      item t;
      bit reset;
      forever begin
         seq_item_port.get_next_item( t );
         `uvm_info("Got" , t.get_full_name() , UVM_MEDIUM );
         #10;
         if (reset == 0) begin
            seq_item_port.item_reset();
            `uvm_info("Reset" , t.get_full_name() , UVM_MEDIUM );
            reset = 1;
         end
         else begin
            seq_item_port.item_done();
            `uvm_info("Done" , t.get_full_name() , UVM_MEDIUM );
         end
      end
   endtask
   
endclass
   
class item_seqA extends uvm_sequence #( item );
   `uvm_object_utils( item_seqA );
   
   function new( string name = "" );
      super.new( name );
   endfunction
   
   task body();
      item t;
      
      t = new("seqA_item");
         
      start_item( t );
      finish_item( t );

      `uvm_error("DO_NOT_UNBLOCK", "item_seqA's item shouldn't have unblocked!")
   endtask
   
   function void do_kill();
      `uvm_info("SEQ_A_KILLED" , get_full_name() , UVM_MEDIUM )
   endfunction
endclass
   
class item_seqB extends uvm_sequence #( item );
   `uvm_object_utils( item_seqB );
   
   function new( string name = "" );
      super.new( name );
   endfunction
   
   task body();
      item t;
      
      t = new("seqB_item");
         
      start_item( t );
      finish_item( t );
   endtask
   
   function void do_kill();
      `uvm_info("SEQ_B_KILLED" , get_full_name() , UVM_MEDIUM )
   endfunction
endclass
   
   
class test extends uvm_test;
   `uvm_component_utils( test );

   uvm_sequencer #( item ) sequencer;
   item_driver driver;
   
   function new( string name , uvm_component parent );
      super.new( name , parent );
   endfunction
   
   function void build_phase( uvm_phase phase );
      sequencer = uvm_sequencer #( item )::type_id::create("sequencer" , this );
      driver = item_driver::type_id::create("driver" , this );

   endfunction
   
   function void connect_phase( uvm_phase phase );
      driver.seq_item_port.connect( sequencer.seq_item_export );
   endfunction
   
   task run_phase( uvm_phase phase );
      item_seqA seqA;
      item_seqB seqB;
      
      phase.raise_objection( this , "started run" );
      
      seqA = item_seqA::type_id::create("item_seqA");
      fork
         seqA.start( sequencer );
      join_none

      #20;

      seqB = item_seqB::type_id::create("item_seqB");
      seqB.start( sequencer );

      seqA.kill();
      
      phase.drop_objection( this , "finished run" );
   endtask
   
   function void phase_started( uvm_phase phase );
      `uvm_info("Phase Started" , phase.get_full_name() , UVM_MEDIUM )
   endfunction
   
   function void phase_ended( uvm_phase phase );
     `uvm_info("Phase Ended" , phase.get_full_name() , UVM_MEDIUM )
   endfunction
   
   function void report();
      uvm_report_server svr;
      svr = _global_reporter.get_report_server();
      
      svr.summarize();

      if (svr.get_severity_count(UVM_FATAL) +
          svr.get_severity_count(UVM_ERROR) == 0)
         $write("** UVM TEST PASSED **\n");
      else
         $write("!! UVM TEST FAILED !!\n");
   endfunction
endclass
   
endpackage
   
   import test_pkg::*;
   import uvm_pkg::*;
   
module top();
   initial run_test();
endmodule 
