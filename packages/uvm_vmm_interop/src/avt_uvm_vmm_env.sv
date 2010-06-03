//------------------------------------------------------------------------------
// Copyright 2008 Mentor Graphics Corporation
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
// This class is used to wrap a VMM env for use as an uvm_component in an
// UVM environment. The <avt_uvm_vmm_env> component provides default implementations
// of the UVM phases that delegate to the underlying VMM env's phases. 
// Any number of vmm_env's may be wrapped and reused using the <avt_uvm_vmm_env>.
//
// All other VMM components, such as the ~vmm_subenv~ and ~vmm_xactor~, do not
// require integrated phase support; they can be instantiated and initialized
// directly by the parent component using their respective APIs.
//
// Implementation:
//
// New phases are added to UVM's phasing lineup to accommodate VMM env phases
// that do not have a direct UVM mapping. These include ~vmm_gen_cfg~, which
// delegates to the VMM env's ~gen_cfg~ phase, and ~vmm_report~, which delegates
// to the ~report~ phase. (UVM's report phase is a function, whereas VMM's
// report phase is a task.) These extra phases are transparent to UVM
// components.
//
// With VMM_UVM_INTEROP defined, VMM env phasing is controlled by
// the <avt_uvm_vmm_env> as follows:
//
//|            UVM                  VMM (env)
//|             |                    
//|         vmm_gen_cfg ---------> gen_cfg
//|             |                    
//|           build     --------->  build
//|             |   
//|          connect
//|             |
//|     end_of_elaboration
//|             |
//|     start_of_simulation
//|             |
//|            run --------------> reset_dut
//|             |                  cfg_dut
//|             |                  start
//|             |                  wait_for_end
//|             |  stop
//|             |  request
//|             |   |
//|             |  stop----------> stop
//|             |   |              cleanup
//|             |   |
//|             X<--|   
//|             |    
//|             |
//|          extract
//|             |
//|           check
//|             |
//|           report 
//|             |
//|         vmm_report ----------> report
//|             |
//|             *
//
// Per the UVM use model, the user may customize <avt_uvm_vmm_env>'s default test
// flow by extending and overriding any or all of the UVM phase callbacks.
// You can add functionality before or after calling super.<phase>, or you
// can completely replace the default implementation by not calling super.
// The new <avt_uvm_vmm_env> subtype can then be selected on a type or
// instance basis via the ~uvm_factory~.
//
//------------------------------------------------------------------------------
`ifdef UVM_ON_TOP 
`uvm_phase_func_topdown_decl(vmm_gen_cfg)
`uvm_phase_task_bottomup_decl(vmm_report)

typedef class avt_uvm_vmm_env_base;

vmm_gen_cfg_phase #(avt_uvm_vmm_env_base) vmm_gen_cfg_ph = new;
vmm_report_phase  #(avt_uvm_vmm_env_base) vmm_report_ph = new;


//------------------------------------------------------------------------------
//
// CLASS: avt_uvm_vmm_env_base
//
//------------------------------------------------------------------------------
//
// The ~avt_uvm_vmm_env_base~ class is used to "wrap" an existing ~vmm_env~ subtype
// so that it may be reused as an ordinary UVM component in an UVM-on-top
// environment. If an instance handle to the ~vmm_env~ subtype is not provided
// in the constructor, a new instance will be created and placed in the ~env~
// public property.
//
// When UVM runs through its phasing lineup, the ~avt_uvm_vmm_env_base~ component
// delegates to the appropriate phase methods in the underlying ~env~ object.
// Thus, the VMM env phasing is sychronized with UVM phasing. Although the
// default mapping between UVM and VMM phases is deemed the best in most
// applications, users may choose to override the phase methods in a subtype
// to this class to implement a different phasing scheme.
//
//------------------------------------------------------------------------------

class avt_uvm_vmm_env_base extends uvm_component;

  `uvm_component_utils(avt_uvm_vmm_env_base)

  vmm_env env;

  local static bit m_phases_inserted = insert_vmm_phases();

  // Variable: ok_to_stop
  //
  // When ~ok_to_stop~ is clear (default), the avt_uvm_vmm_env's <stop> task will
  // wait for the VMM env's ~wait_for_end~ task to return before continuing.
  // This bit is automatically set with the underlying VMM env's ~wait_for_end~
  // task returns, which allows the <stop> <stop> task to call the VMM env's
  // ~stop~ and ~cleanup~ phases.
  // 
  // If ~ok_to_stop~ is set manually, other UVM components will be able to
  // terminate the run phase before the VMM env has returned from ~wait_for_end~.

  bit ok_to_stop = 0;


  // Variable: auto_stop_request
  //
  // When set, this bit enables calling an UVM stop_request after
  // the VMM env's wait_for_end task returns, thus ending UVM's run phase
  // coincident with VMM's wait_for_end. Default is 0.
  //
  // A wrapped VMM env is now a mere subcomponent of a larger-scale UVM
  // environment (that may incorporate multiple wrapped VMM envs).  A VMM envs'
  // end-of-test condition is no longer sufficient for determining the overall
  // end-of-test condition. Thus, the default value for ~auto_stop_request~
  // is 0. Parent components of the VMM env wrapper may choose to wait on the
  // posedge of <ok_to_stop> to indicate the VMM env has reached its end-of-test
  // condition.

  bit auto_stop_request = 0;


  // Function: new
  //
  // Creates the vmm_env proxy class with the given name, parent, and optional
  // vmm_env handle.  If the env handle is null, it is assumed that an extension
  // of this class will be responsible for creating and assigning the m_env
  // internal variable.
  
  function new (string name, uvm_component parent=null,
                vmm_env env=null);
  
    super.new(name,parent);

    if (vmm_report_ph == null) vmm_report_ph = new();
    uvm_top.insert_phase(vmm_report_ph, report_ph);

    this.env = env;

    enable_stop_interrupt = 1;

  endfunction
  
  
  // Function: insert_vmm_phases
  //
  // A static function that registers the ~vmm_gen_cfg~ phase callback with the UVM.
  // It is called as part of static initialization before any env or phasing
  // can begin. This allows the ~vmm_env~ to be created as an UVM component
  // in ~build~ phase.
  
  local static function bit insert_vmm_phases();
    if (vmm_gen_cfg_ph == null)
      vmm_gen_cfg_ph   = new;
    uvm_top.insert_phase(vmm_gen_cfg_ph, null);
    return 1;
  endfunction
   
  
  // Function: vmm_gen_cfg
  //
  // Calls the underlying VMM env's gen_cfg phase.
  
  virtual function void vmm_gen_cfg();
    if (this.env == null) begin
      uvm_report_fatal("NUVMMENV","The avt_uvm_vmm_env requires a vmm_env instance");
      return;
    end
    uvm_top.check_verbosity();
    env.gen_cfg();
  endfunction
  
  
  // Function: build
  //
  // Calls the underlying VMM env's build phase. Disables the underlying
  // env from manually calling into the UVM's phasing mechanism.
  
  virtual function void build();
    env.build();
  endfunction
  

  // Task: vmm_reset_dut
  //
  // Calls the underlying VMM env's reset_dut phase, provided this
  // phase was enabled in the <new> constructor.

  virtual task vmm_reset_dut();
    env.reset_dut();
    uvm_top.stop_request();
  endtask

  
  // Task: vmm_cfg_dut
  //
  // Calls the underlying VMM env's cfg_dut phase, provided this
  // phase was enabled in the <new> constructor.

  virtual task vmm_cfg_dut();
    env.cfg_dut();
    uvm_top.stop_request();
  endtask

  
  // Task: run
  //
  // Calls the underlying VMM env's reset_dut, cfg_dut, start, and
  // wait_for_end phases, returning when the env's end-of-test
  // condition has been reached. Extensions of this method may augment
  // or remove certain end-of-test conditions from the underlying env's
  // consensus object before calling ~super.run()~. When ~super.run()~
  // returns, extensions may choose to call ~uvm_top.stop_request()~ if
  // the underlying env is the only governor of end-of-test.
  // 
  // Extensions may completely override this base implementation by
  // not calling ~super.run()~. In such cases, all four VMM phases must
  // still be executed in the prescribed order.
  
  virtual task run();
    env.reset_dut();
    env.cfg_dut();
    env.start();
    env.wait_for_end();
    if (auto_stop_request)
      uvm_top.stop_request();
    ok_to_stop = 1;
  endtask
  
  
  // Task: stop
  //
  // If the ~run~ phase is being stopped, this task waits for the
  // underlying env's ~wait_for_end~ phase to return, then calls the
  // VMM env's stop and cleanup tasks. If the <ok_to_stop> variable
  // is set at the time ~stop~ is called, then ~stop~ will not wait
  // for ~wait_for_end~ to return. This allows UVM components to
  // control when the VMM env and its embedded xactors are stopped.
  
  virtual task stop(string ph_name); 
    if (ph_name == "run") begin
      if (!ok_to_stop)
        @ok_to_stop;
      env.stop();
      env.cleanup();
    end
  endtask
  

  // Task: vmm_report
  //
  // Calls the underlying VMM env's report method, then stops the
  // reportvmm phase. This phase is called after UVM's ~report~
  // phase has completed.
  
  virtual task vmm_report();
    env.report();
    uvm_top.stop_request();
    vmm_report_ph.wait_done();
  endtask

