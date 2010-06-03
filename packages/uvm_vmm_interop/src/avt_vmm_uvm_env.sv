//------------------------------------------------------------------------------
//    Copyright 2009 Mentor Graphics Corporation
//    Copyright 2009 Synopsys, Inc.
//    All Rights Reserved Worldwide
//
//    Licensed under the Apache License, Version 2.0 (the
//    "License"); you may not use this file except in
//    compliance with the License.  You may obtain a copy of
//    the License at
//
//        http://www.apache.org/licenses/LICENSE-2.0
//
//    Unless required by applicable law or agreed to in
//    writing, software distributed under the License is
//    distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
//    CONDITIONS OF ANY KIND, either express or implied.  See
//    the License for the specific language governing
//    permissions and limitations under the License.
//------------------------------------------------------------------------------


//------------------------------------------------------------------------------
//
// Title: Integrated Phase Control - VMM-on-top
//
//------------------------------------------------------------------------------
//
// This class is used to ensure UVM components (i.e. all subtypes of
// uvm_component), when instantiated in VMM environments and/or components, have
// their phase methods called at the correct time relative to the execution of
// the top-level VMM environment phase methods.
//
// With VMM_UVM_INTEROP defined, UVM phasing is controlled by the ~avt_vmm_uvm_env~
// as follows:
//
//|             VMM                 UVM
//|             |                    
//|           gen_cfg                
//|             |                    
//|            build________________build
//|                   uvm_build       |
//|                                 connect
//|              _____________________/     
//|             |                      
//|             |_____________end_of_elaboration
//|                                   |
//|                           start_of_simulation
//|              _____________________/     
//|             |          
//|             |            
//|             |\__FORK run phase__ 
//|             |                    \
//|           reset_dut              run
//|             |                     |
//|           cfg_dut                 | 
//|             |                     |
//|           start                   |
//|             |                     |
//|        wait_for_end               |
//|             |                     |
//|             |_ stop  --> FORK     |
//|             | request        \    |
//|             |               stop  |
//|             |                 |   |    
//|             |                 |-->X    
//|             |__ WAIT -------> *
//|                 for run
//|              ___/  complete
//|           stop                   
//|             |                    
//|          cleanup                 
//|             |                    
//|             |
//|           report
//|             |___________________extract
//|                 uvm_report        |
//|                                  check
//|                                   |
//|                                 report 
//|                                   |
//|                                 <user>
//|                                   |
//|              _____________________*
//|             |
//|        <final report>
//|             |
//|             *
//
//------------------------------------------------------------------------------

`ifdef VMM_ON_TOP

// Replace the UVM message server with one that re-routes
// UVM messages to a vmm_log instance.

function bit avt_override_uvm_report_server();
  avt_vmm_uvm_report_server svr;
  uvm_report_global_server glob;
  svr = avt_vmm_uvm_report_server::get();
  glob = new();
  glob.set_server(svr);
  return 1;
endfunction

bit _avt_uvm_server = avt_override_uvm_report_server();

`endif

//------------------------------------------------------------------------------
//
// CLASS: avt_vmm_uvm_env
//
// This class is used to automatically integrate UVM phasing with VMM phasing
// in a VMM-on-top environment.
//------------------------------------------------------------------------------

class avt_vmm_uvm_env extends `AVT_VMM_UVM_ENV_BASE;

   bit disable_uvm = 0;
   protected int build_level;

   // Function: new
   // 
   // Creates a new instance of an ~avt_vmm_uvm_env~.

   function new(string name = "Verif Env"
                `VMM_ENV_BASE_NEW_EXTERN_ARGS);
     super.new(name
     `ifdef VMM_ENV_BASE_NEW_CALL
      `VMM_ENV_BASE_NEW_CALL
     `endif
     );

   endfunction


   // Function: uvm_build
   // 
   // Calls into the UVM's phasing mechanism to complete UVM's
   // ~build~, ~connect~, and any other user-defined phases
   // up to ~end_of_elaboration~.

   virtual function void uvm_build();
     if (disable_uvm)
       return;
     if (--build_level <= 0)
       //OVM2UVM> uvm_top.run_global_func_phase(configure_ph,1);
       uvm_top.run_global_func_phase(connect_ph,1);  //OVM2UVM> see ovm-2.0 deprecated.txt
   endfunction


   // Function: uvm_report
   // 
   // Calls into the UVM's phasing mechanism to complete UVM's
   // ~extract~, ~check~, and ~report~ phases.

   virtual task uvm_report();
     if (!disable_uvm) begin
       repeat(2) #0;
       uvm_top.run_global_phase(report_ph);
     end
   endtask


   // Task: reset_dut
   //
   // Syncs the start of VMM reset_dut with the start of UVM run phase,
   // then forks UVM run phase to run in parallel with reset_dut,
   // config_dut, start, and wait_for_end.

   virtual task reset_dut();
      if (this.step < BUILD)
        this.build();
      if (!disable_uvm) begin
        //OVM2UVM> if (!connect_ph.is_done()) begin
        if (!build_ph.is_done()) begin
	         `vmm_fatal(this.log, {"The build() method did not call ",
                    "avt_vmm_uvm_env::uvm_build() before returning"});
        end
        uvm_top.run_global_phase(run_ph,1);
        fork
	   uvm_top.run_global_phase(run_ph);
        join_none
      end
      super.reset_dut();
   endtask


   // Function: stop
   // 
   // Requests the UVM run phase to stop if it is still running,
   // then waits for the UVM run phase to finish.

   virtual task stop();
      super.stop();
      if (!disable_uvm) begin
        if (!run_ph.is_done()) begin
           repeat (2) #0;
           //OVM2UVM> uvm_top.global_stop_request();
           uvm_top.stop_request();  //OVM2UVM> ovm-2.0.2 release-notes.txt
           run_ph.wait_done();
        end
      end
   endtask


   // Task: report
   //
   // Calls into the UVM's phasing mechanism to execute user-defined
   // UVM phases inserted after ~report_ph~, if any.

   virtual task report();
      if (!disable_uvm) begin
        repeat (2) #0;
        uvm_top.run_global_phase();
      end
      super.report();
   endtask

endclass


// MACRO: `uvm_build
//
// Overrides the avt_vmm_uvm_env's <uvm_build> method such that the
// call to advance UVM phasing up to ~end_of_elaboration~ is
// performed only once in the most derived env-subtype of a
// a potentially deep vmm_env-inheritance hierarchy.

`define uvm_build \
   local int _uvm_build_level = ++build_level; \
   virtual function void uvm_build(); \
     if (disable_uvm) \
       return; \
     if (--build_level <= 0) \
       /* OVM2UVM> uvm_top.run_global_func_phase(configure_ph,1); */ \
       uvm_top.run_global_func_phase(connect_ph,1); \
   endfunction





