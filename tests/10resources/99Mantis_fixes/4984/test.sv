//----------------------------------------------------------------------
//   Copyright 2013 Cadence Design Inc
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

module test;
   import uvm_pkg::*;

   initial begin
      string s;
      
      uvm_config_db#(string)::set(null,"","foo","somestring");
      uvm_config_db#(string)::set(null,"tb2","foo","somestring");
      assert(uvm_config_db#(string)::get(null,"tb1","foo",s)==0);
      if(s!="") uvm_report_fatal("TEST","uvm_config_db did return something not intented");

                begin
                        uvm_report_server svr;
                        svr = uvm_report_server::get_server();

                        if (svr.get_severity_count(UVM_ERROR)==0)
                                $write("** UVM TEST PASSED **\n");
                        else
                                $write("!! UVM TEST FAILED !!\n");

                        svr.report_summarize();

                end

   end
endmodule // test
