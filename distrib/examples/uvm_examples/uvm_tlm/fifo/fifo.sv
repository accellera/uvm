//
//----------------------------------------------------------------------
//   Copyright 2007-2010 Mentor Graphics Corporation
//   Copyright 2007-2010 Cadence Design Systems, Inc.
//   Copyright 2010 Synopsys, Inc.
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


/*
About: uvm_examples/uvm_tlm/fifo
This test will illustrate how to create two threads producer and consumer which are completely independent, and connect them through a communication channel, here the channel used will be uvm_tlm_fifo.

The fifo throttles the communication.  This example will use the fifo channel, transaction-level ports, and the messaging facilities as part of the UVM library.
*/




package user_pkg;

  import uvm_pkg::*;
  
  //----------------------------------------------------------------------
  // class producer
  //----------------------------------------------------------------------
  class producer extends uvm_component;
  
    uvm_blocking_put_port #(int) put_port;
  
    function new(string name, uvm_component p = null);
      super.new(name,p);
      put_port = new("put_port", this);
    endfunction
  
    task run;
          
      int randval;
      string s;
      
      for(int i = 0; i < 10; i++)
        begin
          randval = $random % 100;
          //randval = i;
          $sformat(s, "sending     %4d", randval);
          uvm_report_info("producer", s);
          put_port.put(randval);
        end
    endtask
      
  endclass : producer
  
  //----------------------------------------------------------------------
  // class consumer
  //----------------------------------------------------------------------
  class consumer extends uvm_component;
  
    uvm_blocking_get_port #(int) get_port;
  
    function new(string name, uvm_component p = null);
      super.new(name,p);
      get_port = new("get_port", this);
    endfunction
  
    task run;
  
      int val;
      string s;
  
      forever
        begin
          get_port.get(val);
          $sformat(s, "receiving   %4d", val);
          uvm_report_info("consumer", s);
        end
  
    endtask
      
  endclass : consumer
  
  //----------------------------------------------------------------------
  // class env
  //----------------------------------------------------------------------
  class env extends uvm_env;
  
    producer p;
    consumer c;
    uvm_tlm_fifo #(int) f;
  
    function new(string name, uvm_component parent);
      super.new(name);
      p = new("producer", this);
      c = new("consumer", this);
      f = new("fifo", this);
    endfunction
  
    function void connect();
      p.put_port.connect(f.blocking_put_export);
      c.get_port.connect(f.blocking_get_export);
    endfunction
  
    task run();
      #100 global_stop_request();
    endtask
  endclass
  
endpackage

//----------------------------------------------------------------------
// module top
//----------------------------------------------------------------------
module top;
  import uvm_pkg::*;
  import user_pkg::*;

  env e;

  initial begin
    e = new("env", null);
    run_test();
    //$finish;
  end

endmodule : top
