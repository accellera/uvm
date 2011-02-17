//---------------------------------------------------------------------- 
//   Copyright 2010 Cadence Design Systems, Inc. 
//   Copyright 2010 Mentor Graphics Corporation
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

// Test the api's for setting the verbosity based on id and id/severity.
// The following API's are tested:
//    uvm_report_object::set_report_id_verbosity()
//    uvm_report_object::set_report_severity_id_verbosity()
//    uvm_component::set_report_id_verbosity_hier()
//    uvm_component::set_report_severity_id_verbosity_hier()
//
// The test creates a simple three level design with four subtrees
// from the root level. Two trees emit all messages by setting its
// verbosity threshold to UVM_FULL, the other two filter all messages with 
// a threshold of UVM_NONE.
//
// In one tree which emits all messages, one message is targeted to be
// turned off using uvm_report_object::set_report_id_verbosity() and
// one is targeted to be turned off using 
// uvm_report_object::set_report_severity_id_verbosity().
//
// In the other tree which emits all messages, one message is targeted to be
// turned off using uvm_component::set_report_id_verbosity_hier() and
// one is targeted to be turned off using 
// uvm_component::set_report_severity_id_verbosity_hier().
// 
// The other two trees target specific messages to be turned on in the
// same fashion.

module top;

import uvm_pkg::*;
`include "uvm_macros.svh"

class leaf extends uvm_component;
  `uvm_new_func
  task run;
    `uvm_info("NONE_MSG", "A none message from class leaf", UVM_NONE)
    `uvm_info("LOW_MSG", "A low message from class leaf", UVM_LOW)
    `uvm_info("MEDIUM_MSG", "A medium message from class leaf", UVM_MEDIUM)
    `uvm_info("HIGH_MSG", "A high message from class leaf", UVM_HIGH)
    `uvm_info("FULL_MSG", "A full message from class leaf", UVM_FULL)
  endtask
endclass

class middle extends uvm_component;
  leaf leaf1;
  function new(string name, uvm_component parent);
    super.new(name,parent);
    leaf1 = new("leaf1", this);
  endfunction
  task run;
    `uvm_info("NONE_MSG", "A none message from class middle", UVM_NONE)
    `uvm_info("LOW_MSG", "A low message from class middle", UVM_LOW)
    `uvm_info("MEDIUM_MSG", "A medium message from class middle", UVM_MEDIUM)
    `uvm_info("HIGH_MSG", "A high message from class middle", UVM_HIGH)
    `uvm_info("FULL_MSG", "A full message from class middle", UVM_FULL)
  endtask
endclass


class my_catcher extends uvm_report_catcher;
  int cnt[uvm_report_object];
  virtual function action_e catch();
    if(!cnt.exists(get_client())) begin
      cnt[get_client()] = 1;
    end
    else begin
      cnt[get_client()] = cnt[get_client()]+1;
    end

    return THROW;
  endfunction
endclass

class test extends uvm_component;
  middle middle1, middle2, middle3, middle4;
  my_catcher ctchr = new;

  `uvm_component_utils(test)
  function new(string name, uvm_component parent);
    super.new(name,parent);
    middle1 = new("middle1", this);
    middle2 = new("middle2", this);
    middle3 = new("middle3", this);
    middle4 = new("middle4", this);
  endfunction
  function void start_of_simulation();
      uvm_report_cb::add(null,ctchr);

      //middle1 and middle2 have the verbosity turned on full so they
      //emit all by default
      middle1.set_report_verbosity_level_hier(UVM_FULL);
      middle2.set_report_verbosity_level_hier(UVM_FULL);

      //middle3 and middle4 have the verbosity turned to none so they
      //suppress all by default.
      middle3.set_report_verbosity_level_hier(UVM_NONE);
      middle4.set_report_verbosity_level_hier(UVM_NONE);

      //turn off the full messages for middle1/middle2. 
      middle1.set_report_id_verbosity("FULL_MSG",UVM_NONE);
      middle1.leaf1.set_report_id_verbosity("FULL_MSG",UVM_NONE);
      middle2.set_report_id_verbosity_hier("FULL_MSG",UVM_NONE);

      //turn off the low messages from middle3, the medium messages
      //from middle4.
      middle1.set_report_id_verbosity("LOW_MSG",UVM_NONE);
      middle2.set_report_id_verbosity("MEDIUM_MSG",UVM_NONE);

      //turn on the none messages from middle3 and middle4 using severity_id
      middle1.leaf1.set_report_severity_id_verbosity(UVM_INFO,"NONE_MSG",-1);
      middle2.leaf1.set_report_severity_id_verbosity_hier(UVM_INFO,"NONE_MSG",-1);

      //turn off the none messages for middle3/middle4. The only way
      //to turn off a none message is to set the threshold negative.
      middle3.set_report_id_verbosity("NONE_MSG",-1);
      middle3.leaf1.set_report_id_verbosity("NONE_MSG",-1);
      middle4.set_report_id_verbosity_hier("NONE_MSG",-1);

      //turn on the full messages from middle3, the medium messages
      //from middle4.
      middle3.set_report_id_verbosity("FULL_MSG",UVM_FULL);
      middle4.set_report_id_verbosity("MEDIUM_MSG",UVM_MEDIUM);

      //turn on the low messages from middle3 and middle4 using severity_id
      middle3.leaf1.set_report_severity_id_verbosity(UVM_INFO,"LOW_MSG",UVM_LOW);
      middle4.leaf1.set_report_severity_id_verbosity_hier(UVM_INFO,"LOW_MSG",UVM_LOW);


  endfunction

  function void report();
    int fails = 0;
    fails += check_object(middle1, 3);
    fails += check_object(middle1.leaf1, 3);
    fails += check_object(middle2, 3);
    fails += check_object(middle2.leaf1, 3);
    fails += check_object(middle3, 1);
    fails += check_object(middle3.leaf1, 1);
    fails += check_object(middle4, 1);
    fails += check_object(middle4.leaf1, 1);
    if(fails == 0) $display("*** UVM TEST PASSED ****");
  endfunction
  function int check_object(uvm_report_object obj, int cnt);
    if(cnt != ctchr.cnt[obj]) begin
      $display("*** UVM TEST FAILED for %s, expected %0d but got %0d", obj.get_full_name(), cnt, ctchr.cnt[obj]);
      return 1;
    end
    return 0;
  endfunction
endclass

initial
  begin
     run_test();
  end

endmodule
