interface clk_rst;

  bit clk;
  bit rst;

endinterface

interface hfpb_if #(int DATA_SIZE = 8, int ADDR_SIZE = 16) (input bit clk, input bit rst);

  bit [7:0] sel;  // 8 slaves
  bit en;
  bit write;
  bit [ADDR_SIZE-1:0] addr;
  bit [DATA_SIZE-1:0] rdata;
  bit [DATA_SIZE-1:0] wdata;

  modport master(
    input clk,
    output sel,
    output en,
    output write,
    output addr,
    input rdata,
    output wdata
  );

  modport slave(
    input clk,
    input sel,
    input en,
    input write,
    input addr,
    output rdata,
    input wdata
  );

  modport monitor(
    input clk,
    input sel,
    input en,
    input write,
    input addr,
    input wdata,
    input rdata
  );

endinterface
