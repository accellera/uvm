//------------------------------------------------------------------------------
// Copyright 2010 Synopsys, Inc.
//
// All Rights Reserved Worldwide
// 
// Licensed under the Apache License, Version 2.0 (the "License"); you may
// not use this file except in compliance with the License.  You may obtain
// a copy of the License at
// 
//        http://www.apache.org/licenses/LICENSE-2.0
// 
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
// WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.  See the
// License for the specific language governing permissions and limitations
// under the License.
//------------------------------------------------------------------------------

//------------------------------------------------------------------------------
//
// Title: Integrated Phase Control - VMM-on-top (Implicit phasing)
//
//------------------------------------------------------------------------------
//
// The <avt_vmm_uvm_timeline> class is used to wrap a UVM environment based upon 
// uvm_component in a  VMM timeline.
// The <avt_vmm_uvm_timeline> component provides default implementations
// of the VMM phases that delegate to the underlying VMM timeline's phases. 
// Any number of vmm_timeline's may be wrapped and reused using the <avt_vmm_uvm_timeline>.
//
// All other VMM components, such as the <vmm_subenv> and <vmm_xactor>, do not
// require integrated phase support; they can be instantiated and initialized
// directly by the parent component using their respective APIs.
//
// All other UVM components, do not
// require integrated phase support; they can be instantiated and initialized
// directly by the parent component using their respective APIs.
//
// UVM employs single-timeline phasing that can be controlled from VMM timeline. 
// This will allow advanced verification to be performed using VMM mulitple timelines where
// UVM phases are controlled as a single sub-timeline in the overall verification environment.
//
// With VMM_UVM_INTEROP defined, UVM phasing is controlled by the <avt_vmm_uvm_timeline>
// as follows:
//
//|             VMM                 UVM
//|             |                    
//|           rtl_cfg                
//|             |                    
//|            build________________build
//|             |
//|          configure
//|             |                
//|           connect______________connect
//|             |          |           |     
//|             |          |____end_of_elaboration
//|             |                    
//|          start_of_sim______start_of_simulation
//|              _____________________/     
//|             |          
//|             |            
//|             |\__FORK run phase__ 
//|             |                    \
//|          reset_dut               run
//|             |                     |
//|        training_dut               | 
//|             |                     |
//|         config_dut                | 
//|             |                     |
//|        start_of_test              |
//|             |                     |
//|           start                   |
//|             |                     |
//|            run                    |
//|             |                     |
//|          shutdown                 |
//|             |                     |
//|             |_ stop  --> FORK     |
//|             | request        \    |
//|             |               stop  |
//|             |                 |   |    
//|             |                 |-->X    
//|             |__ WAIT -------> *
//|                 for run
//|              ___/  complete
//|          cleanup                 
//|             |                    
//|             |___________________extract
//|             |       |             |
//|             |       |___________check
//|             |                     
//|           report________________report 
//|             |                     
//|             |
//|        <final report>
//|             |
//|             *
//
/*
  Class: avt_vmm_uvm_timeline 
*/
  class avt_vmm_uvm_timeline extends vmm_timeline;
     `vmm_typename(avt_vmm_uvm_timeline)
      avt_vmm_uvm_timeline avt_timeline=new();
     localparam RUN_IT = 0;
     localparam RUN_UPTO = 1;
     
   bit disable_uvm = 0;
   protected int build_level;
   local int 	 _uvm_build_level = ++build_level; 
     function new (string name="VMM_UVM timeline", vmm_object parent = null);
	super.new(name, name, parent);
     endfunction

     
     /* PRE_TEST_TIMELINE */
     // function: rtl_config_ph
     //
     // Called in pre-test timeline, used for configuring the DUT file
     function void rtl_config_ph();
     endfunction // void
    
     // function: build_ph()
     //
     // Called in pre-test timeline, used for build the DUT configurations, generics, etc.
     function void build_ph(); 
	if (!disable_uvm) begin 
	  if (--build_level <= 0) begin
	    uvm_top.run_global_func_phase(uvm_pkg::build_ph,RUN_IT);
	  end
	end 
     endfunction // void     
     
     // function: configure_ph()
     //
     // Called in pre-test timeline, used for configuring the DUT, registers, etc.
     function void configure_ph();
	if (!disable_uvm) begin
	   if (!uvm_pkg::build_ph.is_done()) begin
	      `vmm_fatal(this.log, {"The build_ph() method did not call ",
				    "avt_vmm_uvm_group::build_ph() before returning"});
           end
	end
     endfunction // void
     
     // function: connect_ph()
     //
     // Called in pre-test timeline, used for connecting the testbench components, channels, TLM sockets, etc.
     function void connect_ph();
	if (!disable_uvm) begin
	   if (!uvm_pkg::build_ph.is_done()) begin
	      `vmm_fatal(this.log, {"The build_ph() method did not call ",
				    "avt_vmm_uvm_group::build_ph() before returning"});
           end
	   uvm_top.run_global_func_phase(uvm_pkg::connect_ph,RUN_IT); 
	end
     endfunction

     /* TOP_TEST TIMLINE */
     
     // function: configure_test_ph()
     //
     // Called in test timeline, used for configuring the testbench components, channels, TLM sockets, etc.
     function void configure_test_ph();
	if (!disable_uvm) begin
	   if (!uvm_pkg::connect_ph.is_done()) begin
              `vmm_fatal(this.log, {"The connect_ph() method did not call ",
				    "avt_vmm_uvm_group::connect() before returning"});
           end
	   //uvm_top.run_global_func_phase(uvm_pkg::configure_ph,RUN_IT); 
	   uvm_top.run_global_func_phase(uvm_pkg::end_of_elaboration_ph,RUN_IT);
	end
     endfunction

     // function: configure_test_ph()
     //
     // Called in test timeline, used for starting the testbench components, transactors, scoreboard, etc.
     function void start_of_sim_ph();
	if (!disable_uvm) begin 
	   if (!uvm_pkg::end_of_elaboration_ph.is_done()) begin
              `vmm_fatal(this.log, {"The configure_test_ph() method did not call ",
				    "avt_vmm_uvm_env::uvm_pkg::end_of_elaboration_ph() before returning"});
           end
	   uvm_top.run_global_func_phase(uvm_pkg::start_of_simulation_ph,RUN_IT);
	end 
     endfunction
     
     // task: reset_ph()
     //
     // Called in test timeline, used for resetting the DUT and testbench transactors, etc.
     task reset_ph();
     	if (!disable_uvm) begin  
           if (!uvm_pkg::start_of_simulation_ph.is_done()) begin
              `vmm_fatal(this.log, {"The start_of_sim_ph() method did not call ",
				    "avt_vmm_uvm_env::uvm_pkg::start_of_simulation_ph() before returning"});
           end
           fork
           	uvm_top.run_global_phase(uvm_pkg::run_ph, RUN_IT);
           join_none
     	end
     endtask // reset_ph
     
     // task: training_ph()
     //
     // Called in test timeline, used to wait for DUT end of training
     task training_ph();
     endtask

     // task: config_dut_ph()
     //
     // Called in test timeline, used to configure the DUT registers (dynamic)
     task config_dut_ph();
     endtask

     // task: start_ph()
     //
     // Called in test timeline, used to start testbench transactors, etc.
     task start_ph();
     endtask


     // function: start_of_test_ph()
     //
     // Called in test timeline, used start the tests
     function void start_of_test_ph();
     endfunction     

     // task: run_ph()
     //
     // Called in test timeline, used to start secondary testbench transactors, etc.
     task run_ph(); 
     endtask
 
     // task: shutdown_ph
     //
     // Calls into the UVM's phasing mechanism 
     // to ensure completion of UVM ~run_ph~..     
     task shutdown_ph();
     	if (!disable_uvm) begin 
           if (!uvm_pkg::run_ph.is_done()) begin
              repeat (2) #0;
              uvm_top.stop_request();
              uvm_pkg::run_ph.wait_done();
           end	
     	end 
     endtask // shutdown
 
     // task: cleanup_ph
     //
     // Calls into the UVM's phasing mechanism to execute all
     // UVM phases after ~run_ph~, such as ~extract_ph~.    
     task cleanup_ph();
     	if (!disable_uvm) begin 
     		if (!uvm_pkg::run_ph.is_done()) begin
              `vmm_fatal(this.log, {"The shutdown_ph() method did not call ",
				    "uvm_top.stop_request() "});
     		end	   repeat(2) #0;
	   	uvm_top.run_global_phase(uvm_pkg::check_ph,RUN_IT); 
     	end 
     endtask // cleanup_ph
 
     // function: report_ph
     //
     // Calls into the UVM's phasing mechanism to execute UVM ~report_ph~.     
     function void report_ph();
     	if (!disable_uvm) begin 
           if (!uvm_pkg::check_ph.is_done()) begin
	      `vmm_fatal(this.log, {"The claenup_ph() method did not call ",
				    "avt_vmm_uvm_env::uvm_pkg::check_ph() before returning"});
	      end
	      uvm_top.run_global_func_phase(uvm_pkg::report_ph,RUN_IT);
     	end
     endfunction // void
     
     /* POST_TEST_TIMELINE */
     
     // function: final_ph
     //
     // Calls into the UVM's phasing mechanism to execute user-defined
     // UVM phases inserted after ~report_ph~, if any.
     function void final_ph();
     	if (!disable_uvm) begin
     		uvm_top.run_global_func_phase();
     	end
     endfunction
     
  endclass
