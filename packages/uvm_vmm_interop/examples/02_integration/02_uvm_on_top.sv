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

`define UVM_ON_TOP

`include "uvm_vmm_pkg.sv"

`include "uvm_other.sv"
`include "vmm_other.sv"

//------------------------------------------------------------------------------
//
// Example: UVM on top
//
// This example demonstrates a simple UVM-on-top environment, where UVM controls
// the phasing of UVM and any integrated VMM envs. Unlike the VMM-on-top use
// model, VMM envs integrated in an UVM environment do not require modification,
// i.e. do not require a change to its inheritance and the addition of a call
// to <uvm_build> in the ~build~ phase.
//
//------------------------------------------------------------------------------

//------------------------------------------------------------------------------
//
// Class- wrapped_vmm_env
//
// Wrap a VMM env in an uvm_component, thus making it reusable as a block-level
// component in an UVM environment.
//------------------------------------------------------------------------------

class wrapped_vmm_env extends avt_uvm_vmm_env #(vmm_env_ext);

  `uvm_component_utils(wrapped_vmm_env)

  function new (string name, uvm_component parent=null);
    super.new(name,parent);
  endfunction

endclass


//------------------------------------------------------------------------------
//
// Class- my_uvm_env
//
// Top-level UVM container, which can later be reused as a block-level
// component.
//------------------------------------------------------------------------------

class my_uvm_env extends uvm_comp_ext;

  wrapped_vmm_env subenv;

  `uvm_component_utils(my_uvm_env)

  function new (string name, uvm_component parent=null);
    super.new(name,parent);
  endfunction

  virtual function void build();
    subenv = new("vmm_env",this);
    subenv.auto_stop_request = 1;
  endfunction

endclass

//-------------------------------------------------------------
//
// Example- example_02_uvm_on_top
//
//-------------------------------------------------------------

program example_02_uvm_on_top;

  initial run_test("my_uvm_env");

endprogram

// (inline source)

