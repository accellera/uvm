//------------------------------------------------------------------------------
//   Copyright 2013 Mentor Graphics Corporation
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

import uvm_pkg::* ; 
`include "uvm_macros.svh" 

class master_agent extends uvm_component;
 `uvm_component_utils( master_agent )

   function new(string name, uvm_component parent ) ;
      super.new(name, parent);
   endfunction

   task reset_phase(uvm_phase phase);
     phase.raise_objection(this,get_name(),10) ; 
        uvm_report_info(get_name(), "reset phase at master_agent ------------->") ;
     phase.drop_objection(this,get_name(),10) ; 
   endtask

   virtual function void raised (uvm_objection objection, uvm_object source_obj, 
         string description, int count);
         $display ("reset ---------- Raised at %s ----------",get_name());
   endfunction

   virtual function void dropped (uvm_objection objection, uvm_object source_obj, 
      string description, int count);
      $display ("reset ---------- Dropped at %s ----------",get_name());
   endfunction

endclass

//-//-//-//-//-//-//-//-

class env extends uvm_env;
 `uvm_component_utils( env )
   master_agent  m_master_agent;
   master_agent  m_master_agent2;

   function new(string name, uvm_component parent ) ;
      super.new(name, parent);
      m_master_agent = new("MASTER_AGENT",this);

`ifndef case2
      m_master_agent2 = new("MASTER_AGENT2",this);
`endif

   endfunction

`ifndef case1
   task reset_phase(uvm_phase phase);
     phase.raise_objection(this) ; 
        uvm_report_info(get_name(), "reset phase at ENV -------------->") ;
     phase.drop_objection(this) ; 
   endtask
`endif

   virtual function void dropped (uvm_objection objection, uvm_object source_obj, 
      string description, int count);
      $display ("reset ---------- Dropped at ENV ----------");
   endfunction

   virtual function void raised (uvm_objection objection, uvm_object source_obj, 
      string description, int count);
      $display ("reset ---------- Raised at ENV ----------");
   endfunction

endclass

//-//-//-//-//-//-//-//-

class test extends uvm_test ;
 `uvm_component_utils( test ) 
   env env1;
        
  function new(string name, uvm_component parent ) ;
     super.new(name, parent) ;
     env1 = new("ENV1",this);
  endfunction

  virtual function void raised (uvm_objection objection, uvm_object source_obj, 
        string description, int count);
        $display ("reset ---------- Raised at %s ----------",get_name());
  endfunction

   virtual function void dropped (uvm_objection objection, uvm_object source_obj, 
      string description, int count);
      $display ("reset ---------- Dropped at %s ----------",get_name());
   endfunction

   virtual function void report_phase(uvm_phase phase);
      // if we got to this phase, we did not get a FATAL
      $display("*** UVM TEST PASSED ***");
   endfunction


endclass

//-//-//-//-//-//-//-//-

module test ; 
  initial begin
	run_test("user_test") ;
  end

endmodule

