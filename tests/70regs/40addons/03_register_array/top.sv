
module top();

  bit reset;
  bit reverse_reset;

  uvc_intf pif(reset, reverse_reset);
  dut dut(pif);
  test test();
  task reset_dut(bit r=0);
    if (r) reverse_reset=1;
    reset=1;
    #10 reset=0;
    reverse_reset=0;
  endtask
endmodule
