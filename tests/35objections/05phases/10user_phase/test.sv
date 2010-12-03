`include "uvm_macros.svh"

//This test adds phases to two different class hierarcies. The 
//important effect is to verify that inserting a phase where the
//existing phase is an alias.

module top;
  import uvm_pkg::*;

  `uvm_phase_task_decl(mytask,0)
  `uvm_phase_task_decl(another,0)
  `uvm_phase_task_decl(third,0)

  class cls1 extends uvm_component;
    static mytask_phase #(cls1) mytask_ph;
    static another_phase #(cls1) another_ph;

    function new(string name, uvm_component parent);
      super.new(name,parent);
      if(mytask_ph == null) begin
        mytask_ph = new();
        another_ph = new();
        uvm_top.insert_phase(mytask_ph, start_of_simulation_ph);
        uvm_top.insert_phase(another_ph, mytask_ph);
      end
    endfunction

    virtual task mytask;
      uvm_test_done.raise_objection(this);
      uvm_report_info("mytask", "start");
      #20;
      uvm_report_info("mytask", "end");
      uvm_test_done.drop_objection(this);
    endtask
    virtual task another;
      uvm_test_done.raise_objection(this);
      uvm_report_info("another", "start");
      #20;
      uvm_report_info("another", "end");
      uvm_test_done.drop_objection(this);
    endtask
  endclass

  class cls2 extends uvm_component;
    static mytask_phase #(cls2) mytask_ph;
    static another_phase #(cls2) another_ph;

    function new(string name, uvm_component parent);
      super.new(name,parent);
      if(mytask_ph == null) begin
        mytask_ph = new();
        another_ph = new();
        uvm_top.insert_phase(mytask_ph, start_of_simulation_ph);
        uvm_top.insert_phase(another_ph, mytask_ph);
      end
    endfunction

    virtual task mytask;
      uvm_test_done.raise_objection(this);
      uvm_report_info("mytask", "start");
      #30;
      uvm_report_info("mytask", "end");
      uvm_test_done.drop_objection(this);
    endtask
    virtual task another;
      uvm_test_done.raise_objection(this);
      uvm_report_info("another", "start");
      #40;
      uvm_report_info("another", "end");
      uvm_test_done.drop_objection(this);
    endtask
  endclass

  class cls3 extends cls2;
    static third_phase #(cls3) third_ph;

    function new(string name, uvm_component parent);
      super.new(name,parent);
      if(third_ph == null) begin
        third_ph = new();
        //cls2::mytask_ph is an aliase for cls1::mytask_ph
        uvm_top.insert_phase(third_ph, run_ph);
      end
    endfunction
    virtual task third;
      uvm_test_done.raise_objection(this);
      uvm_report_info("third", "start");
      #70;
      uvm_report_info("third", "end");
      uvm_test_done.drop_objection(this);
    endtask
  endclass

  class test extends uvm_env;
    cls1 c1;
    cls2 c2;
    cls3 c3;

    //want the env to coordinate all phases
    mytask_phase #(test) mytask_ph;
    another_phase #(test) another_ph;
    third_phase #(test) third_ph;

    bit failed = 0;

    `uvm_component_utils(test)
    function new(string name, uvm_component parent);
      super.new(name,parent);
      c1 = new("c1", this);
      c2 = new("c2", this);
      c3 = new("c3", this);
      //mytask_ph becomes an aliase for cls1::mytask_ph
      //another_ph becomes an aliase for cls1::another_ph
      //third_ph becomes an aliase for cls2::third_ph
      mytask_ph = new();
      another_ph = new();
      third_ph = new();
      uvm_top.insert_phase(mytask_ph, start_of_simulation_ph);
      uvm_top.insert_phase(another_ph, mytask_ph);
      uvm_top.insert_phase(third_ph, run_ph);
    endfunction
    virtual task mytask;
      #1 global_stop_request();
    endtask
    virtual task another;
      //mytask runs for 30
      if($time != 30) begin
        failed = 1;
        $display("** UVM TEST FAILED **");
      end
    endtask
    task run;
      //another runs for 40, so time is 70
      if($time != 70) begin
        failed = 1;
        $display("** UVM TEST FAILED **");
      end
      uvm_report_info("run", "start");
      uvm_test_done.raise_objection(this);
      #500 uvm_test_done.drop_objection(this);
      uvm_report_info("run", "end");
    endtask
    virtual task third;
      //run runs for 500, so time is 570
      if($time != 570) begin
        failed = 1;
        $display("** UVM TEST FAILED **");
      end
      #1 global_stop_request();
    endtask
    virtual function void report();
      //third runs for 70, so time should be 640
      if($time != 640) begin
        failed = 1;
        $display("** UVM TEST FAILED **");
      end
      if(!failed)
        $display("** UVM TEST PASSED **");
    endfunction
  endclass

  initial begin
    run_test(); 
  end

endmodule
