//----------------------------------------------------------------------
//   Copyright 2007-2010 Mentor Graphics, Corp.
//   Copyright 2007-2010 Cadence Design Systems, Inc.
//   Copyright 2010 Synopsys, Inc.
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

// This test demonstrates a user defined schedule. The specific user defined
// schedule in this case runs in parallel to the run phase. It does not
// sync to the uvm runtime scheulde, but could be modified to do that.
//
// There are two different component types, mycomp and othercomp. 
// The phase schedule is myreset->mymain->myshutdown. The timing
// of the phasing is:
//
// Component                        Phase        Start time    End time
// ---------------------------------------------------------------------
//  uvm_test_top.me.mc (mycomp)     myreset       0            30
//  uvm_test_top.me.oc (othercomp)  myreset       0            40
//  uvm_test_top.me.mc (mycomp)     mymain        40           70
//  uvm_test_top.me.mc (ohtercomp)  mymain        40           60
//  uvm_test_top.me.mc (mycomp)     myshutdown    70           100
//  uvm_test_top.me.mc (ohtercomp)  myshutdown    70           110


`include "uvm_macros.svh"

// Macro for creating a phase that calls a phase implementation
// task for a specific component type which implements. The implemenation
// has to be a parameterized type parameterized to a component type which
// has the phase implementation as part of this. The alternative would be
// to explicitly call set_phase_imp in each component ctor.

`define my_task_phase(PHASE) \
   class ``PHASE``_phase#(type T=my_component) extends uvm_task_phase; \
     task exec_task(uvm_component comp, uvm_phase_schedule phase); \
       T mycomp; \
       if($cast(mycomp, comp)) begin \
         mycomp.``PHASE ; \
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

package mypkg;
  import uvm_pkg::*;

  // Pseudo interface class for phase schedule just for
  // defining the schedule. When SV supports interface classes,
  // this would be an interface class.
  virtual class my_component;
    pure virtual task myreset;
    pure virtual task mymain;
    pure virtual task myshutdown;
  endclass

  // Create the paramterized class definitions for:
  // myreset_phase#(T), mymain#(T) and myshutdown#(T).

  `my_task_phase(myreset)
  `my_task_phase(mymain)
  `my_task_phase(myshutdown)

  // Parameterized class for creating a schedule for a specific
  // component type. This code gets executed by a derived component's
  // set_phase_schedule function to get the special schedule into
  // the component.
  // 
  // T is the component type. S is a component specific schedule name
  // to keep the different schedules uniquely named.

  class my_schedule#(type T=uvm_component, string S="spec_sched");

    // The base schedule puts new schedule into the master schedule.
    static function uvm_phase_schedule get_my_base_schedule(string domain);
      uvm_phase_schedule common, my_sched;
      uvm_root top;
      top = uvm_root::get();

      // provide a somewhat unique name for the schedule. We are using
      // mypkg::my_sched for the name of the base schedule.
  
      my_sched = top.find_phase_schedule({"mypkg::","my_sched"}, domain);
      if(my_sched != null) return my_sched;
  
      common = top.find_phase_schedule("uvm_pkg::common", "common");
  
      my_sched = new("mypkg::my_sched");
      my_sched.add_phase(myreset_phase::get());
      my_sched.add_phase(mymain_phase::get());
      my_sched.add_phase(myshutdown_phase::get());

      common.add_schedule(my_sched, .with_phase(common.find_schedule("run")));

      //Add to the master schedule
      top.add_phase_schedule(my_sched, domain);
  
      return my_sched;
    endfunction

    // This creates the actual schedule for the particular component type.
    static function uvm_phase_schedule get_my_schedule(string domain);
      uvm_phase_schedule common, my_sched, my_base_sched;
      uvm_root top;
      top = uvm_root::get();
  
      // Check to see if the schedule is already created for the 
      // domain. If so, just return it.
      my_sched = top.find_phase_schedule({"mypkg::",S}, domain);
      if(my_sched != null) return my_sched;
 
      // Get the base schedule so that we can synce to its phases.
      my_base_sched = get_my_base_schedule(domain); 

      // Get the master schedule to insert this schedule in.
      common = top.find_phase_schedule("uvm_pkg::common", "common");

      // Create the new schedule and add its phases with respect to the
      // base schedule.
      my_sched = new({"mypkg::",S});
      my_sched.add_phase(myreset_phase#(T)::get(), .with_phase(my_base_sched.find_schedule("myreset")));
      my_sched.add_phase(mymain_phase#(T)::get(), .with_phase(my_base_sched.find_schedule("mymain")));
      my_sched.add_phase(myshutdown_phase#(T)::get(), .with_phase(my_base_sched.find_schedule("myshutdown")));

      //Add to the master schedule
      common.add_schedule(my_sched, .with_phase(common.find_schedule("run")));
      top.add_phase_schedule(my_sched, domain);

      return my_sched;
    endfunction
  endclass

endpackage

module test;
  import uvm_pkg::*;
  import mypkg::*;

  // Some component that will use the new schedule
  class mycomp extends uvm_component;
    time start_reset, start_main, start_shutdown;
    time end_reset, end_main, end_shutdown;

    uvm_phase_schedule my_sched;
    function new(string name, uvm_component parent);
      super.new(name,parent);
      set_phase_domain("base_domain");
    endfunction

    // The component needs to override teh set_phase_schedule to add
    // the new schedule.
    function void set_phase_schedule(string domain_name);
      my_sched = my_schedule#(mycomp,"mycomp")::get_my_schedule(domain_name);

      // enforce one domain per component per schedule.
      if (find_phase_schedule("my_pkg::mycomp","*"))
        delete_phase_schedule(find_phase_schedule("my_pkg::mycomp","*"));
      add_phase_schedule(my_sched, domain_name);
    endfunction

    task myreset;
      start_reset = $time;
      `uvm_info("RST", "IN MY RESET", UVM_NONE)
      #30 `uvm_info("RST", "END MY RESET", UVM_NONE)
      end_reset = $time;
    endtask
    task mymain;
      start_main = $time;
      `uvm_info("MAIN", "IN MY MAIN", UVM_NONE)
      #30 `uvm_info("MAIN", "END MY MAIN", UVM_NONE)
      end_main = $time;
    endtask
    task myshutdown;
      start_shutdown = $time;
      `uvm_info("SHTDWN", "IN MY SHUTDOWN", UVM_NONE)
      #30 `uvm_info("SHTDWN", "END MY SHUTDOWN", UVM_NONE)
      end_shutdown = $time;
    endtask
  endclass

  // Some other component that will use the new schedule
  class othercomp extends uvm_component;
    time start_reset, start_main, start_shutdown;
    time end_reset, end_main, end_shutdown;

    uvm_phase_schedule my_sched;
    function new(string name, uvm_component parent);
      super.new(name,parent);
      set_phase_domain("base_domain");
    endfunction

    // The component needs to override teh set_phase_schedule to add
    // the new schedule.
    function void set_phase_schedule(string domain_name);
      my_sched = my_schedule#(othercomp,"othercomp")::get_my_schedule(domain_name);
      if (find_phase_schedule("my_pkg::othercomp","*"))
        delete_phase_schedule(find_phase_schedule("my_pkg::othercomp","*"));
      add_phase_schedule(my_sched, domain_name);
    endfunction

    task myreset;
      start_reset = $time;
      `uvm_info("RST", "IN MY RESET", UVM_NONE)
      #40 `uvm_info("RST", "END MY RESET", UVM_NONE)
      end_reset = $time;
    endtask
    task mymain;
      start_main = $time;
      `uvm_info("MAIN", "IN MY MAIN", UVM_NONE)
      #20 `uvm_info("MAIN", "END MY MAIN", UVM_NONE)
      end_main = $time;
    endtask
    task myshutdown;
      start_shutdown = $time;
      `uvm_info("SHTDWN", "IN MY SHUTDOWN", UVM_NONE)
      #40 `uvm_info("SHTDWN", "END MY SHUTDOWN", UVM_NONE)
      end_shutdown = $time;
    endtask
  endclass

  // Normal environment adds the two sub component.
  class myenv extends uvm_component;
    mycomp mc;
    othercomp oc;
    function new(string name, uvm_component parent);
      super.new(name,parent);
      mc = new("mc", this);
      oc = new("oc", this);
    endfunction
    task run;
      `uvm_info("RUN", "In run", UVM_NONE)
      #10 `uvm_info("RUN", "Done with run", UVM_NONE)
