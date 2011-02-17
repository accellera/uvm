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

  class my_catcher extends uvm_report_catcher;
     int id_cnt;
     int client_cnt[uvm_report_object];
     int times_cnt[time];
     uvm_component c;
     virtual function action_e catch();
        if(get_id()!="HBFAIL") return THROW;
        $display("%0t: MSG: %s", $time, get_message());
        id_cnt++;
        if(!client_cnt.exists(get_client())) client_cnt[get_client()] = 0;
        client_cnt[get_client()]++;
        if(!times_cnt.exists($time)) times_cnt[$time] = 0;
        times_cnt[$time]++;
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
      hb.add(agent.mc1);
      hb.add(agent.mc2);
      hb.add(agent);
    endfunction
    task run_phase(uvm_phase phase);
      uvm_event e = new("e");
      phase.raise_objection(this);
      hb.start(e);
      repeat(10) #60 e.trigger(); 
      //should have error on agent.mc2 @540
      //should have error on agent.mc2 @600
      //should have error on agent @600
 
      #0 hb.remove(agent.mc2);
         hb.remove(agent);

      #60 e.trigger(); 
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
      if(mc.id_cnt != 4) begin
        $display("** UVM TEST FAILED **");
        return;
      end
      if(mc.client_cnt.num() != 1) begin
        $display("** UVM TEST FAILED **");
        return;
      end
      r = env;
      if(mc.client_cnt[r] != 4) begin
        $display("** UVM TEST FAILED **");
        return;
      end
      if((mc.times_cnt[540] != 1) || (mc.times_cnt[600] != 2) || 
         (mc.times_cnt[660] != 1)) begin
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
