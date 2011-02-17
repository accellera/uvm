//
//------------------------------------------------------------------------------
//   Copyright 2011 (Authors)
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

`include "uvm_macros.svh"

module top;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  uvm_queue#(int) qi = new, qi2;
  uvm_queue#(logic[63:0]) ql = new, ql2;
  uvm_pool#(int,int) pi = new, pi2;
  uvm_pool#(logic[63:0],logic[63:0]) pl = new, pl2;

  uvm_pool#(int,uvm_queue#(int)) pqi = new, pqi2;
  uvm_pool#(int,uvm_queue#(logic[63:0])) pql = new, pql2;
  uvm_pool#(int,uvm_pool#(int,int)) pqpi = new, pqpi2;
  uvm_pool#(int,uvm_pool#(logic[63:0],logic[63:0])) pqpl = new, pqpl2;

  class test extends uvm_component;
    `uvm_component_utils(test)
    function new(string name, uvm_component parent);
      super.new(name,parent);
    endfunction
  endclass

  initial begin
    for(int i=0; i<5; ++i) begin
      qi.push_back(i);
      ql.push_back(i+5);
    end
    for(int i=0; i<5; ++i) begin
      if(!pi.exists(i)) pi.add(i,i+100);
      if(!pl.exists(i+100)) pl.add(i+100,i);
      if(!pqi.exists(i)) pqi.add(i,qi);
      if(!pql.exists(i+100)) pql.add(i+100,ql);
    end
    if(qi.size() != 5) $display("**** UVM TEST FAILED qi.size = %0d ****", qi.size());
    if(ql.size() != 5) $display("**** UVM TEST FAILED ql.size = %0d ****", ql.size());
    if(pi.num() != 5) $display("**** UVM TEST FAILED ql.num = %0d ****", pi.num());
    if(pl.num() != 5) $display("**** UVM TEST FAILED ql.num = %0d ****", pl.num());
    if(pqi.num() != 5) $display("**** UVM TEST FAILED ql.num = %0d ****", pqi.num());
    if(pql.num() != 5) $display("**** UVM TEST FAILED ql.num = %0d ****", pql.num());
    for(int i=0; i<5; ++i) begin
      if(qi.get(i) != i) $display("**** UVM TEST FAILED qi[%0d] = %0d ****", i, qi.get(i));
      if(ql.get(i) != i+5) $display("**** UVM TEST FAILED ql[%0d] = %0d ****", i, ql.get(i));
      if(pi.get(i) != i+100) $display("**** UVM TEST FAILED pi[%0d] = %0d ****", i, pi.get(i));
      if(pl.get(i+100) != i) $display("**** UVM TEST FAILED pl[%0d] = %0d ****", i+100, pl.get(i+100));
      if(pqi.get(i) != qi) $display("**** UVM TEST FAILED pqi[%0d] = %0d ****", i, pqi.get(i));
      if(pql.get(i+100) != ql) $display("**** UVM TEST FAILED pql[%0d] = %0d ****", i+100, pql.get(i+100));
    end
    for(int i=0; i<5; ++i) begin
      if(qi.pop_front() != i) $display("**** UVM TEST FAILED ****");
      if(ql.pop_front() != i+5) $display("**** UVM TEST FAILED ****");
    end
    uvm_report_info ("PASSED", "**** UVM TEST PASSED ****", UVM_NONE);  

    run_test();
  end
endmodule
