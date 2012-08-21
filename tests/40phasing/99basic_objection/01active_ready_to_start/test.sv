module test;

   import uvm_pkg::*;
`include "uvm_macros.svh"

   // include the experimental "phase objection" (contains protections and whatnot)
`include "uvm_phase_objection.svh"
   
class wait_sequence extends uvm_sequence;

   // Phase to prolong
   uvm_phase_objection prolong_phase_objection;

   // bit used to stop stimulus
   bit stop_stim;

   `uvm_object_utils(wait_sequence)

   function new(string name="unnamed-wait_sequence");
      super.new(name);
   endfunction : new

   task body();
     `uvm_info("PULL_BODY", "inside wait_seq body", UVM_NONE)
     `uvm_info("PULL_WAIT_PH", "waiting for start of phase", UVM_NONE)
     prolong_phase_objection.wait_for_raise_requested_count(0, UVM_GT);
     `uvm_info("PULL_START_PH", "saw request to start phase", UVM_NONE)
       prolong_phase_objection.raise_objection(this, "Prolonging phase");
     `uvm_info("PULL_WAIT_ST", "waiting to stop stimulus", UVM_NONE)
     #100;
      `uvm_info("PULL_END_ST", "ending stimulus", UVM_NONE)
     prolong_phase_objection.drop_objection(this, "Done prolonging phase");
   endtask : body

endclass : wait_sequence
   
              
class cb_sequence extends uvm_sequence;

   // Phase to end on
   uvm_phase_objection prolong_phase_objection;

   // Bit to stop stimulus
   bit prolong_stim;

   // Callback used to track messages
   uvm_basic_objection_cb#(cb_sequence) cb;

   `uvm_object_utils(cb_sequence)

   function new(string name="unnamed-cb_sequence");
      super.new(name);
   endfunction : new

   task body();
     `uvm_info("PUSH_BODY", "inside cb_seq body", UVM_NONE)
     if (prolong_phase_objection.get_raise_requested_count() == 1)
       // prolong_phase has already started
       begin
	 prolong_phase_objection.raise_objection(this, "Prolonging phase");
	 `uvm_info("PUSH_WAIT_ST", "raising objection", UVM_NONE)
       end
     else begin
       // Create our callback and register it
       cb = new({get_full_name(), ".cb"});
       cb.set_impl(this);
       uvm_basic_objection_cbs_t::add(prolong_phase_objection, cb);
     
       `uvm_info("PUSH_WAIT_ST", "prolonging stimulus until callback fires", 
		 UVM_NONE)
       wait(prolong_stim);
     end
     #110;
     `uvm_info("PUSH_WAIT_ST", "ending stimulus", UVM_NONE)
     prolong_phase_objection.drop_objection(this, "Done prolonging phase");
   endtask : body

   function void objection_notified(uvm_objection_message message);
     if (message.get_action_type() == UVM_OBJECTION_RAISE_REQUESTED) begin
       if (prolong_phase_objection.get_raise_requested_count() == 1) begin
         `uvm_info("CB_START_PH", "saw request to start phase", UVM_NONE)
	 prolong_phase_objection.raise_objection(this, "Prolonging phase");
         prolong_stim = 1;
         uvm_basic_objection_cbs_t::delete(prolong_phase_objection, cb);
       end
     end
   endfunction : objection_notified
      
endclass : cb_sequence

class test extends uvm_test;

   wait_sequence ws;
   cb_sequence  cs;
   uvm_sequencer sqr;
   uvm_phase_objection our_phase;

   `uvm_component_utils(test)

   function new(string name="unnamed-test", uvm_component parent);
      super.new(name, parent);
   endfunction : new

   function void build();
      super.build();
      sqr = new("sqr");
   endfunction : build

  task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    
    our_phase = new("our_phase");
    our_phase.m_controller = this;
    
    ws = new("ws");
    ws.prolong_phase_objection = our_phase;
    cs = new("cs");
    cs.prolong_phase_objection = our_phase;
    
    fork 
      ws.start(sqr);
      cs.start(sqr);
    join_none
    
    #1;
    `uvm_info("TEST", "sending request to start our_phase", UVM_NONE)
    our_phase.request_to_raise(this, "request to start the phase");
    uvm_wait_for_nba_region();
    if (our_phase.get_sum() > 0) begin
      `uvm_info("TEST", "saw requests to prolong phase. Waiting for objections to drop", UVM_NONE)
      our_phase.wait_for_sum(0, UVM_EQ);
    end
    else begin
      `uvm_info("TEST", "no one responded to our request, skipping the phase", UVM_NONE)
    end 
      
    uvm_wait_for_nba_region();
    phase.drop_objection(this);
   endtask : run_phase

   function void report();
      uvm_sequence_state_enum ws_state, cs_state;
      ws_state = ws.get_sequence_state();
      cs_state = cs.get_sequence_state();
      if ((ws_state == FINISHED) && (cs_state == FINISHED))
        $display("*** UVM TEST PASSED ***");
      else
        $display("*** UVM TEST FAILED *** - ws.state = '%s', cs.state = '%s'", ws_state.name(), cs_state.name());
   endfunction : report
                              
endclass : test   

initial 
  run_test();
      
endmodule // test
