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

`define vmm_env_task_phase(NAME) \
  virtual task NAME();  \
    super.NAME(); \
    `vmm_note(log,$psprintf(`"%s NAME begin`",log.get_name())); \
    #10; \
    `vmm_note(log,$psprintf(`"%s NAME end`",log.get_name())); \
  endtask

`define vmm_env_func_phase(NAME) \
  virtual function void NAME();  \
    super.NAME(); \
    `vmm_note(log,$psprintf(`"%s NAME`",log.get_name())); \
  endfunction


//------------------------------------------------------------------------------
//
// Class- my_vmm_env
//
// Implements all the VMM env phase callbacks with display statements to show
// when each phase is executed in a combined UVM / ENV environment.
//
// In a VMM-on-top environment, VMM envs must be modified to call a the
// ~uvm_build~ method during its ~build~ phase.  Calling ~uvm_build~ kicks off
// UVM's build and connect phases for any integrated UVM components.
//
//------------------------------------------------------------------------------

class vmm_env_ext extends `VMM_ENV;

   function new(string name="vmm_env_ext");
     super.new(name);
   endfunction

  `uvm_build

   // Implement each phase native to VMM
  `vmm_env_func_phase(gen_cfg)
  `vmm_env_task_phase(reset_dut)
  `vmm_env_task_phase(cfg_dut)
  `vmm_env_task_phase(start)
  `vmm_env_task_phase(wait_for_end)
  `vmm_env_task_phase(cleanup)
  `vmm_env_task_phase(stop)

  virtual function void build(); 
    `vmm_note(log,$psprintf("%s build begin",log.get_name()));
    super.build();
    // the following is not needed when UVM is on top
    `ifdef VMM_ON_TOP
    `vmm_note(log,$psprintf("%s build calling uvm_build()",log.get_name()));
    uvm_build();
    `endif
    `vmm_note(log,$psprintf("%s build end",log.get_name()));
  endfunction

  virtual task report(); 
    // the following call is not needed when UVM is on top
    `ifdef VMM_ON_TOP
    uvm_report();
    `endif
    `vmm_note(log,$psprintf("%s report begin",log.get_name()));
    #5;
    `vmm_note(log,$psprintf("%s report end",log.get_name()));
    super.report();
  endtask

endclass

