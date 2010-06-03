//----------------------------------------------------------------------
//   Copyright 2007-2009 Mentor Graphics Corporation
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
//----------------------------------------------------------------------

const string mem_slave_name = "mem_slave";

`include "ctypes.svh"

//----------------------------------------------------------------------
// mem
//
// A simple general purpose memory with parameterized data element size
// and address size.
//----------------------------------------------------------------------
class mem #(int DATA_SIZE=8, int ADDR_SIZE=16) extends uvm_object;

  typedef bit [DATA_SIZE-1:0] data_t;
  typedef bit [ADDR_SIZE-1:0] addr_t;

  const local int unsigned mem_size = (1 << ADDR_SIZE);

  bit [DATA_SIZE-1:0] m[0 : ((1 << ADDR_SIZE) - 1)];

  function new();
    clear();
  endfunction

  function void clear();
    for(int unsigned i = 0; i < mem_size; i++)
      m[i] = 0;
  endfunction

  function void write(addr_t a, data_t d);
    m[a] = d;
  endfunction

  function data_t read(addr_t a);
    return m[a];
  endfunction

  virtual function void print();

    int unsigned r, c;
    addr_t a;
    addr_t s;
    string data_fmt;
    string addr_fmt;
    string str;

    // Set up the number of rows and columns to print.  Allow a maximum
    // of 16 bytes per line, adjust rows accordingly
    int unsigned cols = (ADDR_SIZE < 5) ? (1 << ADDR_SIZE) : 16;
    int unsigned rows = 1 << ((ADDR_SIZE < 5) ? 1 : (ADDR_SIZE - 4));

    // Set up address and data print formats based on size
    int unsigned data_chars = ((DATA_SIZE >> 2) + ((DATA_SIZE & 'h3) > 0));
    int unsigned addr_chars = ((ADDR_SIZE >> 2) + ((ADDR_SIZE & 'h3) > 0));

    $sformat(addr_fmt, " %%0%0dx:", addr_chars);
    $sformat(data_fmt, " %%0%0dx", data_chars);

    $display("addr size: %0d  data size: %0d", ADDR_SIZE, DATA_SIZE);

    a = 0;
    for(r = 0; r < rows; r++) begin

      // print the address of the first element in the row
      s = a;
      $sformat(str, addr_fmt, a);
      $write(str);

      // print a row in hex
      for(c = 0; c < cols; c++) begin
        $sformat(str, data_fmt, m[a]);
        $write(str);
        a++;
      end

      // print the row in ascii
      a = s;
      $write("  ");
      for(c = 0; c < cols; c++) begin
        $write("%s", (`isprint(m[a])) ? m[a] : ".");
        a++;
      end

      $display();

    end
  endfunction

endclass

//----------------------------------------------------------------------
// hfpb_mem
//
// memory slave used to drive the memory
//----------------------------------------------------------------------
class hfpb_mem #(int DATA_SIZE=8, int ADDR_SIZE=16)
  extends hfpb_responder #(DATA_SIZE, ADDR_SIZE);

  mem #(DATA_SIZE, ADDR_SIZE) m;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build();
    super.build();
    m  = new();
  endfunction

  function void report();

    // find out what the verbosity leve is set to
    uvm_report_handler rh = get_report_handler();
    int verbosity = rh.get_verbosity_level();

    if(verbosity >= UVM_MEDIUM) begin
      $display("\nreport: -- memory dump -- %s", get_full_name());
      m.print();
    end
  endfunction

  task run();

    hfpb_transaction #(DATA_SIZE, ADDR_SIZE) req;
    hfpb_transaction #(DATA_SIZE, ADDR_SIZE) rsp;

    bit [DATA_SIZE-1:0] d;
    bit [ADDR_SIZE-1:0] a;

    forever begin

      // get a request and clone it as the response
      slave_port.get(req);
      assert($cast(rsp, req.clone()));
      
      // interpret the request and fill in response
      a    = req.get_addr();
      if(req.is_read()) begin
        d  = m.read(a);
        rsp.set_rdata(d);
      end
      else begin
        d = req.get_wdata();
        m.write(a, d);
      end

      // send response back
      slave_port.put(rsp);
      #1;
    end
  endtask

endclass
