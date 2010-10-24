// This package is for vendor A. Vendor A has a set of user defined
// phases which run in different places. After Vendor A is done, the
// phase list should look something like (ignoring deprecated phases):
//
// build                  (built-in function phase)
// connect                (built-in function phase)
// end_of_elaboration     (built-in function phase)
// va_pre_start           (vendor A pre start task phase)
// start_of_simulation    (built-in function phase)
// va_init                (vendor A initialization task phase)
// va_reset               (vendor A reset task phase)
// run                    (built-in task phase)
// extract                (built-in function phase)
// check                  (built-in function phase)
// report                 (built-in function phase)

`include "uvm_macros.svh"
package va_base_pkg;
  import uvm_pkg::*;

  //define vendor A phases
  `uvm_phase_task_decl(va_pre_start, 0)
  `uvm_phase_task_decl(va_init, 0)
  `uvm_phase_task_decl(va_reset, 0)

  typedef class va_component;
  typedef class va_env;
  
  va_pre_start_phase#(va_component) va_pre_start_ph;
  va_pre_start_phase#(va_env)       va_pre_start_env_ph;
  va_init_phase#(va_component)      va_init_ph;
  va_init_phase#(va_env)            va_init_env_ph;
  va_reset_phase#(va_component)     va_reset_ph;
  va_reset_phase#(va_env)           va_reset_env_ph;
   
  class va_component extends uvm_component;
    string last_ph = "<none>";
    `uvm_component_utils(va_component)

    function new(string name, uvm_component parent);
      super.new(name, parent);
      if(va_pre_start_ph == null) begin
        va_pre_start_ph = new;
        va_init_ph = new;
        va_reset_ph = new;
        uvm_top.insert_phase(va_pre_start_ph, end_of_elaboration_ph);
        uvm_top.insert_phase(va_init_ph, start_of_simulation_ph);
        $display("Inserting va_reset_ph (%s) after va_init_ph (%s)",
                 va_reset_ph.get_name(), va_init_ph.get_name());
        uvm_top.insert_phase(va_reset_ph, va_init_ph);
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
      last_ph = "end_of_elaboration";
    endfunction

    virtual task va_pre_start();
      assert (last_ph == "end_of_elaboration") 
        uvm_report_info("va_pre_start", { "Got expected last phase, ", last_ph });
      else begin
         `uvm_error("TEST", $psprintf("In component %0s: expected last phase to be end_of_elaboration, but was %s", get_full_name(), last_ph));
        $fatal;
      end
      last_ph = "va_pre_start";
    endtask

    virtual function void start_of_simulation();
      assert (last_ph == "va_pre_start") 
        uvm_report_info("start_of_simulation", { "Got expected last phase, ", last_ph });
      else begin
         `uvm_error("TEST", $psprintf("In component %0s: expected last phase to be va_pre_start, but was %s", get_full_name(), last_ph));
        $fatal;
      end
      last_ph = "start_of_simulation";
    endfunction

    virtual task va_init();
      assert (last_ph == "start_of_simulation") 
        uvm_report_info("va_init", { "Got expected last phase, ", last_ph });
      else begin
         `uvm_error("TEST", $psprintf("In component %0s: expected last phase to be start_of_simulation, but was %s", get_full_name(), last_ph));
        $fatal;
      end
      last_ph = "va_init";
    endtask

    virtual task va_reset();
      assert (last_ph == "va_init") 
        uvm_report_info("va_reset", { "Got expected last phase, ", last_ph });
      else begin
         `uvm_error("TEST", $psprintf("In component %0s: expected last phase to be va_init, but was %s", get_full_name(), last_ph));
        $fatal;
      end
      last_ph = "va_reset";
    endtask

    virtual task run();
      assert (last_ph == "va_reset") 
        uvm_report_info("run", { "Got expected last phase, ", last_ph });
      else begin
         `uvm_error("TEST", $psprintf("In component %0s: expected last phase to be va_reset, but was %s", get_full_name(), last_ph));
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
  endclass 

  class va_env extends uvm_env;

    string last_ph = "<none>";
    `uvm_component_utils(va_env)
    function new(string name, uvm_component parent);
      super.new(name, parent);
      if(va_pre_start_env_ph == null) begin
        va_pre_start_env_ph = new;
        va_init_env_ph = new;
        va_reset_env_ph = new;
        uvm_top.insert_phase(va_pre_start_env_ph, end_of_elaboration_ph);
        uvm_top.insert_phase(va_init_env_ph, start_of_simulation_ph);
        uvm_top.insert_phase(va_reset_env_ph, va_init_env_ph);
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
    virtual task va_pre_start();
      assert (last_ph == "end_of_elaboration") 
        uvm_report_info("va_pre_start", { "Got expected last phase, ", last_ph });
      else begin
         `uvm_error("TEST", $psprintf("In component %0s: expected last phase to be end_of_elaboration, but was %s", get_full_name(), last_ph));
        $fatal;
      end
      last_ph = "va_pre_start";
    endtask
    virtual function void start_of_simulation();
      assert (last_ph == "va_pre_start") 
        uvm_report_info("start_of_simulation", { "Got expected last phase, ", last_ph });
      else begin
         `uvm_error("TEST", $psprintf("In component %0s: expected last phase to be va_pre_start, but was %s", get_full_name(), last_ph));
        $fatal;
      end
      last_ph = "start_of_simulation";
    endfunction
    virtual task va_init();
      assert (last_ph == "start_of_simulation") 
        uvm_report_info("va_init", { "Got expected last phase, ", last_ph });
      else begin
         `uvm_error("TEST", $psprintf("In component %0s: expected last phase to be start_of_simulation, but was %s", get_full_name(), last_ph));
        $fatal;
      end
      last_ph = "va_init";
    endtask
    virtual task va_reset();
      assert (last_ph == "va_init") 
        uvm_report_info("va_reset", { "Got expected last phase, ", last_ph });
      else begin
         `uvm_error("TEST", $psprintf("In component %0s: expected last phase to be va_init, but was %s", get_full_name(), last_ph));
        $fatal;
      end
      last_ph = "va_reset";
    endtask
    virtual task run();
      assert (last_ph == "va_reset") 
        uvm_report_info("run", { "Got expected last phase, ", last_ph });
      else begin
         `uvm_error("TEST", $psprintf("In component %0s: expected last phase to be va_reset, but was %s", get_full_name(), last_ph));
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
  endclass 

endpackage : va_base_pkg

