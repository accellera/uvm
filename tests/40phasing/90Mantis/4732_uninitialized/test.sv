//---------------------------------------------------------------------- 
//   Copyright 2010 Synopsys, Inc. 
//   Copyright 2010-2011 Mentor Graphics Corporation
//   Copyright 2011 Cadence Design Systems, Inc.
//   Copyright 2013 NVIDIA Corporation
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


program top;

import uvm_pkg::*;
`include "uvm_macros.svh"

class my_phase extends uvm_task_phase;

   function new(string name="unnamed-my_phase");
      super.new(name);
   endfunction : new

endclass : my_phase
   
class my_phase_cb extends uvm_phase_cb;

   uvm_phase_state states[uvm_phase_state];
   bit seen[uvm_phase_state];
   bit fail;
   
   function new(string name="unnamed-my_phase_cb");
      super.new(name);
      states[UVM_PHASE_DORMANT] = UVM_PHASE_UNINITIALIZED;
      states[UVM_PHASE_SCHEDULED] = UVM_PHASE_DORMANT;
      states[UVM_PHASE_SYNCING] = UVM_PHASE_SCHEDULED;
      states[UVM_PHASE_STARTED] = UVM_PHASE_SYNCING;
      states[UVM_PHASE_EXECUTING] = UVM_PHASE_STARTED;
      states[UVM_PHASE_READY_TO_END] = UVM_PHASE_EXECUTING;
      states[UVM_PHASE_ENDED] = UVM_PHASE_READY_TO_END;
      states[UVM_PHASE_CLEANUP] = UVM_PHASE_ENDED;
      states[UVM_PHASE_DONE] = UVM_PHASE_CLEANUP;

      seen[UVM_PHASE_DORMANT] = 0;
      seen[UVM_PHASE_SCHEDULED] = 0;
      seen[UVM_PHASE_SYNCING] = 0;
      seen[UVM_PHASE_STARTED] = 0;
      seen[UVM_PHASE_EXECUTING] = 0;
      seen[UVM_PHASE_READY_TO_END] = 0;
      seen[UVM_PHASE_ENDED] = 0;
      seen[UVM_PHASE_CLEANUP] = 0;
      seen[UVM_PHASE_DONE] = 0;

      fail = 0;
   endfunction : new

   virtual function void phase_state_change(uvm_phase phase,
                                            uvm_phase_state_change change);
      uvm_phase_state state = change.get_state();
      uvm_phase_state prev_state = change.get_prev_state();
      `uvm_info("CHANGE", 
                $sformatf("saw %s go from %s to %s",
                          phase.get_name(),
                          prev_state.name(),
                          state.name()),
                UVM_NONE)
      if (phase.get_name == "ph") begin
         if (states[state] != prev_state) begin
            fail = 1;
            `uvm_error("FAIL", $sformatf("expected to see %s:%s but saw %s:%s",
                                         states[state].name(),
                                         state.name(),
                                         prev_state.name(),
                                         state.name()))
         end
         seen[state] = 1;
      end
   endfunction : phase_state_change

   function void check();
      foreach (seen[idx])
        if (seen[idx] == 0) begin
           fail = 1;
           `uvm_error("FAIL", $sformatf("Never saw %s", idx.name()))
        end

      if (!fail)
        `uvm_info("PASS", "*** UVM TEST PASSED ***", UVM_NONE)
   endfunction : check

endclass : my_phase_cb

class test extends uvm_test;

   my_phase ph;
   my_phase_cb cb;
   
   `uvm_component_utils(test)

   function new(string name = "my_comp", uvm_component parent = null);
      uvm_phase runtime_schedule;
      super.new(name, parent);
      runtime_schedule = uvm_domain::get_uvm_schedule();
      ph = new("ph");

      cb = new("cb");
      uvm_phase_cb_pool::add(null, cb);
      
      runtime_schedule.add(ph, .with_phase(uvm_main_phase::get()));
   endfunction

   task main_phase(uvm_phase phase);
      phase.raise_objection(this);
      #10;
      phase.drop_objection(this);
   endtask : main_phase
   
   function void final_phase(uvm_phase phase);
      cb.check();
   endfunction : final_phase
   
endclass

initial
begin
   run_test();
end

endprogram
