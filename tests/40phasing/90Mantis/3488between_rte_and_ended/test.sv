import uvm_pkg::*;
`include "uvm_macros.svh"

class test extends uvm_component;

   `uvm_component_utils(test)

   bit post_shutdown_r2e = 0;
   bit post_shutdown_ended = 0;
   bit failed = 0;
   
   function new(string _name, uvm_component _parent);
      super.new(_name, _parent);
   endfunction : new

   virtual function void start_of_simulation_phase(uvm_phase phase);
      `uvm_info(get_type_name(), "inside of start_of_simulation_phase()", UVM_NONE)
   endfunction : start_of_simulation_phase
   
   virtual task run_phase(uvm_phase phase);
      `uvm_info(get_type_name(), "raising objection in run phase", UVM_NONE)
      phase.raise_objection(this);
      `uvm_info(get_type_name(), "delaying run...", UVM_NONE)
      #10;
      `uvm_info(get_type_name(), "dropping objection in run phase", UVM_NONE)
      phase.drop_objection(this);
   endtask : run_phase

   virtual task post_shutdown_phase(uvm_phase phase);
      `uvm_info(get_type_name(), "raising objection in post_shutdown_phase", UVM_NONE)
      phase.raise_objection(this);
      `uvm_info(get_type_name(), "delaying post_shutdown_phase", UVM_NONE)
      #1;
      `uvm_info(get_type_name(), "dropping objection in post_shutdown_phase", UVM_NONE)
      phase.drop_objection(this);
      uvm_wait_for_nba_region();
      `uvm_info(get_type_name(), "still in post_shutdown_phase...", UVM_NONE)
      post_shutdown_r2e = 1;
      `uvm_info(get_type_name(), "raising objection #2 in post_shutdown_phase", UVM_NONE)
      phase.raise_objection(this);
      `uvm_info(get_type_name(), "delaying post_shutdown_phase", UVM_NONE)
      #20;
      `uvm_info(get_type_name(), "dropping objection #2 in post_shutdown_phase", UVM_NONE)
      post_shutdown_ended = 1;
      phase.drop_objection(this);
   endtask : post_shutdown_phase
      
   virtual function void report_phase(uvm_phase phase);
      if (post_shutdown_r2e == 0) begin
         `uvm_error(get_type_name(), "failed to extend between post_shutdown.ready_to_end and post_shutdown.ended")
         failed = 1;
      end
      if (post_shutdown_ended == 0) begin
         `uvm_error(get_type_name(), "objection between post_shutdown.ready_to_end and post_shutdown.ended was ignored")
         failed = 1;
      end
   endfunction : report_phase

   virtual function void final_phase(uvm_phase phase);
      if(failed) $display("*** UVM TEST FAILED ***");
      else $display("*** UVM TEST PASSED ***");
   endfunction : final_phase
   
   virtual function void phase_started(uvm_phase phase);
      `uvm_info("PHASE", $psprintf("phase_started(%s)", phase.get_full_name()), UVM_NONE)
   endfunction : phase_started
   virtual function void phase_ended(uvm_phase phase);
      `uvm_info("PHASE", $psprintf("phase_ended(%s)", phase.get_full_name()), UVM_NONE)
   endfunction : phase_ended
   virtual function void phase_ready_to_end(uvm_phase phase);
      `uvm_info("PHASE", $psprintf("phase_ready_to_end(%s)", phase.get_full_name()), UVM_NONE)
   endfunction : phase_ready_to_end

endclass : test

module runner;
   import uvm_pkg::*;
      
      
   initial
     uvm_pkg::run_test();
endmodule : runner
