//----------------------------------------------------------------------
//   Copyright 2007-2011 Mentor Graphics Corporation
//   Copyright 2007-2011 Cadence Design Systems, Inc.
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

  typedef class my_cfg_phase;
  // Pseudo interface class for phase schedule just for
  // defining the schedule. When SV supports interface classes,
  // this would be an interface class.
  class my_component extends uvm_component;
    `uvm_component_utils(my_component)
  
    virtual task cfg_phase(uvm_phase phase);
    endtask
  
    static uvm_phase my_sched;

    function void define_domain(uvm_domain domain);
  
      uvm_phase cfg_phase;
      uvm_phase sched;
      uvm_root top  = uvm_root::get();

      // adds the "uvm_sched" to 'domain', if not already added,
      // then adds 'domain' to the master graph, if not already added
      super.define_domain(domain);

      sched = domain.find_by_name("uvm_sched");
      if (sched == null)
        `uvm_fatal("NO_UVM_SCHED",
          {"Could not find required 'uvm_sched' in domain ",domain.get_name()})

      // Add my cfg phase to the "uvm_sched" in given domain
      cfg_phase = sched.find(my_cfg_phase::get());
      if(cfg_phase == null)
        sched.add(my_cfg_phase::get(),
                  .after_phase(sched.find(uvm_pre_configure_phase::get())),
                  .before_phase(sched.find(uvm_configure_phase::get())));
    endfunction

    function new(string name, uvm_component parent);
      super.new(name,parent);
    endfunction
  
  endclass
  
  `uvm_user_task_phase(cfg,my_component,my_)
  
  int my_cfg_phase_imp_called;
  
  class my_cfg_phase_imp extends my_cfg_phase;
    function new(string name);
      super.new(name);
    endfunction
    virtual task exec_task(uvm_component comp, uvm_phase phase);
      my_component mycomp;
      if ($cast(mycomp,comp))
        my_cfg_phase_imp_called++;
      super.exec_task(comp,phase);
    endtask
  endclass
  
  my_cfg_phase_imp cfg_imp = new("my_cfg_imp_override");

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
    endfunction
    task reset_phase(uvm_phase phase);
      phase.raise_objection(this);
      start_reset = $time;
      `uvm_info("RST", "IN RESET", UVM_NONE)
      #delay `uvm_info("RST", "END RESET", UVM_NONE)
      end_reset = $time;
      phase.drop_objection(this);
    endtask
    task pre_configure_phase(uvm_phase phase);
      phase.raise_objection(this);
      start_pre_configure = $time;
      `uvm_info("PRECFG", "IN PRECFG", UVM_NONE)
      #(60 - delay) `uvm_info("PRECFG", "END PRECFG", UVM_NONE)
      end_pre_configure = $time;
      phase.drop_objection(this);
    endtask
    task configure_phase(uvm_phase phase);
      phase.raise_objection(this);
      start_configure = $time;
      `uvm_info("CFG", "IN CONFIGURE", UVM_NONE)
      #delay `uvm_info("CFG", "END CONFIGURE", UVM_NONE)
      end_configure = $time;
      phase.drop_objection(this);
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
      phase.raise_objection(this);
      start_my_cfg = $time;
      `uvm_info("MYCFG", "IN MY CFG", UVM_NONE)
      #delay `uvm_info("MYCFG", "END MY CFG", UVM_NONE)
      end_my_cfg = $time;
      phase.drop_objection(this);
    endtask
    task reset_phase(uvm_phase phase);
      phase.raise_objection(this);
      start_reset = $time;
      `uvm_info("RST", "IN RESET", UVM_NONE)
      #delay `uvm_info("RST", "END RESET", UVM_NONE)
      end_reset = $time;
      phase.drop_objection(this);
    endtask
    task pre_configure_phase(uvm_phase phase);
      phase.raise_objection(this);
      start_pre_configure = $time;
      `uvm_info("PRECFG", "IN PRECFG", UVM_NONE)
      #(60 - delay) `uvm_info("PRECFG", "END PRECFG", UVM_NONE)
      end_pre_configure = $time;
      phase.drop_objection(this);
    endtask
    task configure_phase(uvm_phase phase);
      phase.raise_objection(this);
      start_configure = $time;
      `uvm_info("CFG", "IN CONFIGURE", UVM_NONE)
      #delay `uvm_info("CFG", "END CONFIGURE", UVM_NONE)
      end_configure = $time;
      phase.drop_objection(this);
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
`ifdef UVM_USE_P_FORMAT
      $display("cfg_imp=%p",cfg_imp);
`endif
      mc.set_phase_imp(my_cfg_phase::get(),cfg_imp);
      mc.set_domain(uvm_domain::get_uvm_domain());
    endfunction
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
      if (my_cfg_phase_imp_called != 1) begin
        $display("*** UVM TEST FAILED , the my_cfg_phase_imp override was used %0d times instead of expected 1",my_cfg_phase_imp_called);
      end
      $display("**** UVM TEST PASSED *****");

    endfunction
  endclass

  initial run_test(); 
endmodule

