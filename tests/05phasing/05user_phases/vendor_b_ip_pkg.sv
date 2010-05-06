// This package is for vendor B. This is the actual IP that and end user
// is using. It includes a model from vendor A.
//

`include "uvm_macros.svh"
package vb_ip_pkg;
  import uvm_pkg::*;
  import vb_base_pkg::*;
  import va_ip1_pkg::*;


  class vb_simple_component extends vb_component;
    int del = 10;
    
    `uvm_component_utils(vb_simple_component)
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
    task vb_reset();
      enable_stop_interrupt=1;
      super.vb_reset();
      uvm_report_info("vb_reset_start", "Starting reset phase", UVM_LOW);
      #del;
      uvm_report_info("vb_reset_end", "Ending reset phase", UVM_LOW);
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
    task vb_shutdown();
      enable_stop_interrupt=1;
      super.vb_shutdown();
      uvm_report_info("vb_shutdown_start", "Starting shutdown phase", UVM_LOW);
      #del;
      uvm_report_info("vb_shutdown_end", "Ending shutdown phase", UVM_LOW);
      enable_stop_interrupt=0;
    endtask
  endclass 

  class vb_mid_component extends vb_component;
    vb_simple_component scomp;
    va_ip1_env va_env;
    int del = 30;
    
    `uvm_component_utils(vb_mid_component)
    function new(string name, uvm_component parent);
      super.new(name, parent);
    endfunction
    function void build();
      super.build();
      void'(get_config_int("del",del));
      if(del<0) del = 0;
      if(del>1000) del = 1000;
      scomp = new("scomp", this);
      va_env = new("va_env", this);
    endfunction
    task stop(string ph_name);
      wait(enable_stop_interrupt==0);
    endtask
    task vb_reset();
      enable_stop_interrupt=1;
      super.vb_reset();
      uvm_report_info("vb_reset_start", "Starting reset phase", UVM_LOW);
      #del;
      uvm_report_info("vb_reset_end", "Ending reset phase", UVM_LOW);
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
    task vb_shutdown();
      enable_stop_interrupt=1;
      super.vb_shutdown();
      uvm_report_info("vb_shutdown_start", "Starting shutdown phase", UVM_LOW);
      #del;
      uvm_report_info("vb_shutdown_end", "Ending shutdown phase", UVM_LOW);
      enable_stop_interrupt=0;
    endtask
  endclass

  class vb_ip_env extends vb_env;
    vb_mid_component mid;
    vb_simple_component simp;

    `uvm_component_utils(vb_ip_env)
    function new(string name, uvm_component parent);
      super.new(name, parent);
    endfunction

    function void build();
      super.build();
      set_config_int("simp", "del", 333);
      set_config_int("mid.scomp", "del", 555);
      set_config_int("mid.va_env.simp", "del", 888);
      set_config_int("mid.va_env.mid.comp1", "del", 666);
      set_config_int("mid.va_env.mid.comp2", "del", 444);
      set_config_int("mid", "del", 222);
      mid = new("mid", this); 
      simp = new("simp", this); 
    endfunction
    task vb_reset();
      super.vb_reset();
      #1 global_stop_request();
    endtask
    task run();
      super.run();
      #1 global_stop_request();
    endtask
    task vb_shutdown();
      super.vb_shutdown();
      #1 global_stop_request();
    endtask
  endclass 

endpackage : vb_ip_pkg

