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

// This test demonstrates a user defined phase into the 
// uvm shedule but only using set_phase_imp.
//
// This test puts a hard_reset phase between the pre_reset and
// reset phases.
//
// There are two components, one which uses the new phase and
// one which doesn't.
//
// Component                        Phase        Start time    End time
// ---------------------------------------------------------------------
//  uvm_test_top.me.mc (mycomp)     reset           0            30
//  uvm_test_top.me.oc (othercomp)  reset           0            40
//  uvm_test_top.me.mc (mycomp)     post_reset     40            70
//  uvm_test_top.me.mc (ohtercomp)  post_reset     40            60
//  uvm_test_top.me.mc (mycomp)     my_cfg         70            100
//  uvm_test_top.me.mc (ohtercomp)  configure      100           130
//  uvm_test_top.me.mc (ohtercomp)  configure      100           140


`include "uvm_macros.svh"


package mypkg;
  import uvm_pkg::*;

  // Pseudo interface class for phase schedule just for
  // defining the schedule. When SV supports interface classes,
  // this would be an interface class.
  class my_component extends uvm_component;
    `uvm_component_utils(my_component)
   virtual task cfg_phase(uvm_phase phase);
  endtask
    function new(string name, uvm_component parent);
      super.new(name,parent);
    endfunction
  endclass

  `uvm_user_task_phase(cfg,my_component,my_)


  // default phase imp that doesn't do anything
  class default_imp extends uvm_task_phase;
    function new(string name);
      super.new(name);
      set_name(name);
    endfunction
  endclass
  default_imp cfg_imp;

  // method for adding the phase to some specific domain
  function automatic uvm_phase set_my_schedule();

    uvm_phase new_phase;
    uvm_phase my_sched;
    uvm_root top  = uvm_root::get();
    my_sched = top.find_phase_schedule("uvm_pkg::uvm", "*");

    if(my_sched == null) begin
      top.set_phase_domain("uvm");
      my_sched = top.find_phase_schedule("uvm_pkg::uvm", "*");
    end
    assert(my_sched != null);

    //Add the new phase if needed
    new_phase = my_sched.find_schedule("my_cfg");
    if(new_phase == null) begin
      my_sched.add_phase(my_cfg_ph,
        .after_phase(my_sched.find_schedule("pre_configure")),
        .before_phase(my_sched.find_schedule("configure")));
    end
    return my_sched;
  endfunction

  uvm_phase my_sched = set_my_schedule();
endpackage

module test;
  import uvm_pkg::*;
  import mypkg::*;

  // Some other component that will use the new schedule
  class othercomp extends uvm_component;
    time start_reset, start_pre_configure, start_configure;
    time end_reset, end_pre_configure, end_configure;

    time delay = 40ns;

    function new(string name, uvm_component parent);
      super.new(name,parent);
      set_phase_domain("uvm");
    endfunction
    task reset_phase(uvm_phase phase);
      start_reset = $time;
      `uvm_info("RST", "IN RESET", UVM_NONE)
      #delay `uvm_info("RST", "END RESET", UVM_NONE)
      end_reset = $time;
    endtask
    task pre_configure_phase(uvm_phase phase);
      start_pre_configure = $time;
      `uvm_info("PRECFG", "IN PRECFG", UVM_NONE)
      #(60 - delay) `uvm_info("PRECFG", "END PRECFG", UVM_NONE)
      end_pre_configure = $time;
    endtask
    task configure_phase(uvm_phase phase);
      start_configure = $time;
      `uvm_info("CFG", "IN CONFIGURE", UVM_NONE)
      #delay `uvm_info("CFG", "END CONFIGURE", UVM_NONE)
      end_configure = $time;
    endtask
  endclass


  // Some component that will use the new schedule

  class mycomp extends my_component;
    time start_reset, start_pre_configure, start_configure;
    time end_reset, end_pre_configure, end_configure;
    time start_my_cfg;
    time end_my_cfg;

    time delay = 30ns;

    function new(string name, uvm_component parent);
      super.new(name,parent);
    endfunction
    task cfg_phase(uvm_phase phase);
      start_my_cfg = $time;
      `uvm_info("MYCFG", "IN MY CFG", UVM_NONE)
      #delay `uvm_info("MYCFG", "END MY CFG", UVM_NONE)
      end_my_cfg = $time;
    endtask
    task reset_phase(uvm_phase phase);
      start_reset = $time;
      `uvm_info("RST", "IN RESET", UVM_NONE)
      #delay `uvm_info("RST", "END RESET", UVM_NONE)
      end_reset = $time;
    endtask
    task pre_configure_phase(uvm_phase phase);
      start_pre_configure = $time;
      `uvm_info("PRECFG", "IN PRECFG", UVM_NONE)
      #(60 - delay) `uvm_info("PRECFG", "END PRECFG", UVM_NONE)
      end_pre_configure = $time;
    endtask
    task configure_phase(uvm_phase phase);
      start_configure = $time;
      `uvm_info("CFG", "IN CONFIGURE", UVM_NONE)
      #delay `uvm_info("CFG", "END CONFIGURE", UVM_NONE)
      end_configure = $time;
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
    function void connect_phase(uvm_phase phase);
      my_cfg_phase mc_imp = new;
      mc.set_phase_imp(cfg_imp,my_cfg_ph);
    endfunction
    task run_phase(uvm_phase phase);
      `uvm_info("RUN", "In run", UVM_NONE)
      #10 `uvm_info("RUN", "Done with run", UVM_NONE)
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
    function void report_phase(uvm_phase phase);
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
      if(me.mc.start_pre_configure != 40 || 
         me.oc.start_pre_configure != 40) begin
        $display("*** UVM TEST FAILED , pre_configure started at time %t/%0t instead of 0", me.mc.start_pre_configure, me.oc.start_pre_configure);
        return;
      end
      if(me.mc.end_pre_configure != 70 || 
         me.oc.end_pre_configure != 60) begin
        $display("*** UVM TEST FAILED , pre_configure end times (%0t/%0t)", me.mc.end_pre_configure, me.oc.end_pre_configure);
        return;
      end
      if(me.mc.start_my_cfg != 70) begin 
        $display("*** UVM TEST FAILED , my_cfg started at time %t instead of 0", me.mc.start_my_cfg);
        return;
      end
      if(me.mc.end_my_cfg != 100 ) begin
        $display("*** UVM TEST FAILED , my_cfg end times (%0t)", me.mc.end_my_cfg);
        return;
      end
      if(me.mc.start_configure != 100 || 
         me.oc.start_configure != 100) begin
        $display("*** UVM TEST FAILED , configure started at time %t/%0t instead of 0", me.mc.start_configure, me.oc.start_configure);
        return;
      end
      if(me.mc.end_configure != 130 || 
         me.oc.end_configure != 140) begin
        $display("*** UVM TEST FAILED , configure end times (%0t/%0t)", me.mc.end_configure, me.oc.end_configure);
        return;
      end
      $display("**** UVM TEST PASSED *****");

    endfunction
  endclass

  initial run_test(); 
endmodule

