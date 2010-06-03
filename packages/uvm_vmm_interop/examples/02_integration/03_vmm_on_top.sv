//------------------------------------------------------------------------------
//    Copyright 2008 Mentor Graphics Corporation
//    All Rights Reserved Worldwide
// 
//    Licensed under the Apache License, Version 2.0 (the "License"); you may
//    not use this file except in compliance with the License.  You may obtain
//    a copy of the License at
// 
//        http://www.apache.org/licenses/LICENSE-2.0
// 
//    Unless required by applicable law or agreed to in writing, software
//    distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
//    WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.  See the
//    License for the specific language governing permissions and limitations
//    under the License.
//------------------------------------------------------------------------------

`define VMM_ON_TOP

`include "uvm_vmm_pkg.sv"

`include "uvm_other.sv"
`include "vmm_other.sv"

//------------------------------------------------------------------------------
//
// Example: VMM on top
//
// This example demonstrates a VMM-on-top environment, where the vmm_env
// controls test flow phasing. The VMM use model is fully preserved, including
// user-controlled step-by-step phasing via direct calls to the ~vmm_env~ phase
// methods. 
//
// (inline source)
//------------------------------------------------------------------------------


//------------------------------------------------------------------------------
//
// Class- vmm_env_with_uvm
//
// A vmm_env that contains an UVM child; shows when each UVM and VMM phase is
// executed relative to each other.
//
//------------------------------------------------------------------------------

class vmm_env_with_uvm extends vmm_env_ext;

  function new (string name);
    super.new(name);
  endfunction

  `uvm_build

  uvm_comp_ext uvm_child,uvm_child2; // VMM containing UVM

  virtual function void build();
    `vmm_note(log, $psprintf("subtype build %s begin",log.get_name()));
    super.build();
    uvm_child = uvm_comp_ext::type_id::create({log.get_name(),".uvm_child"},null);
    uvm_child2 = new({log.get_name(),".uvm_child2"});
    `vmm_note(log, $psprintf("subtype build %s calling uvm_build()",log.get_name()));
    uvm_build();
    `vmm_note(log, $psprintf("subtype build %s end",log.get_name()));
  endfunction

endclass


//------------------------------------------------------------------------------
//
// Example- example_03_vmm_on_top
//
// Instantiate the vmm_env subtype, then single-step through each phase.
//
//------------------------------------------------------------------------------

program example_03_vmm_on_top;

  vmm_env_with_uvm e = new("vmm_top");
  vmm_log log        = new("example_03_vmm_on_top","program");

  initial begin
    `vmm_note(log, $psprintf("*** calling env.gen_cfg"));
    e.gen_cfg();
    #100;
    `vmm_note(log, $psprintf("*** calling env.build"));
    e.build();
    #100;
    `vmm_note(log, $psprintf("*** calling env.reset_dut"));
    e.reset_dut();
    #100;
    `vmm_note(log, $psprintf("*** calling env.cfg_dut"));
    e.cfg_dut();
    #100;
    `vmm_note(log, $psprintf("*** calling env.start"));
    e.start();
    #100;
    `vmm_note(log, $psprintf("*** calling env.wait_for_end"));
    e.wait_for_end();
    #100;
    `vmm_note(log, $psprintf("*** calling env.stop"));
    e.stop();
    #100;
    `vmm_note(log, $psprintf("*** calling env.cleanup"));
    e.cleanup();
    #100;
    `vmm_note(log, $psprintf("*** calling env.run"));
    e.run();
    #100 `vmm_note(log, $psprintf("*** after full run"));
  end
endprogram

// (inline source)
