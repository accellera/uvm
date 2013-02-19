//----------------------------------------------------------------------
//   Copyright 2013 Verilab, Inc.
//   All Rights Reserved Worldwide
//
//   Licensed under the Apache License, Version 2.0 (the
//   "License"); you may not use this file except in
//   compliance with the License.  You may obtain a copy of
//   the License at
//
//       http://www.apache.org/licenses/LICENSE-2.0
//
//   Unless required by applicable law or agreed to in
//   writing, software distributed under the License is
//   distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
//   CONDITIONS OF ANY KIND, either express or implied.  See
//   the License for the specific language governing
//   permissions and limitations under the License.
//----------------------------------------------------------------------

`include "uvm_macros.svh"

//`define DEBUG_3895

`define phase_tracker(PHASE, DELAY=50) \
   task PHASE``_phase(uvm_phase phase); \
      phase.raise_objection(this); \
      phase_times[`"start_of_``PHASE``_phase`"] = $time; \
      `uvm_info(`"PHASE`", "START", UVM_NONE) \
      #DELAY `uvm_info(`"PHASE`", "END", UVM_NONE) \
      phase_times[`"end_of_``PHASE``_phase`"] = $time; \
      phase.drop_objection(this); \
    endtask \

module test;

  import uvm_pkg::*;

  typedef struct {string a; string b;} equivalent_phase;

  equivalent_phase equivalent_phases[$];

  typedef class custom_phase_comp;
  `uvm_user_task_phase(end_with, custom_phase_comp, test_)
  `uvm_user_task_phase(start_with, custom_phase_comp, test_)
  `uvm_user_task_phase(start_with_before, custom_phase_comp, test_)
  `uvm_user_task_phase(after_end_with, custom_phase_comp, test_)
  `uvm_user_task_phase(start_with_end_with, custom_phase_comp, test_)


  class tracker_comp extends uvm_component;
    time phase_times[string];

    function new(string name, uvm_component parent);
      super.new(name, parent);
    endfunction

    `phase_tracker(pre_reset)
    `phase_tracker(reset)
    `phase_tracker(post_reset)
    `phase_tracker(pre_configure)
    `phase_tracker(configure)
    `phase_tracker(post_configure)
    `phase_tracker(pre_main)
    `phase_tracker(main)
    `phase_tracker(post_main)
    `phase_tracker(pre_shutdown)
    `phase_tracker(shutdown)
    `phase_tracker(post_shutdown)

  endclass

  class custom_phase_comp extends uvm_component;
    time phase_times[string];

    function new(string name, uvm_component parent);
      super.new(name, parent);
    endfunction

    `phase_tracker(pre_reset)
    `phase_tracker(reset)
    `phase_tracker(post_reset)
    `phase_tracker(pre_configure)
    `phase_tracker(configure)
    `phase_tracker(end_with, 1000)
    `phase_tracker(start_with, 250)
    `phase_tracker(start_with_before, 300)
    `phase_tracker(after_end_with, 500)
    `phase_tracker(start_with_end_with, 2000)
    `phase_tracker(post_configure)
    `phase_tracker(pre_main)
    `phase_tracker(main)
    `phase_tracker(post_main)
    `phase_tracker(pre_shutdown)
    `phase_tracker(shutdown)
    `phase_tracker(post_shutdown)

    function void connect();
      `uvm_info("CONNECT", "connect phase setting domain", UVM_NONE)
      set_domain(uvm_domain::get_uvm_domain());
    endfunction

    // The component needs to override teh set_phase_schedule to add
    // the new schedule.
    function void define_domain(uvm_domain domain);
      uvm_phase schedule;
      schedule = domain.find_by_name("uvm_sched");

      schedule.add(test_end_with_phase::get(), .end_with_phase(uvm_pre_main_phase::get()));
      equivalent_phases.push_back(equivalent_phase'{a:"end_of_end_with_phase", b:"start_of_main_phase"});

      schedule.add(test_start_with_phase::get(), .start_with_phase(uvm_main_phase::get()));
      equivalent_phases.push_back(equivalent_phase'{a:"start_of_start_with_phase", b:"start_of_main_phase"});

      schedule.add(test_start_with_before_phase::get(),
        .start_with_phase(uvm_pre_configure_phase::get()), .before_phase(uvm_pre_main_phase::get()));
      equivalent_phases.push_back(equivalent_phase'{a:"start_of_start_with_before_phase", b:"start_of_pre_configure_phase"});
      equivalent_phases.push_back(equivalent_phase'{a:"end_of_start_with_before_phase", b:"start_of_pre_main_phase"});

      schedule.add(test_after_end_with_phase::get(),
        .after_phase(uvm_post_main_phase::get()), .end_with_phase(uvm_pre_shutdown_phase::get()));
      equivalent_phases.push_back(equivalent_phase'{a:"start_of_after_end_with_phase", b:"end_of_post_main_phase"});
      equivalent_phases.push_back(equivalent_phase'{a:"end_of_after_end_with_phase", b:"start_of_shutdown_phase"});

      schedule.add(test_start_with_end_with_phase::get(),
        .start_with_phase(uvm_post_main_phase::get()), .end_with_phase(uvm_shutdown_phase::get()));
      equivalent_phases.push_back(equivalent_phase'{a:"start_of_start_with_end_with_phase", b:"start_of_post_main_phase"});
      equivalent_phases.push_back(equivalent_phase'{a:"end_of_start_with_end_with_phase", b:"start_of_post_shutdown_phase"});
    endfunction
  endclass


  class test_env extends uvm_env;
    time phase_times[string];
    tracker_comp tc;
    custom_phase_comp cpc;

    function new(string name, uvm_component parent);
      super.new(name, parent);
      tc = new("tc", this);
      cpc = new("cpc", this);
    endfunction

    `phase_tracker(pre_reset)
    `phase_tracker(reset)
    `phase_tracker(post_reset)
    `phase_tracker(pre_configure)
    `phase_tracker(configure)
    `phase_tracker(post_configure)
    `phase_tracker(pre_main)
    `phase_tracker(main)
    `phase_tracker(post_main)
    `phase_tracker(pre_shutdown)
    `phase_tracker(shutdown)
    `phase_tracker(post_shutdown)

  endclass


  class test extends uvm_test;
    test_env te;
    `uvm_component_utils(test)
    function new(string name, uvm_component parent);
      super.new(name, parent);
      te = new("te", this);
    endfunction

    function void show_sorted_list(ref time times[string]);
      string sorted_times[time] = '{default: ""};
      string new_val;
      time timestep;

      foreach (times[phase]) begin
        $display(phase, times[phase]);
        sorted_times[times[phase]] = {phase, " ", sorted_times[times[phase]]};
      end

      foreach (sorted_times[times]) begin
        $display($sformatf("%3d %s", times, sorted_times[times]));
      end
    endfunction



    function bit check_times;

`ifdef DEBUG_3895
      `uvm_info("RESULTS", "tracker_comp", UVM_NONE)
      show_sorted_list(te.tc.phase_times);
      `uvm_info("RESULTS", "custom_phase_comp", UVM_NONE)
      show_sorted_list(te.cpc.phase_times);
`endif

      foreach(equivalent_phases[i]) begin
        $display($sformatf("%d %s %s", i, equivalent_phases[i].a, equivalent_phases[i].b));
        if (te.cpc.phase_times[equivalent_phases[i].a] != te.cpc.phase_times[equivalent_phases[i].b]) begin
          `uvm_error("RESULTS", $sformatf("%s does not match %s", equivalent_phases[i].a, equivalent_phases[i].b))
        end
      end
      return 1;
    endfunction


    function void report_phase(uvm_phase phase);
      bit passed = 0;
      passed = check_times();
      if(passed) begin
        $display("*** UVM TEST PASSED ***");
      end else begin
        $display("*** UVM TEST FAILED ***");
      end
    endfunction
  endclass


  initial run_test();

endmodule