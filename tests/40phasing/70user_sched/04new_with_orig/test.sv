//----------------------------------------------------------------------
//   Copyright 2007-2010 Mentor Graphics, Corp.
//   Copyright 2007-2010 Cadence Design Systems, Inc.
//   Copyright 2010 Synopsys, Inc.
//   Copyright 2010 Cisco Systems, Inc.
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

// This test demonstrates an added user-defined phase. The specific 
// user-defined phase in this case is inserted between reset and post_reset.
//
// There are two different component types, mycomp and stdcomp. 
// The phase schedule is myreset->mymain->myshutdown. The timing
// of the phasing is:
//
// Component                        Phase        Start time    End time
// ---------------------------------------------------------------------
//  uvm_test_top.me.scsd (stdcomp)    reset       0            40
//  uvm_test_top.me.scmd (stdcomp)    reset       0            40
//  uvm_test_top.me.mc   (mycomp)     reset       0            30
//  uvm_test_top.me.mc   (mycomp)     reset2      40           70
//  uvm_test_top.me.scsd (stdcomp)    main        40           60
//  uvm_test_top.me.scmd (stdcomp)    main        70           90
//  uvm_test_top.me.mc   (mycomp)     main        70           100
//  uvm_test_top.me.scmd (stdcomp)    shutdown    60           100
//  uvm_test_top.me.scsd (stdcomp)    shutdown    100          140
//  uvm_test_top.me.mc   (mycomp)     shutdown    100          130


`include "uvm_macros.svh"

// Macro for creating a phase that calls a phase implementation
// task for a specific component type which implements. The implemenation
// has to be a parameterized type parameterized to a component type which
// has the phase implementation as part of this. The alternative would be
// to explicitly call set_phase_imp in each component ctor.

`define my_task_phase(PHASE) \
   class ``PHASE``_phase#(type T=my_component) extends uvm_task_phase; \
     task exec_task(uvm_component comp, uvm_phase phase); \
       T mycomp; \
       if($cast(mycomp, comp)) begin \
         mycomp.``PHASE (uvm_phase phase); \
       end \
     endtask \
     function new(string name); \
       super.new(`"PHASE`"); \
       set_name(`"PHASE`"); \
     endfunction \
     static ``PHASE``_phase#(T) m_inst = get(); \
     static function ``PHASE``_phase#(T) get(); \
       if(m_inst == null) begin \
         m_inst = new(`"PHASE`"); \
       end \
       return m_inst; \
     endfunction \
   endclass \

