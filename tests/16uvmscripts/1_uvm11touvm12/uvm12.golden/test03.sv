//----------------------------------------------------------------------
//   Copyright 2012 Cadence Design Systems, Inc.
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

module top;
    import uvm_pkg::*;

    class my_catcher extends uvm_report_catcher;
        virtual function action_e catch();
            $display("Caught a message...\n",get_message());
            if(get_id()=="RNTST" && (get_message() == "Running test test...")) 
                set_severity(UVM_ERROR);
            return THROW;
        endfunction
        function new(string name="a2");
            super.new(name);
        endfunction
    endclass


    class test extends uvm_test;
        `uvm_component_utils(test)
        function new(string name, uvm_component parent);
            super.new(name, parent);
        endfunction
        function void report_phase(uvm_phase phase);
            super.report_phase(phase);
            $display("** UVM TEST FAILED **");
        endfunction
    endclass

    class test2 extends uvm_test;
        `uvm_component_utils(test2)
        function new(string name, uvm_component parent);
            super.new(name, parent);
        endfunction
        function void report_phase(uvm_phase phase);
            super.report_phase(phase);
            $display("** UVM TEST PASSED **");
        endfunction
    endclass

    initial begin
        my_catcher ctchr1;

        uvm_factory f;
        ctchr1 =  new("Catcher1");
        f = uvm_factory::get();
        f.set_type_override_by_name("test","test2"); 
        f.print();
        f.debug_create_by_name("test", "", "uvm_test_top");
        
        uvm_report_cb::add(null,ctchr1);

        run_test();
    end

endmodule 


