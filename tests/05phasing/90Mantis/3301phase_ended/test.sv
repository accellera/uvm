//Use run_tests script on the following test.sv:

module test;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  bit failed = 0;
// bit phase_run[uvm_phase_imp];



  class base extends uvm_component;
    bit dodelay=1;
// int phase_count ;
    time thedelay = 300;
// time maxdelay = 5*thedelay;

    function new(string name, uvm_component parent);
      super.new(name,parent);
      set_phase_schedule("uvm");
    endfunction



    task reset;
      if(dodelay) #thedelay;
      `uvm_info("RESET",$psprintf("Finished waiting %d",thedelay),UVM_NONE);
    endtask

    task main;
      if(dodelay) #thedelay;
      `uvm_info("MAIN",$psprintf("Finished waiting %d",thedelay),UVM_NONE);
    endtask

    task shutdown;
      if(dodelay) #thedelay;
      `uvm_info("SHUTDOWN",$psprintf("Finished waiting %d",thedelay),UVM_NONE);
    endtask

    task run;

// if(dodelay) #(5*thedelay);
    endtask


    function void report();
// phase_run[uvm_report_ph] = 1;
// if(phase_run.num() != 7) begin
// failed = 1;
// `uvm_error("NUMPHASES", $sformatf("Expected 7 phases, got %0d", phase_run.num()))
// end
      if(failed) $display("*** UVM TEST FAILED ***");
      else $display("*** UVM TEST PASSED ***");
    endfunction
  endclass

  /////////////////////////////////////////

  class leaf extends base;
    function new(string name, uvm_component parent);
      super.new(name,parent);
    endfunction
  endclass

  /////////////////////////////////////////

  class hier extends base;
    leaf leaf1, leaf2 ;
    int flag = 0 ;
    function new(string name, uvm_component parent);
      super.new(name,parent);
      leaf1 = new("leaf1",this) ;
      leaf1.thedelay = 150 ;
      leaf2 = new("leaf2",this) ;
      leaf2.thedelay = 100 ;
      thedelay = 0 ;
    endfunction
    function void phase_started (uvm_phase_schedule phase);
      `uvm_info("PHASE",$psprintf("Starting %s",phase.get_phase_name()),UVM_NONE);
      if (flag == 1) begin
        `uvm_error("START_END", $sformatf("Missed preceding phase_ended"));
        failed = 1 ;
      end
      flag = 1 ;
// phase_run[uvm_build_ph] = 1;
    endfunction
    function void phase_ended (uvm_phase_schedule phase);
      `uvm_info("PHASE",$psprintf("Ending %s",phase.get_phase_name()),UVM_NONE);
      if (flag == 0) begin
        `uvm_error("START_END", $sformatf("Missed preceding phase_started"));
        failed = 1 ;
      end
      flag = 0 ;
    endfunction
  endclass

  /////////////////////////////////////////

  class test extends base;
    hier dom1, dom2;
    `uvm_component_utils(test)
    function new(string name, uvm_component parent);
      super.new(name,parent);
      thedelay = 0 ;
      dom1 = new("dom1", this);
      dom2 = new("dom2", this);
      dom2.leaf1.thedelay = 75 ;
      dom2.leaf2.thedelay = 50 ;
      dom1.set_phase_domain("domain1");
      dom2.set_phase_domain("domain2");
    endfunction


  endclass

  initial run_test();
endmodule
