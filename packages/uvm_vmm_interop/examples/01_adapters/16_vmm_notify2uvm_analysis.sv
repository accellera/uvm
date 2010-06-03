// Copyright (c) 1991-2009 by Synopsys Inc.
//------------------------------------------------------------------------------
`define VMM_ON_TOP

`include "uvm_macros.svh"
`include "uvm_vmm_pkg.sv"
 
`include "uvm_apb_rw.sv"
`include "vmm_apb_rw.sv"
`include "apb_rw_converters.sv"
 
`include "vmm_producers.sv"
`include "uvm_consumers.sv"
`include "apb_scoreboard.sv"

//------------------------------------------------------------------------------

class env extends `VMM_ENV;

  vmm_notifier  #(vmm_apb_rw) sender;
  uvm_subscribe #(uvm_apb_rw) observer;
  apb_notify2analysis         ntfy2ap;
  apb_scoreboard              compare;
  vmm_apb_rw                  tmp;

  `uvm_build
    
  virtual function void build();
    super.build();
    sender    = new("v_prod");
    observer  = new("o_cons",uvm_top);
    ntfy2ap   = new("ntfy2ap",uvm_top, sender.notify, sender.GENERATED);
    uvm_build();
    ntfy2ap.analysis_port.connect(observer.analysis_export);
    compare  = new("comparator", uvm_top, sender.out_chan,1);
    observer.ap.connect(compare.uvm_in);
  endfunction

  virtual task start();
    super.start();
    tmp  = new();
    sender.start_xactor();
  endtask

  virtual task wait_for_end();
    super.wait_for_end();
    //Stop the simulation after 100 timeunits
    #100;
  endtask

  virtual task report();
    super.report();
    if(compare.m_matches > 0 && compare.m_mismatches == 0)
      `vmm_note(log,"Simulation PASSED");
    else
      `vmm_error(log,"Simulation FAILED");
  endtask // report
  
endclass


program example_16_vmm_notify2uvm_analysis;

  env e = new;

  initial begin
     e.build();
     #10;
     e.run();
  end
   
endprogram