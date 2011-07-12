//
//------------------------------------------------------------------------------
//   Copyright 2011 (Authors)
//   Copyright 2011 Cadence Design Systems, Inc.
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
//------------------------------------------------------------------------------

//Test: Killing phases
//

`include "uvm_macros.svh"
module top;
  import uvm_pkg::*;
`include "common.svh"

class test extends test_base;
  function new(string name = "02killing", uvm_component parent = null);
    super.new(name, parent);
  endfunction : new

  `uvm_component_utils(test)

  task main_phase(uvm_phase phase);
    #20;
    `uvm_info( "KILLING_MAIN", $sformatf("Killing current phase: %s",
                                      phase.get_name()), UVM_NONE);
    phase.phase_done.clear();

  endtask : main_phase

  function void check_phase(uvm_phase phase);
    //normal test
    //  [top_random_seq]    10
    //  [bot_random_seq]    24
    //In this killing test
    //  [top_random_seq]     6
    //  [bot_random_seq]    12

    uvm_report_server svr = _global_reporter.get_report_server();
    int e_km_c =1;
    int km_c   = svr.get_id_count( "KILLING_MAIN" );

    int e_trs_c=6;
    int trs_c  = svr.get_id_count( "top_random_seq" );

    int e_brs_c=12;
    int brs_c  = svr.get_id_count( "bot_random_seq" );

    if( km_c != e_km_c ) begin
      `uvm_error( "ID_COUNT", $sformatf( "Expected %1d %s message(s).  Got %1d",
                                            e_km_c, "KILLING_MAIN", km_c));
    end


    if( trs_c != e_trs_c ) begin
      `uvm_error( "ID_COUNT", $sformatf( "Expected %1d [%s] message(s).  Got %1d",
                                         e_trs_c, "top_random_seq", trs_c));
    end
    if( brs_c != e_brs_c) begin
      `uvm_error( "ID_COUNT", $sformatf( "Expected %1d [%s] message(s).  Got %1d",
                                         e_brs_c, "bottom_random_seq", brs_c));
    end
  endfunction : check_phase


endclass : test

  initial begin
    fork
      run_test();
      #2000 begin
        `uvm_error( "TIMEOUT", "TIME OUT OCCURED." );
      end
    join
  end
endmodule : top
