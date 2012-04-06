//---------------------------------------------------------------------- 
//   Copyright 2011 Mentor Graphics Corporation
//   All Rights Reserved Worldwide 
// 
//   Licensed under the Apache License, Version 2.0 (the 
//   "License"); you may not use this file except in 
//   compliance with the License.  You may obtain a copy of 
//   the License at 
// 
//       http://www.apache.org/licenses/LICENSE-2.0 
// 
//   Unless required by applicable law or agreed to in 
//   writing, software distributed under the License is 
//   distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR 
//   CONDITIONS OF ANY KIND, either express or implied.  See 
//   the License for the specific language governing 
//   permissions and limitations under the License. 
//----------------------------------------------------------------------

// This test creates a simple hierarchy and makes sure that phases
// start at the correct time. The env has no delays in it so all
// phase processed in the env end immediately.

module test;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  bit failed = 0;
  int index[uvm_phase];
  int phases;

  class test extends uvm_component;

    `uvm_component_utils(test)

    uvm_phase build_ph;
    uvm_phase connect_ph;
    uvm_phase end_of_elaboration_ph;
    uvm_phase start_of_simulation_ph;
    uvm_phase run_ph;
    uvm_phase extract_ph;
    uvm_phase check_ph;
    uvm_phase report_ph;
    uvm_phase final_ph;
    uvm_phase pre_reset_ph;
    uvm_phase reset_ph;
    uvm_phase post_reset_ph;
    uvm_phase pre_configure_ph;
    uvm_phase configure_ph;
    uvm_phase post_configure_ph;
    uvm_phase pre_main_ph;
    uvm_phase main_ph;
    uvm_phase post_main_ph;
    uvm_phase pre_shutdown_ph;
    uvm_phase shutdown_ph;
    uvm_phase post_shutdown_ph;

    function new(string name, uvm_component parent);
      super.new(name,parent);
    endfunction

    function void set_up_index();
        uvm_domain l_uvm_domain = uvm_domain::get_uvm_domain() ;
        uvm_domain l_common_domain = uvm_domain::get_common_domain() ;
        
        build_ph               = l_common_domain.find_by_name("build");
        connect_ph             = l_common_domain.find_by_name("connect");
        end_of_elaboration_ph  = l_common_domain.find_by_name("end_of_elaboration");
        start_of_simulation_ph = l_common_domain.find_by_name("start_of_simulation");
        run_ph                 = l_common_domain.find_by_name("run");
        extract_ph             = l_common_domain.find_by_name("extract");
        check_ph               = l_common_domain.find_by_name("check");
        report_ph              = l_common_domain.find_by_name("report");
        final_ph               = l_common_domain.find_by_name("final");
        pre_reset_ph           = l_uvm_domain.find_by_name("pre_reset");
        reset_ph               = l_uvm_domain.find_by_name("reset");
        post_reset_ph          = l_uvm_domain.find_by_name("post_reset");
        pre_configure_ph       = l_uvm_domain.find_by_name("pre_configure");
        configure_ph           = l_uvm_domain.find_by_name("configure");
        post_configure_ph      = l_uvm_domain.find_by_name("post_configure");
        pre_main_ph            = l_uvm_domain.find_by_name("pre_main");
        main_ph                = l_uvm_domain.find_by_name("main");
        post_main_ph           = l_uvm_domain.find_by_name("post_main");
        pre_shutdown_ph        = l_uvm_domain.find_by_name("pre_shutdown");
        shutdown_ph            = l_uvm_domain.find_by_name("shutdown");
        post_shutdown_ph       = l_uvm_domain.find_by_name("post_shutdown");

        $display("uvm_build_ph id is %0d type=%s",build_ph.get_inst_id(),build_ph.get_phase_type());
      //index[uvm_build_ph]               = 1;
      index[build_ph]               = 1;
      index[connect_ph]             = 2;
      index[end_of_elaboration_ph]  = 3;
      index[start_of_simulation_ph] = 4;

      index[run_ph]                 = 5;

      index[pre_reset_ph]           = 6;
      index[reset_ph]               = 7;
      index[post_reset_ph]          = 8;
      index[pre_configure_ph]       = 9;
      index[configure_ph]           = 10;
      index[post_configure_ph]      = 11;
      index[pre_main_ph]            = 12;
      index[main_ph]                = 13;
      index[post_main_ph]           = 14;
      index[pre_shutdown_ph]        = 15;
      index[shutdown_ph]            = 16;
      index[post_shutdown_ph]       = 17;

      index[extract_ph]             = 18;
      index[check_ph]               = 19;
      index[report_ph]              = 20;
      index[final_ph]               = 21;
    endfunction

    function void phase_started(uvm_phase phase);
      uvm_phase imp = phase;
      int spread;
      bit is, isb, isa;
      static bit done;
      $write ("phase_started: imp=%s (%0d)\n",imp.get_name(),imp.get_inst_id());
      if (!done) begin
        set_up_index();
        done = 1;
        /*
        foreach (index[ph])
          $display("index[%s] = %0d (id=%0d)",ph.get_name(),index[ph],ph.get_inst_id());
        $display("imp id is %0d type=%s",imp.get_inst_id(),imp.get_phase_type());
        $display("uvm_build_ph id is %0d type=%s",build_ph.get_inst_id(),build_ph.get_phase_type());
        */
      end

      if (!index.exists(imp)) begin
        `uvm_error("UNKNOWN_PHASE", {"Phase '", imp.get_name(), "' (id=",$sformatf("%0d",imp.get_inst_id()),") not expected. "})
        //$display("uvm_build_ph id is %0d",build_ph.get_inst_id());
      end

      if (phase.is_before(null)) `uvm_error("EXP_NOT_BEFORE",   {"Expected ",phase.get_name(),".is_before(null) to be FALSE"});
      if (phase.is(null)) `uvm_error("EXP_NOT_IS",   {"Expected ",phase.get_name(),".is(null) to be FALSE"});
      if (phase.is_after(null)) `uvm_error("EXP_NOT_AFTER",   {"Expected ",phase.get_name(),".is_after(null) to be FALSE"});
      
      foreach (index[ph]) begin

        is = phase.is(ph);
        isb = phase.is_before(ph);
        isa = phase.is_after(ph);

        spread = (index[imp] - index[ph]);

        if ((imp.get_name() == "run" || ph.get_name() == "run") && (index[ph] >= 6 && index[ph] <= 17 || index[imp] >=6 && index[imp] <= 17)) begin
          if ( isa) `uvm_error("EXP_NOT_AFTER",   {"Expected ",phase.get_name(),".is_after(",ph.get_name(),") to be FALSE"})
          if ( isb) `uvm_error("EXP_NOT_BEFORE",  {"Expected ",phase.get_name(),".is_before(",ph.get_name(),") to be FALSE"})
          if ( is)  `uvm_error("EXP_NOT_IS",      {"Expected ",phase.get_name(),".is(",ph.get_name(),") to be FALSE"})
          continue;
        end

        if (spread > 0) begin
          if (!isa) `uvm_error("EXP_AFTER",      {"Expected ",phase.get_name(),".is_after(",ph.get_name(),") to be TRUE"})
          if ( isb) `uvm_error("EXP_NOT_BEFORE", {"Expected ",phase.get_name(),".is_before(",ph.get_name(),") to be FALSE"})
          if ( is)  `uvm_error("EXP_NOT_IS",     {"Expected ",phase.get_name(),".is(",ph.get_name(),") to be FALSE"})
        end
        if (spread > 0) begin
          if (!isa) `uvm_error("EXP_AFTER",      {"Expected ",phase.get_name(),".is_after(",ph.get_name(),") to be TRUE"})
          if ( isb) `uvm_error("EXP_NOT_BEFORE", {"Expected ",phase.get_name(),".is_before(",ph.get_name(),") to be FALSE"})
          if ( is)  `uvm_error("EXP_NOT_IS",     {"Expected ",phase.get_name(),".is(",ph.get_name(),") to be FALSE"})
        end
        else if (spread == 0) begin
          if ( isa) `uvm_error("EXP_NOT_AFTER",  {"Expected ",phase.get_name(),".is_after(",ph.get_name(),") to be FALSE"})
          if (!is)  `uvm_error("EXP_IS",         {"Expected ",phase.get_name(),".is(",ph.get_name(),") to be TRUE"})
          if ( isb) `uvm_error("EXP_NOT_BEFORE", {"Expected ",phase.get_name(),".is_before(",ph.get_name(),") to be FALSE"})
        end
        else begin
          if ( isa) `uvm_error("EXP_NOT_AFTER",  {"Expected ",phase.get_name(),".is_after(",ph.get_name(),") to be FALSE"})
          if ( is)  `uvm_error("EXP_NOT_IS",     {"Expected ",phase.get_name(),".is(",ph.get_name(),") to be FALSE"})
          if (!isb) `uvm_error("EXP_BEFORE",     {"Expected ",phase.get_name(),".is_before(",ph.get_name(),") to be TRUE"})
        end
      end
      phases++;
    endfunction

    function void phase_ended(uvm_phase phase);
    endfunction

    function void final_phase(uvm_phase phase);
      `uvm_info("FINAL", "Starting Final", UVM_NONE)
      if (phases != 21)
        `uvm_error("NOT ENOUGH PHASES", "Expected 21 phases to be started")
    endfunction

    function void report_phase(uvm_phase phase);
      int failed;
      uvm_report_server svr;
      svr = _global_reporter.get_report_server();
      if (svr.get_id_count("EXP_AFTER")      > 0) failed = 1;
      if (svr.get_id_count("EXP_BEFORE")     > 0) failed = 1;
      if (svr.get_id_count("EXP_IS")         > 0) failed = 1;
      if (svr.get_id_count("EXP_NOT_AFTER")  > 0) failed = 1;
      if (svr.get_id_count("EXP_NOT_BEFORE") > 0) failed = 1;
      if (svr.get_id_count("EXP_NOT_IS")     > 0) failed = 1;

      if(failed) $display("*** UVM TEST FAILED ***");
      else $display("*** UVM TEST PASSED ***");
    endfunction

  endclass

  initial #0 run_test();
endmodule
