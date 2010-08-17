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
// Title: Integrated Phase Control - UVM-on-top
//
//------------------------------------------------------------------------------
//
// The <avt_uvm_vmm_timeline> class is used to wrap a VMM timeline for use as an uvm_component in an
// UVM environment. The <avt_uvm_vmm_timeline> component provides default implementations
// of the UVM phases that delegate to the underlying VMM timeline's phases. 
// Any number of vmm_timeline's may be wrapped and reused using the <avt_uvm_vmm_timeline>.
//
// All other VMM components, such as the ~vmm_subenv~ and ~vmm_xactor~, do not
// require integrated phase support; they can be instantiated and initialized
// directly by the parent component using their respective APIs.
//
// Implementation:
//
// New phases are added to UVM's phasing lineup to accommodate VMM timeline phases
// that do not have a direct UVM mapping. These include ~vmm_rtl_config~, which
// delegates to the VMM timeline's ~rtl_config~ phase and ~vmm_cleanup~, as VMM ~cleanup_ph~ 
// is a task wheras ~check~ in UVM is a function. These extra phases are transparent to UVM
// components.
//
// With VMM_UVM_INTEROP defined, VMM timeline phasing is controlled by
// the <avt_uvm_vmm_timeline> as follows:
//
//|            UVM                  VMM (timeline)
//|             |                    
//|         vmm_rtl_config ---------> rtl_config
//|             |                    
//|           build     --------->  build
//|             |                   configure
//|             |   
//|          connect    --------->  connect
//|             |
//|     end_of_elaboration
//|             |
//|     start_of_simulation--------->  start_of_sim
//|             |
//|            run --------------> reset
//|             |                  training
//|             |                  config_dut
//|             |                  start
//|             |                  run
//|             |  stop
//|             |  request
//|             |   |
//|             |  stop----------> shutdown
//|             |   |              
//|             |   |
//|             X<--|   
//|             |    
//|             |
//|          extract
//|             |
//|           check
//|             |
//|          vmm_cleanup --------------> cleanup
//|             |
//|           report ----------> report
//|             |
//|             *
//
// Per the UVM use model, the user may customize <avt_uvm_vmm_timeline>'s default test
// flow by extending and overriding any or all of the UVM phase callbacks.
// You can add functionality before or after calling super.<phase>, or you
// can completely replace the default implementation by not calling super.
// The new <avt_uvm_vmm_timeline> subtype can then be selected on a type or
// instance basis via the ~uvm_factory~.
//
//------------------------------------------------------------------------------
`ifdef UVM_ON_TOP 
`uvm_phase_func_topdown_decl(vmm_rtl_config)
`uvm_phase_task_bottomup_decl(vmm_cleanup)

typedef class avt_uvm_vmm_timeline;
typedef class avt_vmm_uvm_timeline;

vmm_rtl_config_phase #(avt_uvm_vmm_timeline) vmm_rtl_config_ph = new;
vmm_cleanup_phase  #(avt_uvm_vmm_timeline) vmm_cleanup_ph = new;


//------------------------------------------------------------------------------
//
// CLASS: avt_uvm_vmm_timeline
//
//------------------------------------------------------------------------------
//
// The ~avt_uvm_vmm_timeline~ class is used to "wrap" an existing ~vmm_timeline~ subtype
// so that it may be reused as an ordinary UVM component in an UVM-on-top
// environment. If an instance handle to the ~vmm_timeline~ subtype is not provided
// in the constructor, a new instance will be created and placed in the ~timeline~
// public property.
//
// When UVM runs through its phasing lineup, the ~avt_uvm_vmm_timeline~ component
// delegates to the appropriate phase methods in the underlying ~timeline~ object.
// Thus, the VMM timeline phasing is sychronized with UVM phasing. Although the
// default mapping between UVM and VMM phases is deemed the best in most
// applications, users may choose to override the phase methods in a subtype
// to this class to implement a different phasing scheme.
//
//------------------------------------------------------------------------------

class avt_uvm_vmm_timeline extends uvm_component;

  `uvm_component_utils(avt_uvm_vmm_timeline)

  static vmm_timeline  timeline = new;

  local static bit m_phases_inserted = insert_vmm_phases();

  // Variable: ok_to_stop
  //
  // When ~ok_to_stop~ is clear (default), the avt_uvm_vmm_timeline's <stop> task will
  // wait for the VMM timeline's ~wait_for_end~ task to return before continuing.
  // This bit is automatically set with the underlying VMM timeline's ~wait_for_end~
  // task returns, which allows the <stop> <stop> task to call the VMM timeline's
  // ~stop~ and ~cleanup~ phases.
  // 
  // If ~ok_to_stop~ is set manually, other UVM components will be able to
  // terminate the run phase before the VMM timeline has returned from ~wait_for_end~.

  bit ok_to_stop = 0;


  // Variable: auto_stop_request
  //
  // When set, this bit enables calling an UVM stop_request after
  // the VMM timeline's wait_for_end task returns, thus ending UVM's run phase
  // coincident with VMM's wait_for_end. Default is 0.
  //
  // A wrapped VMM timeline is now a mere subcomponent of a larger-scale UVM
  // environment (that may incorporate multiple wrapped VMM timelines).  A VMM timelines'
  // end-of-test condition is no longer sufficient for determining the overall
  // end-of-test condition. Thus, the default value for ~auto_stop_request~
  // is 0. Parent components of the VMM timeline wrapper may choose to wait on the
  // posedge of <ok_to_stop> to indicate the VMM timeline has reached its end-of-test
  // condition.

  bit auto_stop_request = 0;


  // Function: new
  //
  // Creates the vmm_timeline proxy class with the given name, parent, and optional
  // vmm_timeline handle.  If the timeline handle is null, it is assumed that an extension
  // of this class will be responsible for creating and assigning the m_timeline
  // internal variable.

  function new (string name, uvm_component parent=null);   
     avt_vmm_uvm_timeline avt_timeline;
    super.new(name,parent);
     
     if (vmm_cleanup_ph == null) vmm_cleanup_ph = new();
     uvm_top.insert_phase(vmm_cleanup_ph, run_ph);
     
     enable_stop_interrupt = 1;
     
     if ($cast(avt_timeline,timeline)) avt_timeline.disable_uvm = 1;
  endfunction
 
  // Function: insert_vmm_phases
  //
  // A static function that registers the ~vmm_rtl_config~ phase callback with the UVM.
  // It is called as part of static initialization before any timeline or phasing
  // can begin. This allows the ~vmm_timeline~ to be created as an UVM component
  // in ~build~ phase.
  
  local static function bit insert_vmm_phases();
    if (vmm_rtl_config_ph == null)
      vmm_rtl_config_ph   = new;
    uvm_top.insert_phase(vmm_rtl_config_ph, null);
    return 1;
  endfunction
   
  
  // Function: vmm_rtl_config
  //
  // Calls the underlying VMM timeline's rtl_config phase.
  
  virtual function void vmm_rtl_config();
    if (this.timeline == null) begin
      uvm_report_fatal("NUVMMTIMELINE","The avt_uvm_vmm_timeline requires a vmm_timeline instance");
      return;
    end
    uvm_top.check_verbosity();  
   fork timeline.run_phase("rtl_config"); join_none
  endfunction
  
  
  // Function: build
  //
  // Calls the underlying VMM timeline's build phase. Disables the underlying
  // timeline from manually calling into the UVM's phasing mechanism.
  
  virtual function void build();
    timeline.run_function_phase("configure"); 
  endfunction
  
  // Function: connect
  //
  // Calls the underlying VMM timeline's connect phase. Disables the underlying
  // timeline from manually calling into the UVM's phasing mechanism.
  
  virtual function void connect();
   timeline.run_function_phase("connect"); 
  endfunction // void
   
  // Function: start_of_simulation
  //
  // Calls the underlying VMM timeline's start_of_sim phase. Disables the underlying
  // timeline from manually calling into the UVM's phasing mechanism.
  
  virtual function void start_of_simulation();
   timeline.run_function_phase("start_of_sim");
  endfunction // void
  
  
  // Task: run
  //
  // Calls the underlying VMM timeline's reset_dut, cfg_dut, start, and
  // wait_for_end phases, returning when the timeline's end-of-test
  // condition has been reached. Extensions of this method may augment
  // or remove certain end-of-test conditions from the underlying timeline's
  // consensus object before calling ~super.run()~. When ~super.run()~
  // returns, extensions may choose to call ~uvm_top.stop_request()~ if
  // the underlying timeline is the only governor of end-of-test.
  // 
  // Extensions may completely override this base implementation by
  // not calling ~super.run()~. In such cases, all VMM phases must
  // still be executed in the prescribed order.
  
  virtual task run();
   timeline.run_phase("run");
    if (auto_stop_request)
      uvm_top.stop_request();
    ok_to_stop = 1;
  endtask
  
  
  // Task: stop
  //
  // If the ~run~ phase is being stopped, this task waits for the
  // underlying timeline's ~wait_for_end~ phase to return, then calls the
  // VMM timeline's stop and cleanup tasks. If the <ok_to_stop> variable
  // is set at the time ~stop~ is called, then ~stop~ will not wait
  // for ~wait_for_end~ to return. This allows UVM components to
  // control when the VMM timeline and its embedded xactors are stopped.
  
  virtual task stop(string ph_name); 
    if (ph_name == "run") begin
      if (!ok_to_stop)
        @ok_to_stop;
      timeline.run_phase("shutdown");
    end
 endtask
  
   
  // Task: vmm_cleanup
  //
  // Calls the underlying VMM cleanup method, then stops the
  //  phase. This phase is called after UVM's ~check~
  // phase has completed.
  
  virtual task vmm_cleanup();
    timeline.run_phase("cleanup");
    uvm_top.stop_request();
    vmm_cleanup_ph.wait_done();
  endtask
   
  // Function: report
  //
  // Calls the underlying VMM timeline's report method, then stops the
  // reportvmm phase. This phase is called after UVM's ~report~
  // phase has completed.
  
  function void report();
     timeline.run_function_phase("report");
  endfunction // void


  
endclass // avt_uvm_vmm_timeline



`endif
