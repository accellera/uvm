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

program top;

import uvm_pkg::*;
`include "uvm_macros.svh"

// This test needs lots of messaging and checks for correct number.

class test extends uvm_test;

   bit pass_the_test = 1;

   `uvm_component_utils(test)

   function new(string name, uvm_component parent);
      super.new(name, parent);
   endfunction

   virtual function void messages(string phase);
     `uvm_info({phase,"_none"}, {"none message from ",phase}, UVM_NONE)
     `uvm_info({phase,"_low"}, {"low message from ",phase}, UVM_LOW)
     `uvm_info({phase,"_med"}, {"med message from ",phase}, UVM_MEDIUM)
     `uvm_info({phase,"_high"}, {"high message from ",phase}, UVM_HIGH)
     `uvm_info({phase,"_full"}, {"full message from ",phase}, UVM_FULL)
   endfunction

   virtual function void build();
     messages("build");
   endfunction

   virtual function void connect();
     messages("connect");
   endfunction

   virtual function void end_of_elaboration();
     messages("end_of_elaboration");
   endfunction

   virtual function void start_of_simulation();
     messages("start_of_simulation");
   endfunction

   virtual function void extract();
     messages("extract");
   endfunction

   virtual function void check();
     messages("check");
   endfunction

   virtual function void report();
     messages("report");
   endfunction

   virtual task run_phase(uvm_phase phase);
      phase.raise_objection(this);
      #100;
      messages("run");
      #200;
      messages("run");
      #700;
      messages("run");
      phase.drop_objection(this);
   endtask


   //-- Settings from the command line
   //
   //+UVM_VERBOSITY=UVM_MEDIUM
   //+uvm_set_verbosity=uvm_test_top,_ALL_,UVM_LOW,build
   //+uvm_set_verbosity=uvm_test_top,_ALL_,UVM_FULL,connect
   //+uvm_set_verbosity=uvm_test_top,_ALL_,UVM_NONE,end_of_elaboration
   //+uvm_set_verbosity=*,_ALL_,UVM_HIGH,start_of_simulation
   //+uvm_set_verbosity=uvm_test_top,_ALL_,UVM_NONE,time,200
   //+uvm_set_verbosity=*,_ALL_,UVM_MEDIUM,time,800
   //+uvm_set_verbosity=uvm_test_top,_ALL_,UVM_NONE,extract
   //+uvm_set_verbosity=*,_ALL_,UVM_FULL,check
   //+uvm_set_verbosity=*,_ALL_,UVM_LOW,report

   virtual function void final_phase(uvm_phase phase);
     uvm_report_server rs = uvm_report_server::get_server();

     //Should get none and low in build
     pass_the_test &= check_counts("build", UVM_LOW, 1);
     pass_the_test &= check_counts("connect", UVM_FULL, 1);
     pass_the_test &= check_counts("end_of_elaboration", UVM_NONE, 1);
     pass_the_test &= check_counts("start_of_simulation", UVM_HIGH, 1);
     pass_the_test &= check_counts("extract", UVM_NONE, 1);
     pass_the_test &= check_counts("check", UVM_FULL, 1);
     pass_the_test &= check_counts("report", UVM_LOW, 1);

     // During run, verbosity should be:
     //  0-200   HIGH
     //  200-800 NONE
     //  800+    MEDIUM
     if(rs.get_id_count("run_none") != 3) begin
       $write("** UVM TEST FAILED -- got %0d run_none messages, expected 3 **\n", rs.get_id_count("run_none"));
       pass_the_test = 0;
     end
     if(rs.get_id_count("run_low") != 2) begin
       $write("** UVM TEST FAILED -- got %0d run_low messages, expected 2 **\n", rs.get_id_count("run_low"));
       pass_the_test = 0;
     end
     if(rs.get_id_count("run_med") != 2) begin
       $write("** UVM TEST FAILED -- got %0d run_med messages, expected 2 **\n", rs.get_id_count("run_med"));
       pass_the_test = 0;
     end
     if(rs.get_id_count("run_high") != 1) begin
       $write("** UVM TEST FAILED -- got %0d run_high messages, expected 1 **\n", rs.get_id_count("run_high"));
       pass_the_test = 0;
     end
     if(rs.get_id_count("run_full") != 0) begin
       $write("** UVM TEST FAILED -- got %0d run_full messages, expected 0 **\n", rs.get_id_count("run_full"));
       pass_the_test = 0;
     end


     if(pass_the_test)
       $write("** UVM TEST PASSED **\n");
   endfunction

   function int check_counts(string ph, uvm_verbosity v, int num);
     uvm_report_server rs = uvm_report_server::get_server();
     uvm_verbosity vs[$];
     string v_str[$];
     string msg;

     vs.push_back(UVM_NONE); vs.push_back(UVM_LOW); vs.push_back(UVM_MEDIUM);
     vs.push_back(UVM_HIGH); vs.push_back(UVM_FULL); 
     v_str.push_back("none"); v_str.push_back("low"); v_str.push_back("med");
     v_str.push_back("high"); v_str.push_back("full"); 

     check_counts=1;
     foreach(vs[verb]) begin
       if(v<vs[verb]) num = 0;
       msg = {ph,"_", v_str[verb]};
     

       if(rs.get_id_count(msg) != num) begin
         $write("** UVM TEST FAILED -- got %0d %s messages, expected %0d **\n", rs.get_id_count(msg), msg, num);
         check_counts = 0;
       end
     end
   endfunction
endclass


initial
  begin
     run_test();
  end

endprogram
