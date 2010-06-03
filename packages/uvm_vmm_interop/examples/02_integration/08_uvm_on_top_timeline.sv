//------------------------------------------------------------------------------
//    Copyright 2008 Mentor Graphics Corporation
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

`define UVM_ON_TOP

`include "uvm_vmm_pkg.sv"

//------------------------------------------------------------------------------
//
// Example: UVM on top
//
// This example demonstrates a simple UVM-on-top environment, where UVM controls
// the phasing of UVM and any integrated VMM timelines.
//
//------------------------------------------------------------------------------

//------------------------------------------------------------------------------
//
// Class- my_uvm_env
//
// Top-level UVM container, which can later be reused as a block-level
// component.
//------------------------------------------------------------------------------
`ifndef NO_VMM_12
  class vip extends vmm_timeline;
    `vmm_typename(vip)
    int seq;
    int done;

    function new (string name, vmm_timeline default_timeline = null);
      super.new(name, name,default_timeline );
    endfunction
     function void rtl_config_ph();
	`vmm_note(log, `vmm_sformatf("TESTCODE: VMM RTL CONFIG complete"));
     endfunction
     function void build_ph();
	`vmm_note(log, `vmm_sformatf("TESTCODE: VMM Building complete"));
     endfunction
     
     function void configure_ph();
	`vmm_note(log, `vmm_sformatf("TESTCODE: VMM Configure complete"));
     endfunction

     function void connect_ph();
	`vmm_note(log, `vmm_sformatf("TESTCODE: VMM Connect complete"));
     endfunction
     
     task reset_ph();
	`vmm_note(log, `vmm_sformatf("TESTCODE: VMM Resetting start"));
     endtask
      task run_ph;
       	`vmm_note(log, `vmm_sformatf("TESTCODE: VMM Running the TEST"));
    endtask
     
    task start_ph;
      fork
        begin 
          repeat (10) #10 seq++;
          done = 1;
        end
      join_none
      `vmm_note(log, `vmm_sformatf("TESTCODE: VMM vip Started"));
    endtask
   
     task shutdown_ph();
	`vmm_note(log, `vmm_sformatf("TESTCODE: VMM All components are done"));
     endtask
     task cleanup_ph();
	`vmm_note(log, `vmm_sformatf("TESTCODE: VMM Cleaning in progress"));
     endtask
     function void report_ph();
	`vmm_note(log, `vmm_sformatf("TESTCODE: VMM What a wonderful simulation"));
     endfunction 

  endclass

class my_uvm_env extends uvm_component;

  avt_uvm_vmm_timeline subenv;
     vip   theVIP;

  `uvm_component_utils(my_uvm_env)

  function new (string name, uvm_component parent=null);
    super.new(name,parent);
     subenv = new("tester",this);
     theVIP = new ("tester_theVIP", subenv.timeline);
  endfunction

  virtual function void build();
   super.build();
   subenv.auto_stop_request = 0;
   `uvm_info("TESTCODE: UVM BUILD:",m_name ,UVM_LOW)
 endfunction

  function void connect();
    super.connect();
     `uvm_info("TESTCODE: UVM CONNECT:",m_name ,UVM_LOW)
  endfunction // void
   
  function void end_of_elaboration();
    super.end_of_elaboration();
     `uvm_info("TESTCODE: UVM end_of_elaboration:",m_name ,UVM_LOW)
  endfunction // void

   task run();
      `uvm_info("TESTCODE: UVM RUN:",m_name ,UVM_LOW)
	fork 
	   begin super.run();  end
	   begin
	      #25;
	      global_stop_request();     
	      `uvm_info("TESTCODE: UVM RUN DONE:",m_name ,UVM_LOW)
	   end
	join
  endtask // run
   
  
  virtual function void extract();
   super.extract();
     `uvm_info("TESTCODE: UVM EXTRACT:",m_name ,UVM_LOW)
   endfunction // void
   
  function void report();
    super.report();
     `uvm_info("TESTCODE: UVM REPORT:",m_name ,UVM_LOW)
  endfunction // void
endclass

program 08_uvm_on_top_timeline;
   
   initial run_test("my_uvm_env");   

endprogram
`endif
// (inline source)

