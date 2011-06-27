`include "uvm_macros.svh"

module test;

import uvm_pkg::*;

typedef class my_env;

`uvm_user_task_phase(main2, my_env, my_)

class my_env extends uvm_env;

   `uvm_component_utils(my_env)

   int main2_count = 0;

   static local bit m_add_phases = m_do_add_phases();
   static local function bit m_do_add_phases();
      uvm_phase sched = uvm_domain::get_uvm_schedule();
      sched.add(my_main2_phase::get(),
                .after_phase(uvm_post_reset_phase::get()),
                .before_phase(uvm_post_shutdown_phase::get()));
   endfunction

   function new(string name, uvm_component parent);
      super.new(name,parent);
   endfunction : new

   task pre_reset_phase(uvm_phase phase);
      `uvm_info(phase.get_name(), "Started...", UVM_LOW)
      phase.raise_objection(this);
      #30;
      phase.drop_objection(this);
      `uvm_info(phase.get_name(), "Ended...", UVM_LOW)
   endtask
   
   task reset_phase(uvm_phase phase);
      `uvm_info(phase.get_name(), "Started...", UVM_LOW)
      phase.raise_objection(this);
      #30;
      phase.drop_objection(this);
      `uvm_info(phase.get_name(), "Ended...", UVM_LOW)
   endtask
   
   task post_reset_phase(uvm_phase phase);
      `uvm_info(phase.get_name(), "Started...", UVM_LOW)
      phase.raise_objection(this);
      #30;
      phase.drop_objection(this);
      `uvm_info(phase.get_name(), "Ended...", UVM_LOW)
   endtask
   
   task pre_configure_phase(uvm_phase phase);
      `uvm_info(phase.get_name(), "Started...", UVM_LOW)
      phase.raise_objection(this);
      #30;
      phase.drop_objection(this);
      `uvm_info(phase.get_name(), "Ended...", UVM_LOW)
   endtask
   
   task main_phase(uvm_phase phase);
      `uvm_info(phase.get_name(), "Started...", UVM_LOW)
      phase.raise_objection(this);
      #15;
      if (phase.get_run_count() == 1)
      begin
         `uvm_info("Test", "Jumping to reset...", UVM_NONE)
         phase.jump(uvm_reset_phase::get());
      end
      #15;
      phase.drop_objection(this);
      `uvm_info(phase.get_name(), "Ended...", UVM_LOW)
   endtask : main_phase

   // main2 phase runs longer
   task main2_phase(uvm_phase phase);
      `uvm_info(phase.get_name(), "Started...", UVM_LOW)
      phase.raise_objection(this);
      main2_count++;
      #500;
      phase.drop_objection(this);
      `uvm_info(phase.get_name(), "Ended...", UVM_LOW)
   endtask : main2_phase

   task shutdown_phase(uvm_phase phase);
      `uvm_info(phase.get_name(), "Started...", UVM_LOW)
      phase.raise_objection(this);
      #30;
      phase.drop_objection(this);
      `uvm_info(phase.get_name(), "Ended...", UVM_LOW)
   endtask
   
   task post_shutdown_phase(uvm_phase phase);
      `uvm_info(phase.get_name(), "Started...", UVM_LOW)
      phase.raise_objection(this);
      #30;
      phase.drop_objection(this);
      `uvm_info(phase.get_name(), "Ended...", UVM_LOW)
   endtask
   
   function void report_phase(uvm_phase phase);
      if (main2_count != 2) begin
         `uvm_error("test", $sformatf("main2 phase ran %0d times instead of 2",
                                      main2_count))
      end
   endfunction

endclass : my_env


class test extends uvm_test;

   my_env mc;

   `uvm_component_utils(test)

   function new(string name, uvm_component parent);
      super.new(name,parent);
   endfunction : new

   function void build_phase(uvm_phase phase);
      mc = my_env::type_id::create("mc", this);
   endfunction

   function void final_phase(uvm_phase phase);
      uvm_report_server svr;
      svr = _global_reporter.get_report_server();

      if (svr.get_severity_count(UVM_FATAL) +
          svr.get_severity_count(UVM_ERROR) == 0)
         $write("** UVM TEST PASSED **\n");
      else
         $write("!! UVM TEST FAILED !!\n");
   endfunction
   
endclass : test

initial run_test("test");

endmodule

