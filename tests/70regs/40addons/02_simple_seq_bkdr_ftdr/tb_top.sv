`ifndef NUM_DUTS
  `define NUM_DUTS 1
`endif
`ifndef NUM_REGS
  `define NUM_REGS 10
`endif

module tb_top();
  parameter int NUM_DUTS=`NUM_DUTS;
  parameter int NUM_REGS=`NUM_REGS;
  
  bit reset;
  bit reverse_reset;

  uvc_intf pif(reset, reverse_reset);
  dut #(NUM_REGS) dut [0:NUM_DUTS-1] (pif);

  test_top test();
  task reset_dut(bit r=0);
    if (r) reverse_reset=1;
    reset=1;
    #10 reset=0;
    reverse_reset=0;
  endtask
endmodule
