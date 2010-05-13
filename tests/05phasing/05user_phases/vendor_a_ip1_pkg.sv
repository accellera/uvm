// This package is for vendor A. This is the actual IP that and end user
// is using.
//

`include "uvm_macros.svh"
package va_ip1_pkg;
  import uvm_pkg::*;
  import va_base_pkg::*;

  class va_simple_component extends va_component;
    int del = 10;
    
    `uvm_component_utils(va_simple_component)
    function new(string name, uvm_component parent);
      super.new(name, parent);
    endfunction

    task stop(string ph_name);
      wait(enable_stop_interrupt==0);
    endtask

    function void build();
      super.build();
      void'(get_config_int("del",del));
      if(del<0) del = 0;
      if(del>1000) del = 1000;
    endfunction

    task va_pre_start();
      enable_stop_interrupt=1;
      super.va_pre_start();
      uvm_report_info("va_pre_start_start", "Starting pre start phase", UVM_LOW);
      #del;
      uvm_report_info("va_pre_start_end", "Ending pre start phase", UVM_LOW);
      enable_stop_interrupt=0;
    endtask

    task va_init();
      enable_stop_interrupt=1;
      super.va_init();
      uvm_report_info("va_init_start", "Starting init phase", UVM_LOW);
      #(1000-del);
      uvm_report_info("va_init_end", "Ending init phase", UVM_LOW);
      enable_stop_interrupt=0;
    endtask

    task va_reset();
      enable_stop_interrupt=1;
      super.va_reset();
      uvm_report_info("va_reset_start", "Starting reset phase", UVM_LOW);
      #del;
      uvm_report_info("va_reset_end", "Ending reset phase", UVM_LOW);
      enable_stop_interrupt=0;
    endtask

    task run();
      enable_stop_interrupt=1;
      super.run();
      uvm_report_info("run_start", "Starting run phase", UVM_LOW);
      #(1000-del);
      uvm_report_info("run_end", "Ending run phase", UVM_LOW);
      enable_stop_interrupt=0;
    endtask

  endclass 

  class va_mid_component extends va_component;
    va_simple_component comp1;
    va_simple_component comp2;
    int del = 30;
    
    `uvm_component_utils(va_mid_component)
    function new(string name, uvm_component parent);
      super.new(name, parent);
    endfunction

    function void build();
      super.build();
      void'(get_config_int("del",del));
      if(del<0) del = 0;
      if(del>1000) del = 1000;
      comp1 = new("comp1", this);
      comp2 = new("comp2", this);
    endfunction

    task stop(string ph_name);
      wait(enable_stop_interrupt==0);
    endtask

    task va_pre_start();
      enable_stop_interrupt=1;
      super.va_pre_start();
      uvm_report_info("va_pre_start_start", "Starting pre start phase", UVM_LOW);
      #del;
      uvm_report_info("va_pre_start_end", "Ending pre start phase", UVM_LOW);
      enable_stop_interrupt=0;
    endtask

    task va_init();
      enable_stop_interrupt=1;
      super.va_init();
      uvm_report_info("va_init_start", "Starting init phase", UVM_LOW);
      #(1000-del);
      uvm_report_info("va_init_end", "Ending init phase", UVM_LOW);
      enable_stop_interrupt=0;
    endtask

    task va_reset();
      enable_stop_interrupt=1;
      super.va_reset();
      uvm_report_info("va_reset_start", "Starting reset phase", UVM_LOW);
      #del;
      uvm_report_info("va_reset_end", "Ending reset phase", UVM_LOW);
      enable_stop_interrupt=0;
    endtask

    task run();
      enable_stop_interrupt=1;
      super.run();
      uvm_report_info("run_start", "Starting run phase", UVM_LOW);
      #(1000-del);
      uvm_report_info("run_end", "Ending run phase", UVM_LOW);
      enable_stop_interrupt=0;
    endtask

  endclass

  class va_ip1_env extends va_env;
    va_mid_component mid;
    va_simple_component simp;

    `uvm_component_utils(va_ip1_env)
    function new(string name, uvm_component parent);
      super.new(name, parent);
    endfunction

    function void build();
      super.build();
      set_config_int("simp", "del", 700);
      set_config_int("mid.comp1", "del", 100);
      set_config_int("mid.comp2", "del", 500);
      set_config_int("mid", "del", 300);
      mid = new("mid", this); 
      simp = new("simp", this); 
    endfunction

    task va_pre_start();
      super.va_pre_start();
      #1;
      uvm_report_info("va_pre_start", "Calling global_stop_request for the pre_start() phase",UVM_LOW);
      global_stop_request();
    endtask

    task va_init();
      super.va_init();
      #1 global_stop_request();
    endtask

    task va_reset();
      super.va_reset();
      #1 global_stop_request();
    endtask

    task run();
      super.run();
      #1 global_stop_request();
    endtask

  endclass 

endpackage : va_ip1_pkg

