module test;
  import uvm_pkg::*;
  uvm_action a;

  initial begin
    uvm_report_server l_rs = uvm_report_server::get_server();
    if(!uvm_string_to_action("UVM_LOG|UVM_STOP",a))
      $display("UVM TEST FAILED");
    else
      $display("UVM TEST PASSED");

    l_rs.report_summarize();
    _global_reporter.dump_report_state();
  end
endmodule