endclass


typedef class avt_vmm_uvm_env;

//------------------------------------------------------------------------------
//
// CLASS: avt_uvm_vmm_env
//
// Use this class to wrap (contain) an existing VMM env whose constructor does
// not have a ~name~ argument. See <avt_uvm_vmm_env_base> for more information.
//
//------------------------------------------------------------------------------

class avt_uvm_vmm_env #(type ENV=vmm_env) extends avt_uvm_vmm_env_base;

   typedef avt_uvm_vmm_env #(ENV) this_type;

  `uvm_component_utils(this_type)

  ENV env;

  // Function: new
  //
  // Creates a VMM env container component with the given ~name~ and ~parent~.
  // A new instance of an env of type ~ENV~ is created if one is not
  // provided in the ~env~ argument. The ~env~ will not be named.

  function new (string name,
                uvm_component parent=null,
                ENV env=null);
    avt_vmm_uvm_env avt_env;
    super.new(name,parent,env);
    if (env == null)
      env = new();
    if ($cast(avt_env,env))
      avt_env.disable_uvm = 1;
    this.env = env;
    super.env = env;
  endfunction

endclass


//------------------------------------------------------------------------------
//
// CLASS: avt_uvm_vmm_env_named
//
// Use this class to wrap (contain) an existing VMM env whose constructor
// must have a ~name~ argument. See <avt_uvm_vmm_env_base> for more information.
//
//------------------------------------------------------------------------------

class avt_uvm_vmm_env_named #(type ENV=vmm_env) extends avt_uvm_vmm_env_base;

   typedef avt_uvm_vmm_env_named #(ENV) this_type;

  `uvm_component_utils(this_type)

  ENV env;

  // Function: new
  //
  // Creates a VMM env container component with the given ~name~ and ~parent~.
  // A new instance of an env of type ~ENV~ is created if one is not
  // provided in the ~env~ argument. The name given the new ~env~ is
  // the full name of this component. 

  function new (string name,
                uvm_component parent=null,
                ENV env=null);
    avt_vmm_uvm_env avt_env;
    super.new(name,parent,env);
    if (env == null)
      env = new({parent==null?"":{parent.get_full_name(),"."},name});
    if ($cast(avt_env,env))
      avt_env.disable_uvm = 1;
    this.env = env;
    super.env = env;
  endfunction

endclass


`endif
