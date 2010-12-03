module test;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  class my_catcher extends uvm_report_catcher;
     int id_cnt;
     int client_cnt[uvm_report_object];
     uvm_component c;
     virtual function action_e catch();
        if(get_id()!="HBFAIL") return THROW;
        $display("MSG: %s", get_message());
        id_cnt++;
        if(!client_cnt.exists(get_client())) client_cnt[get_client()] = 0;
        client_cnt[get_client()]++;
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
    task run;
      uvm_event e = new("e");
      hb.start(e);
      fork
        repeat(11) #60 e.trigger();
        #550 hb.remove(agent.mc1);
      join
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
      uvm_report_cb::add(null,mc);
    endfunction 
    function void report;
      uvm_report_object r;
      if(mc.id_cnt != 2) begin
        $display("** UVM TEST FAILED **");
        return;
      end
      if(mc.client_cnt.num() != 1) begin
        $display("** UVM TEST FAILED **");
        return;
      end
      r = env;
      if(mc.client_cnt[r] != 2) begin
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
