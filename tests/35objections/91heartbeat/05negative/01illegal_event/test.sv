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
     int cnt = 0;
     string msg = "";
     bit times[time];

     uvm_component c;
     virtual function action_e catch();
        if(get_id()!="ILHBVNT") return THROW;
        $display("%0t: MSG: %s", $time, get_message());
        cnt++;
        msg = get_message();
        times[$time] = 1;
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
      repeat(10) #del begin
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
      mc1.del = 45;
      mc2.del = 55;
    endfunction
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
    endfunction
    task run_phase(uvm_phase phase);
      uvm_event e = new("e");
      uvm_event e2 = new("e2");
      uvm_component l[$];
      phase.raise_objection(this);
      hb.start(e);
      fork
        #10 hb.start(e2); //cause error since is started and e is event
        #20 hb.start(e);  //no error because e is the event
        #61 begin  //do this right after an event trigger
           //stop e and start e2, no error
           hb.stop();
           hb.start(e2);
           #10 hb.stop();
           hb.start(e);
        end
        #100 begin
           //cause error because set_heartbeat called with different event
           hb.set_heartbeat(e2,l);
        end
        repeat(8) #60 e.trigger();
      join
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
      if(mc.cnt != 2) begin
        $display("** UVM TEST FAILED **");
        return;
      end
      if(!mc.times.exists(10) || !mc.times.exists(100)) begin
        $display("** UVM TEST FAILED **");
        return;
      end
      if(mc.msg != "start() was called for: myhb with trigger e2 which is different from the original trigger e") begin
        $display("** UVM TEST FAILED **");
        return;
      end
      $display("** UVM TEST PASSED **");
    endfunction
  
  endclass

  initial run_test();
endmodule
