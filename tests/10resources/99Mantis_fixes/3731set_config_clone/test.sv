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

    uvm_object sy_acs;
    uvm_object sn_acs;
    uvm_object sy_gn;
    uvm_object sy_gy;
    uvm_object sn_gn;
    uvm_object sn_gy;
     
    `uvm_component_utils_begin(mycomp)
      `uvm_field_object(sy_acs, UVM_ALL_ON)
      `uvm_field_object(sn_acs, UVM_ALL_ON)
    `uvm_component_utils_end

    function new(string name, uvm_component parent);
       super.new(name, parent);
    endfunction : new

    function void build();
      super.build();

      void'(get_config_object("set_with_clone", sy_gn, 0));
      void'(get_config_object("set_with_clone", sy_gy, 1));
      void'(get_config_object("set_without_clone", sn_gn, 0));
      void'(get_config_object("set_without_clone", sn_gy, 1));
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
       set_config_object("mc", "sn_acs", mo, 0);
       set_config_object("mc", "sy_acs", mo, 1);
       set_config_object("mc", "set_with_clone", mo, 1);
       set_config_object("mc", "set_without_clone", mo, 0);
       mc = new("mc", this);
    endfunction

    task run_phase(uvm_phase phase);
      bit failed = 0;
      phase.raise_objection(this);
      if (mc.sn_acs != mo) begin
         $display("*** UVM TEST FAILED, Set Clone (0) resulted in different reference");
         failed = 1;
      end
      if (mc.sy_acs == mo) begin
         $display("*** UVM TEST FAILED, Set Clone (1) resulted in same reference");
         failed = 1;
      end
      if (mc.sn_gn != mo) begin
         $display("*** UVM TEST FAILED, Set Clone (0) & Get Clone (0) resulted in different reference");
         failed = 1;
      end
      if (mc.sn_gy == mo) begin
         $display("*** UVM TEST FAILED, Set Clone (0) & Get Clone (1) resulted in same reference");
         failed = 1;
      end else begin
         $display("*** UVM TEST NOTE: Set Clone(0) & Get Clone (1) resulted in a different behavior than in OVM");
      end
      if (mc.sy_gn == mo) begin
         $display("*** UVM TEST FAILED, Set Clone (1) & Get Clone (0) resulted in same reference");
         failed = 1;
      end
      if (mc.sy_gy == mo) begin
         $display("*** UVM TEST FAILED, Set Clone (1) & Get Clone (1) resulted in same reference");
         failed = 1;
      end
      if (mc.sy_gy == mc.sy_gn) begin
         $display("*** UVM TEST FAILED, Set Clone (1) & Get Clone (1) resulted in same reference as Set Clone (1) & Get Clone (0)");
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
