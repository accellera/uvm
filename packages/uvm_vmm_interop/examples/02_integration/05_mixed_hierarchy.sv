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

`include "uvm_apb_rw.sv"
`include "vmm_apb_rw.sv"
`include "apb_rw_converters.sv"

`include "vmm_producers.sv"
`include "vmm_consumers.sv"
`include "uvm_consumers.sv"
`include "apb_scoreboard.sv"

class uvm_container #(type T=uvm_object) extends uvm_object;
  rand T obj;
  function new(T obj = null);
    this.obj = obj;
  endfunction
endclass





//------------------------------------------------------------------------------
// Example: Mixed Hierarchy
//
// This example demonstrates how testbench environments can evolve to become
// mixed component hierarchies, where UVM instantiates VMM that instantiates
// UVM and so on. Such hierarchies are referred as ~sandwiched~ or ~layered~. 
//
// The following figure represents what is meant by mixed hierarchy
//
// (see MH_05_mixed_hierarchy.gif)
//
// Such hierarchies are not typically designed from scratch like this. They
// typically evolve to something like this as block-level testing progresses to
// system-level, where integration of existing IP and legacy environments are
// commonly employed to maximize reuse.
//
// When integrating UVM components as children of envs, subenvs, and xactors,
// care must be taken to ensure the hierarchical name of every UVM component
// is unique and deterministic. The UVM's configuration and factory interfaces
// require this. It is not enough to simply pass a null handle to each UVM
// component's parent constructor argument. Such components end up as children
// of uvm_top, the implicit top-level UVM component, and there can not be any
// two children by the same name in uvm_top. 
//
// Therefore, to meet this requirement, these guidelines should be followed
// to emulate hierarchical naming in an environment containing UVM components:
//
// - The instance name of a VMM child of an UVM parent should be prefixed with
//   the full name of the UVM parent:
//
//   | UVM instantiating VMM in build method:
//   |
//   | virtual function build();
//   |   env    = new({get_full_name(),".env"},...);
//   |   subenv = new({get_full_name(),".subenv"},...);
//   |   xactor = new("typename",{get_full_name(),".xactor"},...);
//
// - The instance name of an UVM child of an VMM parent should be prefixed
//   with the instance name of the VMM parent. The instance name of a VMM
//   child of a VMM parent should be prefixed in the same manner if the VMM
//   child contains any UVM components, directly or indirectly. This ensures
//   that the name of the UVM descendants receive a unique name.
//
//   | VMM env instantiating UVM and VMM children in build method:
//   |
//   | virtual function build();
//   |   o_comp = new({log.get_name(),".o_comp"},this);
//   |   xactor = new("Xactor Name","Xactor Inst",...);
//   |
//   | VMM subenv/xactor instantiating UVM and VMM children in
//   | constructor:
//   |
//   | function new(string name, string inst, ...);
//   |   super.new(name,inst,...);
//   |   o_comp = new({inst,".o_comp"},this);
//   |   xactor = new("Xactor Name","Xactor Inst",...);
//
// The instance names given any component containing any UVM component, directly
// or indirectly, should contain only alpha-numerics and underscores.
//
// We now present the example in series of steps that might emulate how a mixed
// testbench environment evolves.
//
//------------------------------------------------------------------------------

//------------------------------------------------------------------------------
//
// Group: Step 1 - Simple block-level, mixed environment
//
//------------------------------------------------------------------------------
// We start with a simple mixed, block-level testbench that connects a VMM
// generator to on UVM driver via the <avt_channel2uvm_tlm> adapter. 
//
// (see MH_01_block_level.gif)
//
//------------------------------------------------------------------------------

// (begin inline source)
class block_env extends uvm_component;

  `uvm_component_utils(block_env)

  vmm_apb_rw_atomic_gen gen;
  apb_channel2uvm_tlm       adapt;
  uvm_driver_req        drv;
  apb_scoreboard        compare;

  bit PASS  = 0;

  function new (string name="block_env",uvm_component parent=null);
    super.new(name,parent);
  endfunction

  virtual function void build();
    gen   = new("gen", 0);
    adapt = new("adapt", this, gen.out_chan);
    drv   = new("drv", this);
    void'(get_config_int("max_trans",drv.max_trans));
    compare = new("comparator", this, gen.out_chan);
    gen.out_chan.tee_mode(1);
  endfunction

  virtual function void connect();
    drv.seq_item_port.connect(adapt.seq_item_export);
    drv.ap.connect(compare.uvm_in);
  endfunction

  virtual task run();
    gen.start_xactor();
    gen.notify.wait_for(vmm_apb_rw_atomic_gen::DONE);
    uvm_top.stop_request();
  endtask

  virtual function void check();
    if(compare.m_matches >= 1 && compare.m_mismatches == 0)
      PASS  = 1;
  endfunction // check

  virtual function void report();
    if(PASS == 1) begin
      //OVM2UVM> `UVM_REPORT_INFO("PASS","Test PASSED");
      `uvm_info("PASS","Test PASSED", UVM_MEDIUM);  //OVM2UVM>
    end
    else begin
      //OVM2UVM> `UVM_REPORT_ERROR("FAIL","Test FAILED");
      `uvm_info("FAIL","Test FAILED", UVM_MEDIUM);  //OVM2UVM>
    end
  endfunction // report
endclass
// (end inline source)


//------------------------------------------------------------------------------
//
// Group: Step 2 - Define an UVM IP block
//
//------------------------------------------------------------------------------
// At some point, we may decide to encapsulate the block-level testbench in an
// UVM IP block for reuse at the system level.  Doing this does not take much
// effort, as we can simply extend the existing block-level env to change its
// role from top-level env to a reusable subcomponent as follows:
//
// - promote the underlying driver's analysis port to the IP block-level for
// possible connection by external components.
//
// - override the run task to not govern the end-of-test via stop_request.
// The IP is now a mere participant.
//
// (see MH_02_uvm_ip.gif)
//
//------------------------------------------------------------------------------

// (begin inline source)
class uvm_ip extends block_env;

  `uvm_component_utils(uvm_ip)
  
  uvm_analysis_port #(uvm_apb_rw) ap;

  function new(string name, uvm_component parent=null);
    super.new(name,parent);
  endfunction

  function void build();
    super.build();
    ap = new ("ap",this);
  endfunction

  function void connect();
    super.connect();
    drv.ap.connect(ap);
  endfunction

  virtual task run();
    gen.start_xactor();
  endtask

