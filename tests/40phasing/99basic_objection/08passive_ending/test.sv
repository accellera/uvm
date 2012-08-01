module test;

   import uvm_pkg::*;
`include "uvm_macros.svh"

   // include the experimental "phase objection" (contains protections and whatnot)
`include "uvm_phase_objection.svh"
   
class wait_sequence extends uvm_sequence;

   // Phase to end on
   uvm_phase_objection ending_phase_objection;

   // bit used to stop stimulus
   bit stop_stim;

   `uvm_object_utils(wait_sequence)

   function new(string name="unnamed-wait_sequence");
      super.new(name);
   endfunction : new

   task body();
      `uvm_info("PULL_BODY", "inside pull body", UVM_NONE)

      fork : body_fork
         begin
            `uvm_info("PULL_WAIT_PH", "waiting for end of phase", UVM_NONE)
            ending_phase_objection.wait_for_cycle();
            `uvm_info("PULL_END_PH", "saw end of phase", UVM_NONE)
            stop_stim = 1;
         end
      join_none : body_fork

      
      `uvm_info("PULL_WAIT_ST", "waiting to stop stimulus", UVM_NONE)
      wait(stop_stim);
      `uvm_info("PULL_END_ST", "ending stimulus", UVM_NONE)
   endtask : body

endclass : wait_sequence
   
              
class cb_sequence extends uvm_sequence;

   // Phase to end on
   uvm_phase_objection ending_phase_objection;

   // Bit to stop stimulus
   bit stop_stim;

   // Callback used to track messages
   uvm_basic_objection_cb#(cb_sequence) cb;

   `uvm_object_utils(cb_sequence)

   function new(string name="unnamed-cb_sequence");
      super.new(name);
   endfunction : new

   task body();
      // Create our callback and register it
      cb = new({get_full_name(), ".cb"});
      cb.set_impl(this);
      uvm_basic_objection_cbs_t::add(ending_phase_objection, cb);

      `uvm_info("PUSH_WAIT_ST", "waiting to stop stimulus", UVM_NONE)
      wait(stop_stim);
      `uvm_info("PUSH_END_ST", "ending stimulus", UVM_NONE)
   endtask : body

   function void objection_notified(uvm_objection_message message);
      // We're using the shallow filter, the only drop we ever see is the
      // 0->N drop, but we need to make sure the phase was active
      if (ending_phase_objection.raise_requested) begin
         if (message.get_action_type() == UVM_OBJECTION_DROPPED) begin
            `uvm_info("CB_END_PH", "saw end of phase", UVM_NONE)
            stop_stim = 1;
            uvm_basic_objection_cbs_t::delete(ending_phase_objection, cb);
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
      ws.ending_phase_objection = our_phase;
      cs = new("cs");
      cs.ending_phase_objection = our_phase;

      fork 
         ws.start(sqr);
         cs.start(sqr);
      join_none

      `uvm_info("TEST", "sending request to start our_phase", UVM_NONE)
      our_phase.request_to_raise(this, "request to start the phase");
      `uvm_info("TEST", "prolonging our_phase...", UVM_NONE)
      our_phase.raise_objection(this, "prolonging");
      #5;
      `uvm_info("TEST", "letting the phase end...", UVM_NONE)
      our_phase.drop_objection(this, "done prolonging");
      #1;

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
