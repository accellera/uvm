`include "uvm_macros.svh"
import uvm_pkg::*;

typedef byte unsigned uint8;

class D;
  rand uint8 x;
endclass

class my_class extends uvm_object;
  int foo = 3;
  string bar = "hi there";
  `uvm_object_utils_begin(my_class)
    `uvm_field_int(foo, UVM_ALL_ON | UVM_DEC)
    `uvm_field_string(bar, UVM_ALL_ON)
  `uvm_object_utils_end
  function new (string name = "unnamed-my_class");
    super.new(name);
  endfunction
endclass


class test extends uvm_test;

  D d;

  `uvm_component_utils(test)

  function new(string name, uvm_component parent=null);
    super.new(name,parent);
  endfunction

  task run_phase(uvm_phase phase);

    process p;
    uint8 result;
    bit error;

    set_report_verbosity_level(UVM_DEBUG);

    p = process::self();
    p.srandom(100);

    d = new;
    void'(d.randomize());
    $display("Pass1 d.x: 0x%h",d.x);
    result = d.x;


  begin

    uvm_report_object urm1 = new("urm1");

    // User variables
    int my_int;
    string my_string;
    my_class my_obj;


    // Adjust action on urm1
    urm1.set_report_severity_action(UVM_INFO, UVM_RM_RECORD | UVM_DISPLAY);

    my_int = 5;
    my_string = "foo";
    my_obj = new("my_obj");


    p.srandom(100);

    `uvm_info_context_begin("TEST_A", "Message A...", UVM_LOW, urm1)
      `uvm_message_add_tag("color", "red")
      `uvm_message_add_int(my_int, UVM_DEC, "attr_int")
      `uvm_message_add_string(my_string, "attr_string")
      `uvm_message_add_object(my_obj, "attr_obj")
    `uvm_info_context_end

    my_string = "hey buddy";
    my_obj.foo = 7;
    my_obj.bar = "bar";

    `uvm_info_context_begin("TEST_B", "Message B...", UVM_LOW, urm1)
    `uvm_message_add_tag("color", "white")
    `uvm_message_add_string(my_string, "attr_string")
	`uvm_message_add_object(my_obj, "attr_obj")
	`uvm_info_context_end

    d = new;
    void'(d.randomize());
    $display("Pass2 d.x: 0x%h",d.x);
    if (d.x != result) begin
      `uvm_error("Bad Result", $sformatf("Expected d.x=0x%0x, but got 0x%0x",result,d.x))
      error = 1;
    end
  end


    if (error)
      $display("** UVM TEST FAILED **");
    else
      $display("** UVM TEST PASSED **");

  endtask

endclass

module top;

   initial run_test();

endmodule
