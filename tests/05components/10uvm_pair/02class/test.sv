//---------------------------------------------------------------------- 
//   Copyright 2011 Mentor Graphics Corporation
//   Copyright 2011 Synopsys, Inc.
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

`include "uvm_macros.svh"
`include "transaction.sv"

module top;


class test extends uvm_test;

  int errors =0;

  transaction t1, t2;

  uvm_class_pair #(transaction, transaction) pair, pair2;


  `uvm_component_utils(test)

  function new(string name, uvm_component parent=null);
    super.new(name,parent);
  endfunction

  task run();

  for (int i=0;i<5;i++) begin

    t1 = new($sformatf("t1_%0d",i));
    t2 = new($sformatf("t2_%0d",i));

    assert(t1.randomize & t2.randomize);
    pair = new;
    pair.first = t1;
    pair.second = t2;
  
    $display ("**INFO 1 %s", pair.convert2string());

    $cast (pair2 , pair.clone());
    $display ("**INFO 2 %s", pair2.convert2string());
  
    // check that the comparison results should be 1
    assert (pair.compare(pair2)==1)
    else begin
      $display ("ERROR in %0s line %0d The Two pairs are equales and the comparison result should be 1", `__FILE__,  `__LINE__);
      errors ++;
    end
  end

  if (errors ==0)
      $write("** UVM TEST PASSED **\n");
   else
      $write("** UVM TEST FAILED **\n");

    uvm_top.stop_request();
  endtask

endclass

initial begin

  run_test();
end
  

endmodule
