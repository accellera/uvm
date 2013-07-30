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
    $display("Pass1 d.x: %h",d.x);
    result = d.x;


  begin

    uvm_report_object urm1 = new("urm1");

    // User variables
    uvm_trace_message l_trace_messageA, l_trace_messageB;
    int l_tr_handle0, l_tr_handle1;
    int my_int;
    string my_string;
    my_class my_obj;


    // Adjust action on urm1
    urm1.set_report_severity_action(UVM_INFO, UVM_RM_RECORD | UVM_DISPLAY);

    my_int = 5;
    my_string = "foo";
    my_obj = new("my_obj");


    p.srandom(100);


    // Message A starts at 5, Message B starts at 15.
    // Message A finishes at 35 (Message B is still going)
    // Message B finishes at 60

    // Spans #30 time
    `uvm_info_begin(l_trace_messageA, "TEST_A", "Beginning A...", UVM_LOW, urm1)
    `uvm_add_trace_tag(l_trace_messageA, "color", "red")
    `uvm_add_trace_int(l_trace_messageA, my_int, UVM_DEC, "attr_int")
    `uvm_add_trace_string(l_trace_messageA, my_string, "attr_string")
    `uvm_add_trace_object(l_trace_messageA, my_obj, "attr_obj")

    my_string = "hey buddy";
    my_obj.foo = 7;
    my_obj.bar = "bar";

    // Spans #45 time
    `uvm_info_begin(l_trace_messageB, "TEST_B", "Beginning B...", UVM_LOW, urm1)
    `uvm_add_trace_tag(l_trace_messageB, "color", "white")
    `uvm_add_trace_string(l_trace_messageB, my_string, "attr_string")
    `uvm_add_trace_object(l_trace_messageB, my_obj, "attr_obj")


    `uvm_info_end(l_trace_messageA, "Ending A...", l_tr_handle0)

    `uvm_info_end(l_trace_messageB, "Ending B...", l_tr_handle1)

    `uvm_link(l_tr_handle0, l_tr_handle1, "child", "TEST_L", UVM_LOW, urm1)

    `uvm_link(-1 , l_tr_handle1, "BAD", "TEST_L", UVM_LOW, urm1)

    d = new;
    void'(d.randomize());
    $display("Pass2 d.x: %h",d.x);
    if (d.x != result) begin
      `uvm_error("Bad Result", $sformatf("Expected d.x=%0d, but got %0d",result,d.x))
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
