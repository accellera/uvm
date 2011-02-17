//----------------------------------------------------------------------
//   Copyright 2010-2011 Synopsys, Inc.
//   Copyright 2010 Mentor Graphics Corporation
//   Copyright 2011 Cadence Design Systems, Inc.
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
//

import uvm_pkg::*;
`include "uvm_macros.svh"

//------------------------------------------------------------------------------
// MODULE TOP
//------------------------------------------------------------------------------

module top;

initial run_test();
   
   
class test extends uvm_test;
   bit pass = 1;
   `uvm_component_utils(test)
   function new(string name, uvm_component parent = null);
      super.new(name, parent);
   endfunction

   byte unsigned da[];
   byte unsigned be[];
  
   task run_phase(uvm_phase phase);
      uvm_tlm_gp  obj=new;
      
      uvm_top.set_report_id_action("ILLEGALNAME",UVM_NO_ACTION);
     
      obj.m_address           = 'hF00D;
      obj.m_command           = UVM_TLM_WRITE_COMMAND;
      begin
	byte unsigned x[3]='{2,3,4};
        obj.m_data=x;
      end 
      // obj.m_data              = new [3] ('{2, 3, 4});
      obj.m_length            = 3;
      obj.m_response_status   = UVM_TLM_INCOMPLETE_RESPONSE;
      obj.m_dmi               = 0; //NYI
      begin
	byte unsigned  x[3]='{1,0,1};
	obj.m_byte_enable=x;
      end
      //obj.m_byte_enable       = new [3] ('{1, 0, 1});
      obj.m_byte_enable_length= obj.m_length;
      obj.m_streaming_width   = obj.m_length; 

      if (obj.get_command() !=       obj.m_command           ) begin
          `uvm_error("TEST", "get_command");
     end
      if (obj.get_address()!=        obj.m_address           ) begin
          `uvm_error("TEST", "get_address");
     end    

      obj.get_data(da);      
      foreach (obj.m_data[i])
	if (da[i] !=	obj.m_data[i] ) begin
           `uvm_error("TEST", "get_data");
	end
      
     if (obj.get_data_length()!=	     obj.m_length            ) begin
          `uvm_error("TEST", "get_data_length");
     end
      if (obj.get_streaming_width()!=        obj.m_streaming_width   ) begin
          `uvm_error("TEST", "get_streaming_width");
      end

      obj.get_byte_enable(be);
      foreach (obj.m_byte_enable[i])
      if (be[i]!=	                     obj.m_byte_enable[i]    ) begin
          `uvm_error("TEST", "get_byte_enable");
     end
      if (obj.get_byte_enable_length()!=     obj.m_byte_enable_length) begin
          `uvm_error("TEST", "get_byte_enabled");
     end
      if (obj.is_dmi_allowed()!=	     obj.m_dmi               ) begin
          `uvm_error("TEST", "is_dmi_allowed");
     end
      if (obj.is_response_ok()!=	     0                       ) begin
          `uvm_error("TEST", "is_response_ok");
     end
     if ( obj.get_response_status()!=	     obj.m_response_status   ) begin
          `uvm_error("TEST", "get_response_status");
     end     
     if ( obj.get_response_string()!=   "INCOMPLETE") begin
	`uvm_error("TEST", "get_response_string");
     end
     if ( obj.is_response_error() != 1 ) begin 
	 `uvm_error("TEST", "is_response_error");
     end 
      if (obj.is_read() != 0 ) begin
	 `uvm_error("TEST", "is_read");
     end 
      if (obj.is_write() != 1 ) begin
	 `uvm_error("TEST", "is_write");
     end 
	 

      
      obj.set_write(); //set m_comand=UVM_TLM_WRITE_COMMAND
      if (UVM_TLM_WRITE_COMMAND !=       obj.m_command           ) begin
          `uvm_error("TEST", "m_command WRITE");
      end
      obj.set_read(); //set m_comand=UVM_TLM_READ_COMMAND
      if (UVM_TLM_READ_COMMAND !=       obj.m_command           ) begin
          `uvm_error("TEST", "m_command READ");
      end 
      obj.set_command(UVM_TLM_IGNORE_COMMAND);
      if (UVM_TLM_IGNORE_COMMAND !=       obj.m_command           ) begin
          `uvm_error("TEST", "m_command WRITE");
      end
      obj.set_address('hDEADBEEF);
      if ('hdeadbeef !=        obj.m_address           ) begin
         `uvm_error("TEST", "set_address");
      end 
      obj.set_response_status(UVM_TLM_BYTE_ENABLE_ERROR_RESPONSE);
      if(UVM_TLM_BYTE_ENABLE_ERROR_RESPONSE !=  obj.m_response_status   ) begin
         `uvm_error("TEST", "set_response_status");
      end
      //da = new[4] ('{2, 3, 4, 5});
begin
	byte unsigned x[4]='{2,3,4,5};
	da=x;
end
      obj.set_data(da);
      foreach (obj.m_data[i])
	if (da[i] !=	obj.m_data[i] ) begin
           `uvm_error("TEST", "set_data");
	end
      obj.set_data_length(4);      
     if (    4!= obj.m_length            ) begin
          `uvm_error("TEST", "set_data_length");
     end
     obj.set_streaming_width(7);
     if (7!=        obj.m_streaming_width   ) begin
          `uvm_error("TEST", "set_streaming_width");
     end

//      be = new [4] ('{0,1, 0,1});
begin
byte unsigned x[4]='{0,1,0,1};
be=x;
end

      obj.set_byte_enable(be);
      foreach (obj.m_byte_enable[i])
	if (be[i]!= obj.m_byte_enable[i]    ) begin
          `uvm_error("TEST", "set_byte_enable");
	end
       obj.set_byte_enable_length(4);
      if (4 != obj.m_byte_enable_length               ) begin
          `uvm_error("TEST", "set_byte_enable_length");
     end
     obj.set_dmi_allowed(1);
      if (1 != obj.m_dmi               ) begin
          `uvm_error("TEST", "set_dmi_allowed");
     end
   endtask // run_phase
   
   virtual function void report_phase(uvm_phase phase);
      uvm_report_server svr = uvm_report_server::get_server();
      if (svr.get_severity_count(UVM_ERROR) > 0) pass = 0;
       $write("** UVM TEST %sED **\n", (pass) ? "PASS" : "FAIL");
   endfunction
 endclass
endmodule
