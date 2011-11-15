//---------------------------------------------------------------------- 
//   Copyright 2011 Mentor Graphics Corporation
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


// Tests random stability of the phasing mechanism
//
// UVM phases, function or task, always start within their own
// thread.

// All component phase callbacks within a given FUNCTION phase share the
// same parent process. Random stability was lost in subsequent component
// callbacks whenever the previous callback created a new object, used $urandom,
// or forked a new process, relative to a previous runs.  New objects/processes
// advance the seed of the parent process, which affects the starting
// seed for the subsequent function phase call.

// TASK phases would lose stability if additional components were added
// to the component hierarchy. New components mean new processes forked
// for each task phase of each new component. Later components, therefore,
// start with a different seed.

// All phases would lose stability when a new phase is inserted into
// the phase graph. This case is not tested here.

module top;

import uvm_pkg::*;
`include "uvm_macros.svh"

class data;
  rand int a;
endclass
 
bit func;
bit destable;
int FILE;

class base extends uvm_component;

   `uvm_component_utils(base)

   function new(string name = "base", uvm_component parent = null);
      super.new(name, parent);
   endfunction

   // for task phases, component c1 or c2's phase task will be called
   // first. Which it is is undefined. We ensure that c2 randomization
   // when present with destable is active, is executed first so as
   // to destabilize the random seed of the phase mechanism.
   // The first component called isn't interesting as
   // there is no previous component that may upset a phase process' random seed.
   // It is the 2nd component (if there is a 2nd) that is interesting.

   task randomize_task(uvm_phase phase);
      data d;
        

      if (get_name() == "c2")
        return;
      else
        #0;

      if (func)
        return;

      phase.raise_objection(this); 
      d = new;
      void'(d.randomize());
      $fdisplay(FILE,"%8h %s",d.a,{get_full_name(),".",phase.get_name()});
      #1;
 
      phase.drop_objection(this);
  
   endtask

   // for function phases, component c1's will always get called before c2
   // (this is implementation knowledge, given children are stored in assoc
   // array by name (alphabetical order), and function phases involve
   // no forking of processes as do task phases)

   function void randomize_func(string phname);
      data d;
      static byte toggle;
      if (!func)
        return;
      d = new;
      assert(d.randomize());
      if (get_name() == "c2")
        $fdisplay(FILE,"%8h %s",/*d.a*/$urandom(),{get_full_name(),".",phname});
      if (destable) begin
        case (toggle)
          0: d = new;
          1: void'($urandom());
          2: fork #0; join_none
        endcase
      end
      toggle = (toggle+1) % 3;
   endfunction

   //function void phase_started            (uvm_phase phase); randomize_func({phase.get_name(),".started"}); endfunction 
   //function void phase_ended              (uvm_phase phase); randomize_func({phase.get_name(),".ended"}); endfunction  

   function void build_phase              (uvm_phase phase); randomize_func(phase.get_name()); endfunction 
   function void connect_phase            (uvm_phase phase); randomize_func(phase.get_name()); endfunction 
   function void end_of_elaboration_phase (uvm_phase phase); randomize_func(phase.get_name()); endfunction 
   function void start_of_simulation_phase(uvm_phase phase); randomize_func(phase.get_name()); endfunction 
   function void extract_phase            (uvm_phase phase); randomize_func(phase.get_name()); endfunction
   function void check_phase              (uvm_phase phase); randomize_func(phase.get_name()); endfunction
   function void report_phase             (uvm_phase phase); randomize_func(phase.get_name()); endfunction
   function void final_phase              (uvm_phase phase); randomize_func(phase.get_name()); endfunction
   
   task run_phase           (uvm_phase phase);       randomize_task(phase);   #50; endtask 
   task pre_reset_phase     (uvm_phase phase);       randomize_task(phase);   #50; endtask 
   task reset_phase         (uvm_phase phase);       randomize_task(phase);   #50; endtask 
   task post_reset_phase    (uvm_phase phase);       randomize_task(phase);   #50; endtask 
   task pre_configure_phase (uvm_phase phase);       randomize_task(phase);   #50; endtask 
   task configure_phase     (uvm_phase phase);       randomize_task(phase);   #50; endtask 
   task post_configure_phase(uvm_phase phase);       randomize_task(phase);   #50; endtask 
   task pre_main_phase      (uvm_phase phase);       randomize_task(phase);   #50; endtask 
   task main_phase          (uvm_phase phase);       randomize_task(phase);   #50; endtask 
   task post_main_phase     (uvm_phase phase);       randomize_task(phase);   #50; endtask 
   task pre_shutdown_phase  (uvm_phase phase);       randomize_task(phase);   #50; endtask 
   task shutdown_phase      (uvm_phase phase);       randomize_task(phase);   #50; endtask 
   task post_shutdown_phase (uvm_phase phase);       randomize_task(phase);   #50; endtask 

endclass 
   

class test extends uvm_component;
   `uvm_component_utils(test)
   base c1;
   base c2;
   function new(string name = "my_comp", uvm_component parent = null);
      data d;
      super.new(name, parent);
      c1 = new("c1",this);

      if ($test$plusargs("DESTABLE")) begin
        destable = 1;
        $write("DESTABILIZING ");
        //d = new;
      end
      else 
        $write("STABLE ");

      if ($test$plusargs("FUNC")) begin
        func = 1;
        $display("FUNCS");
        //d = new;
      end
      else
        $display("TASKS");

      if (func || destable) begin
        c2 = new("c2",this);
      end
   endfunction
endclass


initial
begin
   process p;
   string file,first;
   uvm_top.finish_on_completion = 0;
   p = process::self();
   p.srandom(1000);

   if (!$value$plusargs("FILE=%s",file)) begin
     $display("FATAL: no +FILE plusarg");
     $finish;
   end
   $display("Writing output to log ",file);
   FILE = $fopen(file,"w");

   run_test("test");

   $fclose(FILE);

end

endmodule