//Current global stop integration has an issue here... needs
//to be looked at
`ifdef WORKAROUND
run_ph.phase_done.drop_objection();
`else
    `uvm_info("RUN", "WORKAROUND NOT IN PLACE, THIS WILL FAIL BECAUSE UVM DOESN'T KNOW THERE IS A USE PHASE", UVM_NONE)
`endif
    endtask
  endclass

  // Normal test that contains just the one env.
  class test extends uvm_component;
    myenv me;
    `uvm_component_utils(test)
    function new(string name, uvm_component parent);
      super.new(name,parent);
      me = new("me", this);
    endfunction
    function void report;
      if(me.mc.start_reset != 0 || 
         me.oc.start_reset != 0) begin
        $display("*** UVM TEST FAILED , reset started at time %t/%0t instead of 0", me.mc.start_reset, me.oc.start_reset);
        return;
      end
      if(me.mc.end_reset != 30 || 
         me.oc.end_reset != 40) begin
        $display("*** UVM TEST FAILED , reset end times (%0t/%0t)", me.mc.end_reset, me.oc.end_reset);
        return;
      end
      if(me.mc.start_main != 40 || 
         me.oc.start_main != 40) begin
        $display("*** UVM TEST FAILED , main started at time %t/%0t instead of 0", me.mc.start_main, me.oc.start_main);
        return;
      end
      if(me.mc.end_main != 70 || 
         me.oc.end_main != 60) begin
        $display("*** UVM TEST FAILED , main end times (%0t/%0t)", me.mc.end_main, me.oc.end_main);
        return;
      end
      if(me.mc.start_shutdown != 70 || 
         me.oc.start_shutdown != 70) begin
        $display("*** UVM TEST FAILED , shutdown started at time %t/%0t instead of 0", me.mc.start_shutdown, me.oc.start_shutdown);
        return;
      end
      if(me.mc.end_shutdown != 100 || 
         me.oc.end_shutdown != 110) begin
        $display("*** UVM TEST FAILED , shutdown end times (%0t/%0t)", me.mc.end_shutdown, me.oc.end_shutdown);
        return;
      end
      $display("**** UVM TEST PASSED *****");

    endfunction
  endclass

  initial run_test(); 
endmodule

