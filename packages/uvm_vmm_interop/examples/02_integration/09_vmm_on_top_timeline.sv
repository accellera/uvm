//------------------------------------------------------------------------------
//    Copyright 2009-2010 Synopsys Inc
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
  
//------------------------------------------------------------------------------
//
// Example: VMM on top
//
// This example demonstrates a advanced verification using VMM timeline, 
// where VMM controls the phasing of UVM and any integrated VMM timelines.
//
//------------------------------------------------------------------------------

//------------------------------------------------------------------------------
//
// Class- MyEnv
//
// Top-level VMM container, which can later be reused as a block-level
// component.
//------------------------------------------------------------------------------


`ifndef NO_VMM_12
   
program example_09_vmm_on_top_timeline;
    bit reset =0;

class uvm_as_child extends uvm_component;
  int v=0; int s=0;
  string myaa[string];

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build();
    super.build();
     `uvm_info("TESTCODE: UVM BUILD:",m_name ,UVM_LOW)
  endfunction // void
  function void connect();
    super.connect();
     `uvm_info("TESTCODE: UVM CONNECT:",m_name ,UVM_LOW)
  endfunction // void
  function void end_of_elaboration();
    super.end_of_elaboration();
     `uvm_info("TESTCODE: UVM end_of_elaboration:",m_name ,UVM_LOW)
  endfunction // void

  task run();
     `uvm_info("TESTCODE: UVM RUN",m_name ,UVM_LOW)
    super.run();
     #100;
     `uvm_info("TESTCODE: UVM RUN DONE",m_name ,UVM_LOW)
  endtask

  `uvm_component_utils_begin(uvm_as_child)
    `uvm_field_int(v, UVM_DEFAULT)
    `uvm_field_int(s, UVM_DEFAULT)
    `uvm_field_aa_string_string(myaa, UVM_DEFAULT)
  `uvm_component_utils_end
 endclass // uvm_as_child
   
  class vip1 extends vmm_group;
    `vmm_typename(vip1)
    int seq;
    int done;

    function new (string name, vmm_object parent = null);
      super.new(name, name, parent);
    endfunction

    task start_ph;
      fork
        begin 
          repeat (10) #10 seq++;
          done = 1;
        end
      join_none
      `vmm_note(log, `vmm_sformatf("TESTCODE: VMM vip1 Started"));
    endtask
  endclass

  class vip2 extends vmm_group;
    `vmm_typename(vip2)
    int seq;
    int done;

    function new (string name, vmm_object parent = null);
      super.new(name, name, parent);
    endfunction

    task start_ph;
      fork
        begin 
          repeat (50) #5 seq++;
          done = 1;
        end
      join_none
      `vmm_note(log, `vmm_sformatf("TESTCODE: VMM vip2 Started"));
    endtask
  endclass

  class MyEnv extends vmm_timeline;
 
    `vmm_typename(MyEnv)
     vip1   c1;
     vip2   c2;
     uvm_as_child uvm_child;
     uvm_as_child uvm_child2; 

     function new (string name, vmm_object parent = null);
	super.new(name, name , parent);
     endfunction
     
     function void build_ph();
	uvm_child = uvm_as_child::type_id::create({log.get_name(),".uvm_child"},null);
	uvm_child2 = new({log.get_name(),".uvm_child2"},null);
	c1 = new ({get_object_name(), "_c1"}, this);
	c2 = new ({get_object_name(), "_c2"}, this);
	`vmm_note(log, `vmm_sformatf("TESTCODE: VMM Building complete"));
     endfunction
     
     function void configure_ph();
	`vmm_note(log, `vmm_sformatf("TESTCODE: VMM Configure complete"));
     endfunction

     function void connect_ph();
	`vmm_note(log, `vmm_sformatf("TESTCODE: VMM Connect complete"));
     endfunction
     
     task reset_ph();
	example_09_vmm_on_top_timeline.reset <= 1;
	#100 example_09_vmm_on_top_timeline.reset <= 0;
	`vmm_note(log, `vmm_sformatf("TESTCODE: VMM Resetting start"));
     endtask
     
     task shutdown_ph();
	wait (c1.done && c2.done);
	`vmm_note(log, `vmm_sformatf("TESTCODE: VMM All components are done"));
     endtask
     
     function void report_ph();
	`vmm_note(log, `vmm_sformatf("TESTCODE: VMM What a wonderful simulation"));
     endfunction // void
  endclass // MyEnv
   
class MyTest extends vmm_test;
   `vmm_typename(MyTest)
     function new ();
	super.new("MyTest", "THE TEST");
     endfunction
   static MyTest MyTest_inst  = new();
endclass // MyTest

   
   MyEnv   env;
   MyEnv   env2;
   
   initial begin
      env = new ("env");
      env2 = new ("env2");
      vmm_simulation::run_tests();
   end
   
endprogram 
`endif
 