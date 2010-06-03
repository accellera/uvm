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

//----------------------------------------------------------------------
// hfpb_addr_map
//----------------------------------------------------------------------
class hfpb_addr_map #(int ADDR_SIZE=16) extends uvm_object;

  typedef bit [ADDR_SIZE-1:0] addr_t;

  `ifndef INCA
    typedef struct {
      addr_t low;
      addr_t high;
    } range_t;
  `else
    class range_t; 
      addr_t low;
      addr_t high;
    endclass
  `endif

  range_t addr_map[int unsigned];

  //--------------------------------------------------------------------
  // add_range
  //
  // add new entry to the address map
  //--------------------------------------------------------------------
  function void add_range(addr_t l, addr_t h, int unsigned u);

    string s;

    if(l > h) begin
      $sformat(s, "%0x is not less than or equal to %0x", l, h);
      uvm_report_error("address range", s);
      return;
    end
    `ifdef INCA
      if (!addr_map.exists(u)) addr_map[u] = new;
    `endif
    addr_map[u].low = l;
    addr_map[u].high = h;

  endfunction

  //--------------------------------------------------------------------
  // query
  //--------------------------------------------------------------------
  function bit query(input int unsigned u, output addr_t l, output addr_t h);

    if(!addr_map.exists(u))
      return 0;

    l = addr_map[u].low;
    h = addr_map[u].high;
    return 1;

  endfunction

  //--------------------------------------------------------------------
  // map
  //
  // map an address to a unit
  //--------------------------------------------------------------------
  function int map(input addr_t addr, output addr_t base);

    string s;
    int i;

    foreach(addr_map[i]) begin
      if(addr >= addr_map[i].low && addr <= addr_map[i].high) begin
        base = addr_map[i].low;
        return i;
      end
    end

    $sformat(s, "unable to map address %0x", addr);
    uvm_report_warning("address map", s);

    base = 0;
    return -1;

  endfunction

  //--------------------------------------------------------------------
  // print
  //--------------------------------------------------------------------
  function void print();

    int i;

    $display("--- address map ---");
    foreach (addr_map[i]) begin
      $display("%06x : %06x = %0d", addr_map[i].low, addr_map[i].high,i);
    end

  endfunction
  
endclass
