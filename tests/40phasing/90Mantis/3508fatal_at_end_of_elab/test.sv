//---------------------------------------------------------------------- 
//   Copyright 2011 Cadence 
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


program top;

    import uvm_pkg::*;
`include "uvm_macros.svh"

    class fatal_error_catcher extends uvm_report_catcher;
        int unsigned count=0;
        virtual function action_e catch();
            if("BUILDERR" != get_id()) return THROW;
            if(get_severity() != UVM_FATAL) return THROW;
            uvm_report_info("FATAL CATCHER", "From fatal_error_catcher catch()", UVM_MEDIUM , `uvm_file, `uvm_line );
            count++; 
            return CAUGHT;
        endfunction
    endclass

    class test extends uvm_test;
        fatal_error_catcher fec;
        `uvm_component_utils(test)

        function new(string name, uvm_component parent = null);
            super.new(name, parent);
        endfunction

        virtual function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            fec = new;
            uvm_report_cb::add(null,fec);
            
            `uvm_error("TEST","some build error");
        endfunction

        virtual function void connect_phase(uvm_phase phase);
            super.connect_phase(phase);
            `uvm_error("TEST","some build error");
        endfunction
                    
        virtual task run();
           uvm_top.stop_request();
        endtask

        virtual function void report();
            if(fec.count==1)
                $write("** UVM TEST PASSED **\n");
        endfunction
    endclass


    initial
    begin
        $write("UVM TEST EXPECT 2 UVM_ERROR\n");
        
        run_test();
    end

endprogram
