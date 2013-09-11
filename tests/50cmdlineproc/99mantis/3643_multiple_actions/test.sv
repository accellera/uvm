module test;
  import uvm_pkg::*;
  uvm_action a;

  initial begin
    if(!uvm_string_to_action("UVM_LOG|UVM_STOP",a))
      $display("UVM TEST FAILED");
    else
      $display("UVM TEST PASSED");

    begin
	uvm_report_server svr = uvm_coreservice.get_report_server();
        svr.summarize();
    end
  end
endmodule
