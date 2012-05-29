//------------------------------------------------------------------------------
//   Copyright 2010 Mentor Graphics Corporation
//   All Rights Reserved Worldwide
//
//   Licensed under the Apache License, Version 2.0 (the
//   "License"); you may not use this file except in
//   compliance with the License.  You may obtain a copy of
//   the License at
//
//       http://www.apache.org/licenses/LICENSE-2.0
//
//   Unless required by applicable law or agreed to in
//   writing, software distributed under the License is
//   distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
//   CONDITIONS OF ANY KIND, either express or implied.  See
//   the License for the specific language governing
//   permissions and limitations under the License.
//------------------------------------------------------------------------------

`include "ctypes.svh"

//----------------------------------------------------------------------
// mem_if
//----------------------------------------------------------------------
interface mem_if #(int unsigned ADDR_SIZE=16, int unsigned DATA_SIZE=8)
  (input bit clk);

  bit [DATA_SIZE-1:0] data;
  bit [ADDR_SIZE-1:0] addr;
  bit rw;  // 1=write, 0=read
  bit start;
  bit ready;

endinterface


//----------------------------------------------------------------------
// memory
//----------------------------------------------------------------------
module memory #(int unsigned ADDR_SIZE=16, int unsigned DATA_SIZE=8)
  (mem_if mif);

  typedef bit[DATA_SIZE-1:0] data_t;
  typedef bit[ADDR_SIZE-1:0] addr_t;

  data_t mem [1 << ADDR_SIZE];
  addr_t addr;
  data_t data;

  initial begin
    mif.ready = 0;
  end

  always @(posedge mif.clk) begin

    mif.ready <= 0;

    while(mif.start != 1)
      @(posedge mif.clk);

    addr = mif.addr;
    data = mif.data;

    if(mif.rw == 1) begin
      // write
      mem[addr] = data;
      //$display("%0t: write addr=%04x data=%02x", $time, addr, mem[addr]);
    end
    else begin
      // read
      mif.data = mem[addr];
      //$display("%0t: read  addr=%04x data=%02x", $time, addr, mem[addr]);
    end

    @(posedge mif.clk);  // delay for read/write operations
    mif.ready <= 1;

  end

  final dump();

  // utility function to dump the memory for debugging purposes
  function void dump();

    int unsigned r, c;
    addr_t a;
    addr_t s;
    string data_fmt;
    string addr_fmt;
    string str;
    int unsigned cols;
    int unsigned rows;
    int unsigned data_chars;
    int unsigned addr_chars;

    // Set up the number of rows and columns to print.  Allow a maximum
    // of 16 bytes per line, adjust rows accordingly
    cols = (ADDR_SIZE < 5) ? (1 << ADDR_SIZE) : 16;
    rows = 1 << ((ADDR_SIZE < 5) ? 1 : (ADDR_SIZE - 4));

    // Set up address and data print formats based on size
    data_chars = ((DATA_SIZE >> 2) + ((DATA_SIZE & 'h3) > 0));
    addr_chars = ((ADDR_SIZE >> 2) + ((ADDR_SIZE & 'h3) > 0));

    $sformat(addr_fmt, " %%0%0dx:", addr_chars);
    $sformat(data_fmt, " %%0%0dx", data_chars);


    $display ("----------------------------------------------------------------------");
    $display ("                         M E M O R Y   D U M P\n");
    $display("addr size: %0d  data size: %0d\n", ADDR_SIZE, DATA_SIZE);

    a = 0;
    for(r = 0; r < rows; r++) begin

      // print the address of the first element in the row
      // print the row in ascii
      $sformat(str, addr_fmt, a);
      $write(str);

      // print a row in hex
      for(c = 0; c < cols; c++) begin
        $sformat(str, data_fmt, mem[a+c]);
        $write(str);
      end

      // print the row in ascii
      $write("  ");
      for(c = 0; c < cols; c++) begin
        $write("%s", (`isprint(mem[a+c])) ? (mem[a+c] & 'h7f) : ".");
      end

      a += cols;

      $display();

    end

    $display ("----------------------------------------------------------------------");

  endfunction
endmodule

//----------------------------------------------------------------------
// clkgen
//----------------------------------------------------------------------
module clkgen(output bit clk);

  initial begin
    clk = 0;
    #0;
    forever begin
      #5; clk = ~clk;
    end
  end

endmodule
