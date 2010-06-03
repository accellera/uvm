//----------------------------------------------------------------------
//   Copyright 2005-2007 Mentor Graphics Corporation
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
// hfpb_coverage
//----------------------------------------------------------------------
class hfpb_coverage #(int DATA_SIZE=8, int ADDR_SIZE=16)
  extends uvm_subscriber #(hfpb_transaction #(DATA_SIZE, ADDR_SIZE));

  bus_trans_t         bus_trans_type;
  bit[DATA_SIZE-1:0]  wdata;
  bit[DATA_SIZE-1:0]  rdata;
  bit[ADDR_SIZE-1:0]  addr;
  bit[2:0]            slave_id;

  covergroup hfpb_cov;
    coverpoint bus_trans_type;
    coverpoint slave_id;
    transXslave: cross slave_id, bus_trans_type;
  endgroup

  function new(string name , uvm_component parent);
    super.new(name, parent);
    hfpb_cov = new();
  endfunction

  function void write(hfpb_transaction #(DATA_SIZE, ADDR_SIZE) t);
    wdata           = t.wdata;
    rdata           = t.rdata;
    addr            = t.addr;
    bus_trans_type  = t.bus_trans_type;
    slave_id        = t.slave_id;
    hfpb_cov.sample();  
  endfunction

  function void report();

    int unsigned covered;
    int unsigned total;
    real pct;

`ifndef INCA
    pct = hfpb_cov.bus_trans_type.get_coverage(covered, total);
    $display("bus trans type coverage: covered = %0d, total = %0d (%5.2f%%)",
             covered, total, pct);
    pct = hfpb_cov.slave_id.get_coverage(covered, total);
    $display("slave id coverage:  covered = %0d, total = %0d (%5.2f%%)",
             covered, total, pct);
    pct = hfpb_cov.transXslave.get_coverage(covered, total);
    $display("slave  X trans coverage:  covered = %0d, total = %0d (%5.2f%%)",
             covered, total, pct);
`endif

  endfunction
  
endclass
