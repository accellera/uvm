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
        int count;
        virtual function action_e catch();
            if(get_id()=="UVM/PKG/DEPR_FACTORY_VAR/SET_INST_OVERRIDE_BY_NAME") begin
                $display("Caught a message...");
                count++;
                set_severity(UVM_INFO);
            end
            return THROW;
        endfunction
        function new(string name="unnamed-uvm_report_catcher");
            super.new(name);
        endfunction
    endclass


    class test extends uvm_test;
        my_catcher c;
        
        `uvm_component_utils(test)
        function new(string name, uvm_component parent);
            super.new(name, parent);
            c = new("c");
            uvm_report_cb::add(null,c);
        endfunction // new
        function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            factory.set_inst_override_by_name("uvm_component","test","*");
        endfunction : build_phase
        function void report_phase(uvm_phase phase);
            super.report_phase(phase);
            if (c.count == 0) begin
                `uvm_error("NO_MSG", "Didn't see the warning")
                $display("** UVM TEST FAILED **");
            end
            else if (c.count > 1) begin
                `uvm_error("MANY_MSG", "Saw too many warnings")
                $display("** UVM TEST FAILED **");
            end
            else begin
                $display("** UVM TEST PASSED **");
            end
        endfunction
    endclass

    initial begin
        run_test();
    end

endmodule 