endclass
// (end inline source)

//-------------------------------------------------------------------------------
// 
// Group: Step 3 - Define a VMM IP block - Part A
//
//------------------------------------------------------------------------------
//
// First encapsulate all UVM children with an UVM component wrapper that can
// make all port connections at the appropriate time.
//
// As we define new environments from pieces of existing IP and block-
// level components, we may find ourselves wanting to integrate the ~uvm_ip~
// with a VMM xactor and enclose that in a VMM subenv IP block. Such a
// pairing requires a connection from the ~uvm_ip~'s analysis export to the
// analysis export of a <vmm_analysis_adapter>. The adapter and VMM consumer
// will then share a ~vmm_channel~ to complete the connection.
//
// But there's one small catch. The ~uvm_ip~ analysis port will not exist
// until after its build phase, which means we can not attempt an analysis
// port connection in the constructor of the VMM subenv. 
//
// ~The best approach is to enclose all sibling UVM components with a parent UVM
// component whose job is to build and connect the UVM components per the UVM
// use model.~
//
// The UVM wrapper, after making all UVM port connections between sibling
// components, would present only the vmm_channel connection to its VMM
// parent.
//
// (see MH_03_vmm_ip.gif)
//
// In this example, the wrapper will make the connection from the ~uvm_ip~
// analysis port to the analysis2notify adapter's analysis export during the
// connect phase, thus relieving the VMM parent from that responsibility.
// As with most VMM components, the wrapper can either be assigned a channel
// via its constructor or provide the channel via its ~out_chan~ property. 
//
//------------------------------------------------------------------------------

