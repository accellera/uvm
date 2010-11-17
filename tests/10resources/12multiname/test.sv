module top;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  typedef uvm_config_db#(int) my_config_type;

  class test extends uvm_component;
    uvm_resource_pool p = uvm_resource_pool::get();

    function new(string name, uvm_component parent);
      super.new(name,parent);
    endfunction

    `uvm_component_utils(test)
    task run;

      int unsigned bar=0;
      uvm_resource_base rb;

      uvm_resource_types::rsrc_q_t rq;
      uvm_resource_base r;
      uvm_resource_pool rp = uvm_resource_pool::get();

      my_config_type::set(this,"foo","bar",10);
      rq = rp.lookup_regex_names({get_full_name(),".foo"}, "bar");

      r = uvm_resource#(int unsigned)::get_highest_precedence(rq);
      rb = p.get_by_name("foo","bar");

      //void'(uvm_config_db#(int unsigned)::get(this,"foo","bar",bar));
      if(rb != null)
        $display("**** UVM TEST FAILED ****");
      else
        $display("**** UVM TEST PASSED ****");
      global_stop_request();
    endtask

  endclass

  initial run_test();
endmodule
