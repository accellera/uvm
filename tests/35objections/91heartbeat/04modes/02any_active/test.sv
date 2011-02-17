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

  string message = "Did not recieve an update of myobj on any component since last event trigger at time 600. The list of registered components is:";

  function automatic bit check_message(string msg);
    int lpos = 0;
    int spos = 0;
    bit got0, got1, got2;
    string agent;

    while(lpos<msg.len() && msg[lpos] != "\n") lpos++;
    if(msg.substr(spos,lpos-1) != message) begin
      $display("*** Bad start of message: %s", msg.substr(spos,lpos-1));
      return 0;
    end

    repeat (3) begin
      lpos++; spos = lpos; 
      while(lpos<msg.len() && msg[lpos] != "\n") lpos++;
      case(msg.substr(spos,lpos-1))
        "  uvm_test_top.env.agent": begin got0=1; end
        "  uvm_test_top.env.agent.mc1": begin got1=1; end
        "  uvm_test_top.env.agent.mc2": begin got2=1; end
        default: begin
          $display("*** BAD AGENT: %s", msg.substr(spos,lpos-1));
          return 0;
        end
      endcase
    end
    if(!got0) $display("*** DIDN'T GET uvm_test_top.env.agent");
    if(!got1) $display("*** DIDN'T GET uvm_test_top.env.agent.mc1");
    if(!got2) $display("*** DIDN'T GET uvm_test_top.env.agent.mc2");
    lpos++;
    if(lpos<msg.len()) begin
      $display("*** Extra message text: %s", msg.substr(lpos, msg.len()-1));
      return 0;
    end 
    return 1;
  endfunction


  class my_catcher extends uvm_report_catcher;
     int id_cnt;
     int client_cnt[uvm_report_object];
     int times_cnt[time];
     string msg;
     uvm_component c;
     virtual function action_e catch();
        if(get_id()!="HBFAIL") return THROW;
        $display("%0t: MSG: %s", $time, get_message());
        id_cnt++;
        if(!client_cnt.exists(get_client())) client_cnt[get_client()] = 0;
        client_cnt[get_client()]++;
        if(!times_cnt.exists($time)) times_cnt[$time] = 0;
        times_cnt[$time]++;
        msg = get_message();
        return CAUGHT;
     endfunction
  endclass

  uvm_callbacks_objection myobj = new("myobj");

  class mycomp extends uvm_component;
    time del;
    function new(string name, uvm_component parent);
      super.new(name,parent);
    endfunction
    task run_phase(uvm_phase phase);
      phase.raise_objection(this);
      repeat(10) #del myobj.raise_objection(this);
      phase.drop_objection(this);
    endtask
  endclass
  class myagent extends uvm_component;
    mycomp mc1, mc2;
    function new(string name, uvm_component parent);
      super.new(name,parent);
      mc1 = new("mc1", this);
      mc2 = new("mc2", this);
      mc1.del = 55;
      mc2.del = 45;
    endfunction
    task run_phase(uvm_phase phase);
      phase.raise_objection(this);
      repeat(10) #50 myobj.raise_objection(this);
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
      void'(hb.set_mode(UVM_ANY_ACTIVE));
      hb.add(agent.mc1);
      hb.add(agent.mc2);
      hb.add(agent);
    endfunction
    task run_phase(uvm_phase phase);
      uvm_event e = new("e");
      phase.raise_objection(this);
      hb.start(e);
      repeat(11) #60 e.trigger(); 
      //should have error on agent.mc1 @660
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
      if(mc.id_cnt != 1) begin
        $display("** UVM TEST FAILED **");
        return;
      end
      if(mc.client_cnt.num() != 1) begin
        $display("** UVM TEST FAILED **");
        return;
      end
      r = env;
      if(mc.client_cnt[r] != 1) begin
        $display("** UVM TEST FAILED **");
        return;
      end
      if((mc.times_cnt[660] != 1)) begin
        $display("** UVM TEST FAILED **");
        return;
      end
      if(!check_message(mc.msg)) begin
        $display("** UVM TEST FAILED **");
        return;
      end
      if($time != 660) begin
        $display("** UVM TEST FAILED **");
        return;
      end
      $display("** UVM TEST PASSED **");
    endfunction
  
  endclass

  initial run_test();
endmodule