// (begin inline source)
class uvm_private_wrapper extends uvm_component;

  `uvm_component_utils(uvm_private_wrapper)

  uvm_ip o_ip;
  apb_analysis_channel v_ap_adapter;
  
  vmm_channel_typed #(vmm_apb_rw) out_chan;

  function new(string name,
               uvm_component parent=null,
               vmm_channel_typed#(vmm_apb_rw) out_chan=null);
    super.new(name,parent);
    this.out_chan = out_chan;
  endfunction

  virtual function void build();
    o_ip = new("o_ip",this);
    v_ap_adapter = new("v_ap_adapter", this, out_chan);
    if (out_chan == null)
      out_chan = v_ap_adapter.chan;
  endfunction

  virtual function void connect();
    o_ip.ap.connect(v_ap_adapter.analysis_export);
  endfunction

endclass
// (end inline source)

//------------------------------------------------------------------------------
// 
// Group: Step 3 - Define a VMM IP block - Part B
//
//------------------------------------------------------------------------------
//
// Then, define the VMM IP block, which instantiates the UVM wrapper and other
// VMM components.
//
// In this example, we instantiate the VMM consumer and UVM wrapper. We connect
// them by making sure they share the same vmm_channel.
//
// (see MH_03_vmm_ip.gif)
//
// In compliance with the VMM use model, the subenv builds itself solely in its
// constructor. We also define the configure, start, stop, and cleanup methods,
// per methodology requirements. 
//
// When naming the VMM consumer and UVM wrapper, we include the instance name
// of the ~vmm_ip~ parent. This ensures that any UVM sub-components all receive
// a unique hierarchical name.
//
// We also employ the UVM set_config interface to map the max_trans VMM config
// parameter from the vmm_ip_cfg object to an UVM configuration parameter
// used by the underlying UVM ip. Here, too, we prepend the vmm_ip's instance
// name when making the call.
//
//------------------------------------------------------------------------------

// (begin inline source)
class vmm_ip_cfg;
  int max_trans=0;
endclass


class vmm_ip extends vmm_subenv;

  uvm_private_wrapper o_wrapper;
  vmm_consumer #(vmm_apb_rw) v_consumer;

  vmm_consensus end_vote;

  function new(string inst, vmm_ip_cfg cfg, vmm_consensus end_vote);

    super.new("vmm_ip", inst, end_vote);
    this.end_vote = end_vote;

    v_consumer = new({inst,".v_consumer"},0);
    o_wrapper  = new({inst,".o_wrapper"},,v_consumer.in_chan);

    v_consumer.stop_after_n_insts = cfg.max_trans;
    set_config_int({inst,".o_wrapper.o_ip"},"max_trans",cfg.max_trans);

    end_vote.register_notification(v_consumer.notify,v_consumer.DONE);

  endfunction

  task configure();
    super.configured();
  endtask

  virtual task start();
    super.start();
    v_consumer.start_xactor();
  endtask

  virtual task stop();
    super.stop();
  endtask

  virtual task cleanup();
    super.cleanup();
  endtask

endclass
// (end inline source)


//-------------------------------------------------------------------------------
// Group: Step 4 - VMM top-level
//
// Let us now consider a vmm_env that contains our ~vmm_ip~ block and, optionally,
// other instances of UVM IP and VMM IP. If our env had UVM children needing port
// connections, we would wrap them as we did for the uvm_private_wrapper above.
//
// When we instantiate the VMM IP in the build method, we provide an instance
// name that includes the env's name, which is retrieved from its log object.
// We do this to ensure the embedded UVM IP gets unique name.
//
// (see MH_04_vmm_on_top.gif)
//
//-------------------------------------------------------------------------------

// (begin inline source)
class tb_env extends vmm_env;

  vmm_ip_cfg cfg;

  vmm_ip v_ip;
  uvm_ip o_ip;
  //vmm_ip2 v_ip2;
  
  function new(string name="");
    super.new(name==""?"mixed_tb_env":name);
  endfunction

  virtual function void gen_cfg();
    super.gen_cfg();
    cfg = new;
    // we could randomize, but we won't
    cfg.max_trans = 10;
  endfunction

  virtual function void build();
    super.build();
    v_ip = new({log.get_name(),".v_ip"},cfg,end_vote);
    o_ip = new({log.get_name(),".env_o_ip"});
  endfunction

  virtual task cfg_dut();
    super.cfg_dut();
    v_ip.configure();
  endtask

  virtual task start();
    super.start();
    v_ip.start();
  endtask

  task wait_for_end();
    super.wait_for_end();
    fork
      end_vote.wait_for_consensus();  
    join
    global_stop_request();
  endtask

endclass
// (end inline source)


//-------------------------------------------------------------------------------
//
// Group: Step 5 - UVM sub-component level 
//
//-------------------------------------------------------------------------------
//
// We can easily encapsulate our ~tb_env~ above for reuse as an uvm_component by
// extending a <avt_uvm_vmm_env> specialization, ~avt_uvm_vmm_env #(tb_env)~.
//
// In this example, we wrap the ~tb_env~ to provide UVM users access to the env's
// config object via the UVM configuration mechanism.
//
// Our new ~uvm_subcomp~ can now be used like any other UVM component
//
// (see MH_05_mixed_hierarchy.gif)
//
//-------------------------------------------------------------------------------

// (begin inline source)
class uvm_subcomp extends avt_uvm_vmm_env_named #(tb_env);

  `uvm_component_utils(uvm_subcomp)

  function new (string name="uvm_subcomp", uvm_component parent=null);
      super.new(name,parent);
  endfunction

  virtual function void vmm_gen_cfg();
    uvm_object obj;
    super.vmm_gen_cfg();
    if (get_config_object("cfg",obj,0)) begin
      uvm_container #(vmm_ip_cfg) v_cfg;
      assert($cast(v_cfg,obj));
      env.cfg = v_cfg.obj;
    end
  endfunction

