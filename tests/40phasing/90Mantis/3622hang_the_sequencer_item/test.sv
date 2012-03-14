`include "uvm_macros.svh"
 
package test_pkg;
 
   import uvm_pkg::*;
   
class error_catcher extends uvm_report_catcher;
   int unsigned count=0;
   virtual function action_e catch();
      if("SEQREQZMB" != get_id()) return THROW;
      if(get_severity() != UVM_ERROR) return THROW;
      uvm_report_info("ERROR CATCHER", {"From error_catcher catch(): ", get_message()}, UVM_NONE , `uvm_file, `uvm_line );
      count++; 
      return CAUGHT;
   endfunction
endclass

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
      forever begin
         seq_item_port.get_next_item( t );
         `uvm_info("Got" , t.get_full_name() , UVM_NONE );
         #10;
         `uvm_info("Done" , t.get_full_name() , UVM_NONE );
         seq_item_port.item_done();
      end
   endtask
   
endclass
   
class item_seq extends uvm_sequence #( item );
   `uvm_object_utils( item_seq );
   
   function new( string name = "" );
      super.new( name );
   endfunction
   
   task body();
      item t;
      
      for( int i = 0; i < 30; i++ ) begin
         t = new($sformatf("item %0d" , i ) );

         `uvm_info("start_item", $sformatf("calling start_item(%0d)", i), UVM_NONE)
         start_item( t );
         finish_item( t );
      end
   endtask
   
   function void do_kill();
      `uvm_info("Just Killed" , get_full_name() , UVM_NONE )
   endfunction
endclass
   
class test extends uvm_test;
   `uvm_component_utils( test );

   error_catcher ec;
   uvm_sequencer #( item ) sequencer;
   item_driver driver;
   
   function new( string name , uvm_component parent );
      super.new( name , parent );
   endfunction
   
   function void build_phase( uvm_phase phase );
      sequencer = uvm_sequencer #( item )::type_id::create("sequencer" , this );
      driver = item_driver::type_id::create("driver" , this );

      ec = new;
      uvm_report_cb::add(null, ec);
   endfunction
   
   function void connect_phase( uvm_phase phase );
      driver.seq_item_port.connect( sequencer.seq_item_export );
   endfunction
   
   task reset_phase( uvm_phase phase );
      phase.raise_objection( this , "start reset" );
      fork
         begin
            item_seq seq = item_seq::type_id::create("item_seq");
            seq.start( sequencer );
         end
      join_none
      #50;
      phase.drop_objection( this , "finished reset" ); 
   endtask
   
   task main_phase( uvm_phase phase );
      item_seq seq;
      
      phase.raise_objection( this , "started main" );
      
      seq = item_seq::type_id::create("item_seq");
      seq.start( sequencer );
      
      #50;
      phase.drop_objection( this , "finished main" );
   endtask
   
   function void phase_started( uvm_phase phase );
      `uvm_info("Phase Started" , phase.get_full_name() , UVM_NONE )
   endfunction
   
   function void phase_ended( uvm_phase phase );
     `uvm_info("Phase Ended" , phase.get_full_name() , UVM_NONE )
   endfunction
   
   function void report();
      if(ec.count==1)
        $write("** UVM TEST PASSED **\n");
   endfunction
endclass
   
endpackage
   
   import test_pkg::*;
   import uvm_pkg::*;
   
module top();
   initial run_test();
endmodule 
