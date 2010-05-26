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

  class data extends uvm_sequence_item;
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
      recording_detail = UVM_LOW;
    endfunction

    task run;
      data d1;
      d1 = new; d1.set_name("d1");

      void'(d1.randomize());

      void'(begin_tr(d1));
      end_tr(d1);

      uvm_report_info("SUCCESS", "**** UVM TEST PASSED ****", UVM_INFO);
      global_stop_request();
    endtask
  endclass

  initial run_test();
endmodule
