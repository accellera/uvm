module test;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  string message = {"Did not recieve an update of myobj on any component since last event trigger at time 600. The list of registered components is:\n",
    "  uvm_test_top.env.agent\n",
    "  uvm_test_top.env.agent.mc1\n",
    "  uvm_test_top.env.agent.mc2"};

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

  uvm_objection myobj = new("myobj");

  class mycomp extends uvm_component;
    time del;
    function new(string name, uvm_component parent);
      super.new(name,parent);
    endfunction
    task run;
      repeat(10) #del myobj.raise_objection(this);
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
    task run;
      repeat(10) #50 myobj.raise_objection(this);
    endtask
  endclass
  class myenv extends uvm_component;
    uvm_heartbeat hb;
    myagent agent;

    function new(string name, uvm_component parent);
      super.new(name,parent);
      agent = new("agent", this);

      hb = new("myhb", this, myobj);
      hb.hb_mode(UVM_ANY_ACTIVE);
      hb.add(agent.mc1);
      hb.add(agent.mc2);
      hb.add(agent);
    endfunction
    task run;
      uvm_event e = new("e");
      hb.start(e);
      repeat(11) #60 e.trigger(); 
      //should have error on agent.mc1 @660

      uvm_top.stop_request(); 
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
      uvm_report_catcher::add_report_default_catcher(mc);
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
      if((mc.msg != message)) begin
        $display("Expected: \"%s\"",message);
        $display("Got: \"%s\"",mc.msg);
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
