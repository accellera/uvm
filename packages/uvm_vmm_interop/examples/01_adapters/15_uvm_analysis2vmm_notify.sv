// This test shows how to use analysis port for UVM with VMM notify

`define VMM_ON_TOP

`include "uvm_macros.svh"
`include "uvm_vmm_pkg.sv"
 
`include "uvm_apb_rw.sv"
`include "vmm_apb_rw.sv"
`include "apb_rw_converters.sv"

`include "uvm_producers.sv"
`include "vmm_consumers.sv"


class env extends `VMM_ENV;

 
  uvm_publish #(uvm_apb_rw) sender;
  vmm_watcher #(vmm_apb_rw) observer;
  apb_analysis2notify       ap2ntfy;
   
   `uvm_build
  virtual function void build();
    super.build();
    uvm_build();

    sender = new("sender",uvm_top);
    observer = new("observer");
    ap2ntfy = new("ap2ntfy",uvm_top, observer.notify, observer.INCOMING);
    sender.out.connect(ap2ntfy.analysis_export);
  endfunction

  virtual task start();
    super.start();
    observer.start_xactor();
  endtask

  virtual task wait_for_end();
    super.wait_for_end();
    //Stop the simulation after 100 timeunits
    #100;
  endtask

   virtual task stop();
    super.stop();
    observer.stop_xactor();
  endtask

endclass


module example_15_uvm_analysis2vmm_notify;

  env e = new;

  initial begin
     e.build();
     #10;
     e.run();
  end

endmodule