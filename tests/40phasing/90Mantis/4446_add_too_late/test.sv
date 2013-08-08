module test_mod();

   import uvm_pkg::*;
`include "uvm_macros.svh"

class simple_phase extends uvm_task_phase();

   local static simple_phase m_imp[string];
   
   function new(string name="simple");
      super.new(name);
   endfunction : new

   static function simple_phase get(string name);
      if (!m_imp.exists(name))
        m_imp[name] = new(name);
      return m_imp[name];
   endfunction : get
   
endclass : simple_phase
   
class test extends uvm_test;

   `uvm_component_utils(test)
   
   function new(string name, uvm_component parent);
      super.new(name, parent);
   endfunction : new

   virtual task main_phase(uvm_phase phase);
      // We're going to add a phase to the schedule,
      // but add 'with' pre_main (already done), so it should get marked
      // DONE.
      uvm_phase node;
      uvm_phase_state state;
      uvm_phase sch = phase.get_schedule();

      node = sch.find(uvm_pre_main_phase::get());
      sch.add(simple_phase::get("simple1"),
              .with_phase(node));

      node = sch.find(simple_phase::get("simple1"));
      state = node.get_state();
      if (state != UVM_PHASE_DONE)
        `uvm_fatal("FAIL1",
                   $sformatf("simple1 is in the '%s' state!", state.name()))
      
      // We're going to add a phase to the schedule,
      // but add 'with' main (currently running), so it should get marked
      // DONE
      sch.add(simple_phase::get("simple2"),
              .with_phase(phase));

      node = sch.find(simple_phase::get("simple2"));
      state = node.get_state();
      if (state != UVM_PHASE_DONE)
        `uvm_fatal("FAIL1",
                   $sformatf("simple2 is in the '%s' state!", state.name()))
      
   endtask : main_phase

   virtual function void report_phase(uvm_phase phase);
      `uvm_info("PASS",
                "*** UVM TEST PASSED ***",
                UVM_NONE)
   endfunction : report_phase

endclass // test

   initial
     run_test();

endmodule // test_mod

   
      
      
   