////////////////////////////////////////////
// add new phase, e.g. myreset2
package mypkg;
  import uvm_pkg::*;

  // Pseudo interface class for phase schedule just for
  // defining the schedule. When SV supports interface classes,
  // this would be an interface class.
  virtual class my_component;
    pure virtual task myreset2(uvm_phase phase);
  endclass

  // Create the parameterized class definitions for:
  // myreset2_phase#(T).
  `my_task_phase(myreset2)

endpackage
/////////////////////////////////////////////



module test;
  import uvm_pkg::*;
  import mypkg::*;

  // Some component that will use the new schedule
  class mycomp extends uvm_component;
    uvm_phase my_sched;

    // this code here only for self-checking purpose
    time phase_times[$] ;
    function bit compare_phase_times( time actual_times[$] ) ;
      if (phase_times.size != actual_times.size) begin
        $display(get_name(),": phase_times.size ",phase_times.size," actual_times.size ",actual_times.size);
        return 0 ;
      end
      foreach ( phase_times [i] )
        if (actual_times[i] != phase_times[i]) begin
        $display(get_name(),": i ",i," phase_time[i] ",phase_times[i]," actual_times[i] ",actual_times[i]);
          return 0 ;
        end
      return 1 ;
    endfunction

    function new(string name, uvm_component parent);
      super.new(name,parent);
      set_phase_domain("mydomain"); //choose some name other than standard "uvm" or the phase modifications will affect all standard components
    endfunction


    // The component needs to override the set_phase_schedule to add
    // the new schedule.
    function void set_phase_schedule(string domain_name);
      uvm_phase new_phase;
      super.set_phase_schedule(domain_name) ; // use built-in schedule as a base
      my_sched = find_phase_schedule("uvm_pkg::uvm",domain_name) ; // get built-in schedule
      assert(my_sched != null); // check nothing has gone horribly wrong

      new_phase = my_sched.find_schedule("myreset2"); // if another component has added it, just use it...
      if (new_phase == null) begin // ... otherwise, add it here
        my_sched.add_phase(myreset2_phase#(mycomp)::get(), //myreset2 from pkg above
          .after_phase(my_sched.find_schedule("reset")), // put it after reset phase
          .before_phase(my_sched.find_schedule("post_reset"))); // and before post_reset
      end

      // enforce one domain per component per schedule.
      if (find_phase_schedule("mypkg::mycomp","*"))
        delete_phase_schedule(find_phase_schedule("mypkg::mycomp","*"));
      add_phase_schedule(my_sched, domain_name);
    endfunction

    // component can implement standard phases ...
    task reset_phase(uvm_phase phase);
      phase_times.push_back($time) ; // for self-checking only
      `uvm_info("RST", "IN STD RESET", UVM_NONE)
      #30 `uvm_info("RST", "END STD RESET", UVM_NONE)
    endtask
    task main_phase(uvm_phase phase);
      phase_times.push_back($time) ; // for self-checking only
      `uvm_info("MAIN", "IN STD MAIN", UVM_NONE)
      #30 `uvm_info("MAIN", "END STD MAIN", UVM_NONE)
    endtask
    task shutdown_phase(uvm_phase phase);
      phase_times.push_back($time) ; // for self-checking only
      `uvm_info("SHTDWN", "IN STD SHUTDOWN", UVM_NONE)
      #30 `uvm_info("SHTDWN", "END STD SHUTDOWN", UVM_NONE)
    endtask

    // ... and also new phase
    task myreset2(uvm_phase phase);
      phase_times.push_back($time) ; // for self-checking only
      `uvm_info("RST2", "IN MY RESET2", UVM_NONE)
      #30 `uvm_info("RST2", "END MY RESET2", UVM_NONE)
    endtask
  endclass

  // Another component that only uses the standard phases for contrast
  class stdcomp extends uvm_component;
    function new(string name, uvm_component parent);
      super.new(name,parent);
      set_phase_domain("uvm");  // should not be necessary once domain membership is built-in
    endfunction

    // this code here only for self-checking purpose
    time phase_times[$] ;
    function bit compare_phase_times( time actual_times[$] ) ;
      if (phase_times.size != actual_times.size) begin
        $display(get_name(),": phase_times.size ",phase_times.size," actual_times.size ",actual_times.size);
        return 0 ;
      end
      foreach ( phase_times [i] )
        if (actual_times[i] != phase_times[i]) begin
        $display(get_name(),": i ",i," phase_times[i] ",phase_times[i]," actual_times[i] ",actual_times[i]);
          return 0 ;
        end
      return 1 ;
    endfunction
    
    // component can implement one or more of the phase methods
    task reset_phase(uvm_phase phase);
      phase_times.push_back($time) ; // for self-checking only
      `uvm_info("RST", "IN STD RESET", UVM_NONE)
      #40 `uvm_info("RST", "END STD RESET", UVM_NONE)
    endtask
    task main_phase(uvm_phase phase);
      phase_times.push_back($time) ; // for self-checking only
      `uvm_info("MAIN", "IN STD MAIN", UVM_NONE)
      #20 `uvm_info("MAIN", "END STD MAIN", UVM_NONE)
    endtask
    task shutdown_phase(uvm_phase phase);
      phase_times.push_back($time) ; // for self-checking only
      `uvm_info("SHTDWN", "IN STD SHUTDOWN", UVM_NONE)
      #40 `uvm_info("SHTDWN", "END STD SHUTDOWN", UVM_NONE)
    endtask

    // this task will not be called automatically unless the component is in a 
    // domain that uses the corresponding phase; it is included here only to
    // illustrate that components run all the phases in their domain; it is
    // not expected that a standard component would implement a user-defined
    // phase
    task myreset2(uvm_phase phase);
      phase_times.push_back($time) ; // for self-checking only
      `uvm_info("RST2", "IN MY RESET2", UVM_NONE)
      #30 `uvm_info("RST2", "END MY RESET2", UVM_NONE)
    endtask
  endclass

  // Normal environment, adds one of the new-phase-aware components, 
  // one of the standard components in the standard domain, and one 
  // of the standandar components in the phase-aware domain.
  class myenv extends uvm_component;
    mycomp mc; //my phase-aware component
    stdcomp scsd; // non-phase-aware component in standard uvm domain
    stdcomp scmd; // non-phase-aware component in domain with mc
    function new(string name, uvm_component parent);
      super.new(name,parent);
      mc = new("mc", this);
      scsd = new("scsd", this);
      scmd = new("scmd", this);
      scmd.set_phase_domain("mydomain"); //switch domain for this instance
    endfunction
    function bit check_times() ;
      time mc_times[$], scsd_times[$], scmd_times[$];

      mc_times.push_back(0); 
      mc_times.push_back(40); 
      mc_times.push_back(70); 
      mc_times.push_back(100);

      scsd_times.push_back(0);
      scsd_times.push_back(40);
      scsd_times.push_back(60);

      scmd_times.push_back(0);
      scmd_times.push_back(70);
      scmd_times.push_back(100);

      if (!mc.compare_phase_times(mc_times)) return 1 ;
      if (!scsd.compare_phase_times(scsd_times)) return 1 ;
      if (!scmd.compare_phase_times(scmd_times)) return 1 ;
      return 0 ;
    endfunction
    task run_phase(uvm_phase phase);
      `uvm_info("RUN", "In run", UVM_NONE)
      #10 `uvm_info("RUN", "Done with run", UVM_NONE)
    endtask
  endclass

  // Normal test that contains just the one env.
  class test extends uvm_component;
    myenv me;
    bit failed = 0 ;
    `uvm_component_utils(test)
    function new(string name, uvm_component parent);
      super.new(name,parent);
      me = new("me", this);
    endfunction

    function void report_phase(uvm_phase phase);
      failed += me.check_times() ;
      if(failed) $display("*** UVM TEST FAILED ***");
      else $display("*** UVM TEST PASSED ***");
    endfunction
  endclass

  initial run_test(); 

endmodule
