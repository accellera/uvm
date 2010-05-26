module top;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  class header extends uvm_object;
    rand int addr, data, size;
    `uvm_object_utils_begin(header)
       `uvm_field_int(addr, UVM_DEFAULT)
       `uvm_field_int(data, UVM_DEFAULT)
       `uvm_field_int(size, UVM_DEFAULT)
    `uvm_object_utils_end
  endclass

  class data extends uvm_object;
    rand header hdr;
    rand byte payload[];
    `uvm_object_utils_begin(data)
       `uvm_field_object(hdr, UVM_DEFAULT)
       `uvm_field_array_int(payload, UVM_DEFAULT)
    `uvm_object_utils_end
  endclass

  class test extends uvm_component;
    `uvm_component_utils(test)
    function new(string name, uvm_component parent);
      super.new(name,parent);
    endfunction

    task run;
      data d1, d2;
      d1 = new; d1.set_name("d1");
      d1.hdr = new;

      void'(d1.randomize());
      $cast(d2, d1.clone());

      d2.hdr = null;

      if(d1.compare(d2)) begin
        uvm_report_error("FAILURE", "**** UVM TEST FAILED  (objects compared as equal) ****");
        return;
      end
      uvm_report_info("SUCCESS", "**** UVM TEST PASSED ****", UVM_NONE);
      global_stop_request();
    endtask
  endclass

  initial run_test();
endmodule
