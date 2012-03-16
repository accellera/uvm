module test;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  class myobj extends uvm_object;

     `uvm_object_utils(myobj)

     function new(string name = "unnamed-myobj");
        super.new(name);
     endfunction : new

  endclass : myobj
   
  class mycomp extends uvm_component;

    uvm_object sngn;
    uvm_object sngy;
    uvm_object sygn;
    uvm_object sygy;
     
    `uvm_component_utils(mycomp)

    function new(string name, uvm_component parent);
       super.new(name, parent);
    endfunction : new

    function void build();
      super.build();

       void'(get_config_object("set_without_clone", sngn, 0));
       void'(get_config_object("set_without_clone", sngy, 1));
       void'(get_config_object("set_with_clone", sygn, 0));
       void'(get_config_object("set_with_clone", sygy, 1));
    endfunction // build
     
  endclass
 
  class test extends uvm_component;
    mycomp mc;
    myobj mo;
    function new(string name, uvm_component parent);
      super.new(name,parent);
    endfunction
    `uvm_component_utils(test)

    function void build();
      super.build();
       mo = myobj::type_id::create("mo");
       set_config_object("mc", "set_without_clone", mo, 0);
       set_config_object("mc", "set_with_clone", mo, 1);
      mc = new("mc", this);
    endfunction

    task run_phase(uvm_phase phase);
      bit failed = 0;
      phase.raise_objection(this);
      if (mc.sngn != mo) begin
         $display("*** UVM TEST FAILED, Set Clone (0) & Get Clone (0) resulted in different reference");
         failed = 1;
      end
      if (mc.sngy != mo) begin
         $display("*** UVM TEST FAILED, Set Clone (0) & Get Clone (1) resulted in different reference");
         failed = 1;
      end
      if (mc.sygn == mo) begin
         $display("*** UVM TEST FAILED, Set Clone (1) & Get Clone (0) resulted in same reference");
         failed = 1;
      end
      if (mc.sygy == mo) begin
         $display("*** UVM TEST FAILED, Set Clone (1) & Get Clone (1) resulted in same reference");
         failed = 1;
      end
      if (mc.sygy == mc.sygn) begin
         $display("*** UVM TEST FAILED, Set Clone (1) & Get Clone (1) produced same output as Set Clone (1) & Get Clone (0)");
         failed = 1;
      end

      if(!failed) $display("*** UVM TEST PASSED ***");
      phase.drop_objection(this);
    endtask

    function void report();
      uvm_resource_pool rp = uvm_resource_pool::get();
      rp.dump();
    endfunction
  endclass

  initial run_test();
endmodule
