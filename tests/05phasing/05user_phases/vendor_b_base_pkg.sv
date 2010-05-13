// This package is for vendor B. Vendor B has a set of user defined
// phases which run in different places. After Vendor B is done, the
// phase list should look something like (ignoring deprecated phases):
//
// build                  (built-in function phase)
// connect                (built-in function phase)
// end_of_elaboration     (built-in function phase)
// start_of_simulation    (built-in function phase)
// vb_reset               (vendor B reset task phase)
// run                    (built-in task phase)
// extract                (built-in function phase)
// check                  (built-in function phase)
// report                 (built-in function phase)
// vb_shutdown            (vendor B shutdown task phase)
// vb_post_shutdown       (vendor B post shutdown run phase)

`include "uvm_macros.svh"
package vb_base_pkg;
  import uvm_pkg::*;

  //define vendor B phases
  `uvm_phase_task_decl(vb_reset, 0)
  `uvm_phase_task_decl(vb_shutdown, 0)
  `uvm_phase_func_decl(vb_post_shutdown, 0)

  typedef class vb_component;
  typedef class vb_env;
  
  vb_reset_phase#(vb_component)          vb_reset_ph;
  vb_reset_phase#(vb_env)                vb_reset_env_ph;
  vb_shutdown_phase#(vb_component)       vb_shutdown_ph;
  vb_shutdown_phase#(vb_env)             vb_shutdown_env_ph;
  vb_post_shutdown_phase#(vb_component)  vb_post_shutdown_ph;
  vb_post_shutdown_phase#(vb_env)        vb_post_shutdown_env_ph;
   
  class vb_component extends uvm_component;
    string last_ph = "<none>";
    `uvm_component_utils(vb_component)


    function new(string name, uvm_component parent);
      super.new(name, parent);
      if(vb_reset_ph == null) begin
        vb_reset_ph = new;
        vb_shutdown_ph = new;
        vb_post_shutdown_ph = new;
        uvm_top.insert_phase(vb_reset_ph, start_of_simulation_ph);
        uvm_top.insert_phase(vb_shutdown_ph, report_ph);
        uvm_top.insert_phase(vb_post_shutdown_ph, vb_shutdown_ph);
      end
    endfunction

    virtual function void build();
      super.build();
      assert (last_ph == "<none>") 
        uvm_report_info("build", { "Got expected last phase, ", last_ph });
      else begin
         `uvm_error("build", { "did not get expected last phase, <none>, got ", last_ph });
        $fatal;
      end
      last_ph = "build";
    endfunction
    virtual function void connect();
      assert (last_ph == "build") 
        uvm_report_info("connect", { "Got expected last phase, ", last_ph });
      else begin
         `uvm_error("TEST", $psprintf("In component %0s: expected last phase to be build, but was %s", get_full_name(), last_ph));
        $fatal;
      end
      last_ph = "connect";
    endfunction
    virtual function void end_of_elaboration();
      assert (last_ph == "connect") 
        uvm_report_info("end_of_elaboration", { "Got expected last phase, ", last_ph });
      else begin
         `uvm_error("TEST", $psprintf("In component %0s: expected last phase to be connect, but was %s", get_full_name(), last_ph));
        $fatal;
      end
      last_ph = "connect";
    endfunction
    virtual function void start_of_simulation();
      assert (last_ph == "connect") 
        uvm_report_info("start_of_simulation", { "Got expected last phase, ", last_ph });
      else begin
         `uvm_error("TEST", $psprintf("In component %0s: expected last phase to be connect, but was %s", get_full_name(), last_ph));
        $fatal;
      end
      last_ph = "start_of_simulation";
    endfunction
    virtual task vb_reset();
      assert (last_ph == "start_of_simulation") 
        uvm_report_info("vb_reset", { "Got expected last phase, ", last_ph });
      else begin
         `uvm_error("TEST", $psprintf("In component %0s: expected last phase to be start_of_simulation, but was %s", get_full_name(), last_ph));
        $fatal;
      end
      last_ph = "vb_reset";
    endtask
    virtual task run();
      assert (last_ph == "vb_reset") 
        uvm_report_info("run", { "Got expected last phase, ", last_ph });
      else begin
         `uvm_error("TEST", $psprintf("In component %0s: expected last phase to be vb_reset, but was %s", get_full_name(), last_ph));
      end
      last_ph = "run";
    endtask
    virtual function void extract();
      assert (last_ph == "run") 
        uvm_report_info("extract", { "Got expected last phase, ", last_ph });
      else begin
         `uvm_error("TEST", $psprintf("In component %0s: expected last phase to be run, but was %s", get_full_name(), last_ph));
        $fatal;
      end
      last_ph = "extract";
    endfunction
    virtual function void check();
      assert (last_ph == "extract") 
        uvm_report_info("check", { "Got expected last phase, ", last_ph });
      else begin
         `uvm_error("TEST", $psprintf("In component %0s: expected last phase to be extract, but was %s", get_full_name(), last_ph));
        $fatal;
      end
      last_ph = "check";
    endfunction
    virtual function void report();
      assert (last_ph == "check") 
        uvm_report_info("report", { "Got expected last phase, ", last_ph });
      else begin
         `uvm_error("TEST", $psprintf("In component %0s: expected last phase to be check, but was %s", get_full_name(), last_ph));
        $fatal;
      end
      last_ph = "report";
    endfunction
    virtual task vb_shutdown();
      assert (last_ph == "report") 
        uvm_report_info("vb_shutdown", { "Got expected last phase, ", last_ph });
      else begin
         `uvm_error("TEST", $psprintf("In component %0s: expected last phase to be report, but was %s", get_full_name(), last_ph));
        $fatal;
      end
      last_ph = "vb_shutdown";
    endtask
    virtual function void vb_post_shutdown();
      assert (last_ph == "vb_shutdown") 
        uvm_report_info("vb_post_shutdown", { "Got expected last phase, ", last_ph });
      else begin
         `uvm_error("TEST", $psprintf("In component %0s: expected last phase to be vb_shutdown, but was %s", get_full_name(), last_ph));
        $fatal;
      end
      last_ph = "vb_post_shutdown";
    endfunction
  endclass 

  class vb_env extends uvm_env;

    string last_ph = "<none>";
    `uvm_component_utils(vb_env)
    function new(string name, uvm_component parent);
      super.new(name, parent);
      if(vb_reset_env_ph == null) begin
        vb_reset_env_ph = new;
        vb_shutdown_env_ph = new;
        vb_post_shutdown_env_ph = new;
        uvm_top.insert_phase(vb_reset_env_ph, start_of_simulation_ph);
        uvm_top.insert_phase(vb_shutdown_env_ph, report_ph);
        uvm_top.insert_phase(vb_post_shutdown_env_ph, vb_shutdown_env_ph);
      end
    endfunction

    virtual function void build();
      super.build();
      assert (last_ph == "<none>") 
        uvm_report_info("build", { "Got expected last phase, ", last_ph });
      else begin
         `uvm_error("TEST", $psprintf("In component %0s: expected last phase to be <none>, but was %s", get_full_name(), last_ph));
        $fatal;
      end
      last_ph = "build";
    endfunction
    virtual function void connect();
      assert (last_ph == "build") 
        uvm_report_info("connect", { "Got expected last phase, ", last_ph });
      else begin
         `uvm_error("TEST", $psprintf("In component %0s: expected last phase to be build, but was %s", get_full_name(), last_ph));
        $fatal;
      end
      last_ph = "connect";
    endfunction
    virtual function void end_of_elaboration();
      assert (last_ph == "connect") 
        uvm_report_info("end_of_elaboration", { "Got expected last phase, ", last_ph });
      else begin
         `uvm_error("TEST", $psprintf("In component %0s: expected last phase to be connect, but was %s", get_full_name(), last_ph));
        $fatal;
      end
      last_ph = "end_of_elaboration";
    endfunction
    virtual function void start_of_simulation();
      assert (last_ph == "end_of_elaboration") 
        uvm_report_info("start_of_simulation", { "Got expected last phase, ", last_ph });
      else begin
         `uvm_error("TEST", $psprintf("In component %0s: expected last phase to be end_of_elaboration, but was %s", get_full_name(), last_ph));
        $fatal;
      end
      last_ph = "start_of_simulation";
    endfunction
    virtual task vb_reset();
      assert (last_ph == "start_of_simulation") 
        uvm_report_info("vb_reset", { "Got expected last phase, ", last_ph });
      else begin
         `uvm_error("TEST", $psprintf("In component %0s: expected last phase to be start_of_simulation, but was %s", get_full_name(), last_ph));
        $fatal;
      end
      last_ph = "vb_reset";
    endtask
    virtual task run();
      assert (last_ph == "vb_reset") 
        uvm_report_info("run", { "Got expected last phase, ", last_ph });
      else begin
         `uvm_error("TEST", $psprintf("In component %0s: expected last phase to be vb_reset, but was %s", get_full_name(), last_ph));
        $fatal;
      end
      last_ph = "run";
    endtask
    virtual function void extract();
      assert (last_ph == "run") 
        uvm_report_info("extract", { "Got expected last phase, ", last_ph });
      else begin
         `uvm_error("TEST", $psprintf("In component %0s: expected last phase to be run, but was %s", get_full_name(), last_ph));
        $fatal;
      end
      last_ph = "extract";
    endfunction
    virtual function void check();
      assert (last_ph == "extract") 
        uvm_report_info("check", { "Got expected last phase, ", last_ph });
      else begin
         `uvm_error("TEST", $psprintf("In component %0s: expected last phase to be extract, but was %s", get_full_name(), last_ph));
        $fatal;
      end
      last_ph = "check";
    endfunction
    virtual function void report();
      assert (last_ph == "check") 
        uvm_report_info("report", { "Got expected last phase, ", last_ph });
      else begin
         `uvm_error("TEST", $psprintf("In component %0s: expected last phase to be check, but was %s", get_full_name(), last_ph));
        $fatal;
      end
      last_ph = "report";
    endfunction
    virtual task vb_shutdown();
      assert (last_ph == "report") 
        uvm_report_info("vb_shutdown", { "Got expected last phase, ", last_ph });
      else begin
         `uvm_error("TEST", $psprintf("In component %0s: expected last phase to be report, but was %s", get_full_name(), last_ph));
        $fatal;
      end
      last_ph = "vb_shutdown";
    endtask
    virtual function void vb_post_shutdown();
      assert (last_ph == "vb_shutdown") 
        uvm_report_info("vb_post_shutdown", { "Got expected last phase, ", last_ph });
      else begin
         `uvm_error("TEST", $psprintf("In component %0s: expected last phase to be vb_shutdown, but was %s", get_full_name(), last_ph));
        $fatal;
      end
      last_ph = "vb_post_shutdown";
    endfunction
  endclass 

endpackage : vb_base_pkg

