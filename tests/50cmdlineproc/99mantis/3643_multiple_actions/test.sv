module test;
  import uvm_pkg::*;
  uvm_action a;

  initial begin
    if(!uvm_string_to_action("UVM_LOG|UVM_STOP",a))
      $display("UVM TEST FAILED");
    else
      $display("UVM TEST PASSED");

    _global_reporter.report_summarize();
    _global_reporter.dump_report_state();
  end
endmodule
