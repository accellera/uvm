module top();

  import uvm_pkg::*;
  `include "uvm_macros.svh"

  uvm_object objs[$];
  uvm_objection foo_objection = new();

  class myseq extends uvm_sequence;
    function new(string name="myseq");
      super.new(name);
    endfunction
    task body;
      uvm_test_done.raise_objection(this);
      #10 uvm_test_done.drop_objection(this);
    endtask
  endclass

  class test extends uvm_component;
    myseq ms;
    function new (string name, uvm_component parent);
      super.new(name, parent);
    endfunction
    task run;
      for(int i=0; i<100; ++i) begin
        ms=new($sformatf("ms_%0d",i));
        ms.body(); 
      end
    endtask
    `uvm_component_utils(test)

    function void report();
      uvm_test_done.get_objectors(objs);
      foreach(objs[i]) $display(": objector: %s", objs[i].get_full_name());
      if(objs.size() == 0 && $time == 1000) $display("*** UVM TEST PASSED ***");
      else $display("*** UVM TEST FAILED ***");
    endfunction
  endclass

  initial begin
    run_test();
  end

endmodule

