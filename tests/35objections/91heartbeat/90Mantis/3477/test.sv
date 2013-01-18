//---------------------------------------------------------------------- 
//   Copyright 2012 Synopsys, Inc. 
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
program top;
    import uvm_pkg::*;


    class test extends uvm_test;
        `uvm_component_utils(test)
        uvm_heartbeat hb;
        uvm_callbacks_objection myobj;
        int failed = 0;     

        function new(string name, uvm_component parent);
            super.new(name,parent);
            myobj = new("heartbeat-objection-source");
            hb = new("this-heartbeat", this, myobj);
            hb.add(this);      
        endfunction
        task run_phase(uvm_phase phase);
            uvm_event e = new("e");
            super.run_phase(phase);

            phase.raise_objection(this);
    
            failed = 1;
            hb.start(e);
            failed = 0;
            #1;
            hb.stop();
            hb.start();
            #1;

            phase.drop_objection(this);
        endtask
        function void report_phase(uvm_phase phase);
            $write("** UVM TEST PASSED **\n");
        endfunction
    endclass
  
    initial run_test();
endprogram