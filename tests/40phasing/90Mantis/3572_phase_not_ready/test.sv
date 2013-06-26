

`include "uvm_macros.svh"
import uvm_pkg::*;

class test extends uvm_test;
  `uvm_component_utils( test )
  bit been_here = 0;

  function new( string name , uvm_component parent = null );
    super.new( name , parent );
  endfunction

  function void phase_ready_to_end( uvm_phase phase );
    if( phase.is( uvm_post_shutdown_phase::get() ) ) begin
      if( been_here ) return;
      been_here = 1;

      phase.raise_objection( this , "delay post shutdown" );

      fork begin
        #20;
        phase.drop_objection( this , "allow post shutdown" );
      end
      join_none
    end
  endfunction

  function void phase_ended( uvm_phase phase );
    `uvm_info("Phase ended" , phase.get_full_name() , UVM_MEDIUM );
  endfunction

  function void check();
    if ($time == 20)
      $display("*** UVM TEST PASSED ***");
    else
      $display("*** UVM TEST FAILED ***");
  endfunction

endclass

module top;

  initial begin
    run_test("test");
  end
endmodule