endclass
// (end inline source)


//-------------------------------------------------------------------------------
//
// Group: Step 6 - UVM top-level
//
// Let us now consider an ~uvm_env~ that contains our ~uvm_subcomp~ block and,
// optionally, other instances of UVM IP and VMM IP. Because the parent (this)
// and child (subcomp) are both UVM components, we do not need to include the
// parent's full name in the name we give the child.
//
//-------------------------------------------------------------------------------

// (begin inline source)
class uvm_env extends uvm_component;

  `uvm_component_utils(uvm_env)

  uvm_subcomp subcomp;

  function new (string name="uvm_env", uvm_component parent=null);
    super.new(name,parent);
  endfunction

  virtual function void build();
    super.build();
    subcomp = new("subcomp",this);
  endfunction

endclass
// (end inline source)


//-------------------------------------------------------------------------------
//
// Group: Step 7 - Module
//
// Although we can continue the sandwiching of UVM and VMM components
// indefinitely, we stop at this point by instantiating the ~uvm_env~ as a
// top-level component. Future integrations could reuse the ~uvm_env~ as a
// child or grandchild of larger system-level environment, but we have to
// stop somewhere.
//
// As part of configuration of the uvm_env, we use the UVM's configuration
// mechanism to set the configuration object that will be used by the
// underlying vmm_subenv. We also use it to set each generator's max number
// of transactions.
//
//-------------------------------------------------------------------------------

// (begin inline source)
module example_05_mixed_hierarchy;

  uvm_env top = new("top");
  
  vmm_ip_cfg v_cfg = new;
  uvm_container #(vmm_ip_cfg) cfg = new(v_cfg);

  initial begin

    // configure the vmm consumer in the vmm_subenv instance
    // to finish after 2 transactions. 
    v_cfg.max_trans = 2;
    set_config_object("top.subcomp","cfg",cfg,0);

    // configure the vmm generator in the uvm_ip instance
    // in top.subcomp to finish in 2 transactions.
    set_config_int("top.subcomp.v_ip.o_wrapper.o_ip","max_trans",2);

    // configure embedded generator in uvm ip to
    // finish in 3 transactions
    set_config_int("top.subcomp.env_o_ip","max_trans",3);

    run_test();
  end

endmodule
// (end inline source)


