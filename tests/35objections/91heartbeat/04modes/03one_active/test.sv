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

module test;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  string message_0 = {"Recieved update of myobj from more than one",
    " component since last event trigger at time 180. The list of ",
    "triggered components is:\n",
    "  uvm_test_top.env.agent.mc1 (updated: 200)\n",
    "  uvm_test_top.env.agent.mc2 (updated: 200)" };
  string message_1 = {"Recieved update of myobj from more than one",
    " component since last event trigger at time 240. The list of ",
    "triggered components is:\n",
    "  uvm_test_top.env.agent (updated: 290)\n",
    "  uvm_test_top.env.agent.mc2 (updated: 300)"};
  string message_2 = {"Did not recieve an update of myobj on any ",
    "component since last event trigger at time 480. The list of ",
    "registered components is:\n",
    "  uvm_test_top.env.agent\n",
    "  uvm_test_top.env.agent.mc1\n",
    "  uvm_test_top.env.agent.mc2"};

  class my_catcher extends uvm_report_catcher;
     int id_cnt;
     int client_cnt[uvm_report_object];
     int times_cnt[time];
     string msg[$];
     uvm_component c;
     virtual function action_e catch();
        if(get_id()!="HBFAIL") return THROW;
        $display("%0t: (%s) MSG: %s", $time, get_id(), get_message());
        id_cnt++;
        if(!client_cnt.exists(get_client())) client_cnt[get_client()] = 0;
        client_cnt[get_client()]++;
        if(!times_cnt.exists($time)) times_cnt[$time] = 0;
        times_cnt[$time]++;
        msg.push_back(get_message());
        return CAUGHT;
     endfunction
  endclass

  uvm_callbacks_objection myobj = new("myobj");

  class mycomp extends uvm_component;
    time active_start, active_stop;
    function new(string name, uvm_component parent);
      super.new(name,parent);
    endfunction
    task run_phase(uvm_phase phase);
      phase.raise_objection(this);
      repeat(10) 
        #50 if($time>=active_start && $time<=active_stop) begin
           $display("%0t: %s raised", $time, get_full_name());
           myobj.raise_objection(this);
        end
      phase.drop_objection(this);
    endtask
  endclass
  class myagent extends uvm_component;
    mycomp mc1, mc2;
    function new(string name, uvm_component parent);
      super.new(name,parent);
      mc1 = new("mc1", this);
      mc2 = new("mc2", this);
      //Create overlap error between mc1 and mc2 at time 240
      mc1.active_start = 0; mc1.active_stop = 200;
      mc2.active_start = 180; mc2.active_stop = 300;
    endfunction
    task run_phase(uvm_phase phase);
      phase.raise_objection(this);
      #240;
      //create overlap error between mc2 and this at time 300
      repeat(4) begin
           #50 
           $display("%0t: %s raised", $time, get_full_name());
           myobj.raise_objection(this);
      end
      phase.drop_objection(this);
    endtask
  endclass
  class myenv extends uvm_component;
    uvm_heartbeat hb;
    myagent agent;

    function new(string name, uvm_component parent);
      super.new(name,parent);
      agent = new("agent", this);

      hb = new("myhb", this, myobj);
      void'(hb.set_mode(UVM_ONE_ACTIVE));
      hb.add(agent.mc1);
      hb.add(agent.mc2);
      hb.add(agent);
    endfunction
    task run_phase(uvm_phase phase);
      uvm_event e = new("e");
      phase.raise_objection(this);
      hb.start(e);
      repeat(9) #60 e.trigger(); 
      //should have error for no triggers @540
      phase.drop_objection(this);
    endtask
  endclass

  class test extends uvm_test;
    myenv env;
    my_catcher mc;
    `uvm_component_utils(test)
    function new(string name, uvm_component parent);
      super.new(name,parent);
      env = new("env", this);
      mc = new;
      uvm_report_cb::add(null,mc);
    endfunction 
    function void report;
      uvm_report_object r;
      if(mc.id_cnt != 3) begin
        $display("** UVM TEST FAILED **");
        return;
      end
      if(mc.client_cnt.num() != 1) begin
        $display("** UVM TEST FAILED **");
        return;
      end
      r = env;
      if(mc.client_cnt[r] != 3) begin
        $display("** UVM TEST FAILED **");
        return;
      end
      if((mc.times_cnt[240] != 1) || (mc.times_cnt[300] != 1) ||
         (mc.times_cnt[540] != 1)) begin
        $display("** UVM TEST FAILED **");
        return;
      end
      if((mc.msg[0] != message_0)) begin
        $display("Expected: \"%s\"",message_0);
        $display("Got: \"%s\"",mc.msg[0]);
        $display("** UVM TEST FAILED **");
        return;
      end
      if((mc.msg[1] != message_1)) begin
        $display("Expected: \"%s\"",message_1);
        $display("Got: \"%s\"",mc.msg[1]);
        $display("** UVM TEST FAILED **");
        return;
      end
      if((mc.msg[2] != message_2)) begin
        $display("Expected: \"%s\"",message_2);
        $display("Got: \"%s\"",mc.msg[2]);
        $display("** UVM TEST FAILED **");
        return;
      end
      if($time != 540) begin
        $display("** UVM TEST FAILED **");
        return;
      end
      $display("** UVM TEST PASSED **");
    endfunction
  
  endclass

  initial run_test();
endmodule
