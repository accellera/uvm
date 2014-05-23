//---------------------------------------------------------------------- 
//   Copyright 2013 Verilab, Inc. 
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

//----------------------------------------------------------------------
//   Mantis Bug: 4032
//
//   pre: It should be possible to override a factory with itself to emulate
//   and "undo". set_type_override_by_type warnings that you are overriding
//   with the original and then returns without doing the override.  
//
//   post: If the override is of the original type, the code still warns
//   but the override just still happen.  This test confirms that 
//   code change in uvm_factory.svh.
//----------------------------------------------------------------------

import uvm_pkg::*;
`include "uvm_macros.svh"

class simple_data extends uvm_sequence_item;
   rand bit [3:0] abc;
   rand bit [3:0] xyz;
        bit id;

   `uvm_object_utils_begin(simple_data)
      `uvm_field_int(abc, UVM_ALL_ON)
      `uvm_field_int(xyz, UVM_ALL_ON)
   `uvm_object_utils_end

   function new(string name = "simple_data");
      super.new(name);
      id = 0;
   endfunction: new

   virtual function bit get_id( );
      return id;
   endfunction: get_id

   virtual function bit [3:0] get_abc( );
      return abc;
   endfunction: get_abc

   virtual function bit [3:0] get_xyz( );
      return xyz;
   endfunction: get_xyz
endclass: simple_data

class constrained_data extends simple_data;
   `uvm_object_utils(constrained_data)

   constraint abc_con { abc == 'ha; }
   constraint xyz_con { xyz == 'h3; }

   function new(string name = "constrained_data");
      super.new(name);
      id = 1;
   endfunction: new

endclass: constrained_data

class top_env extends uvm_env;
   simple_data       pkt;
   constrained_data  cpkt;

   `uvm_component_utils(top_env)

   function new(string name, uvm_component parent);
      super.new(name, parent);
   endfunction: new

   function void build_phase(uvm_phase phase);
      super.build_phase(phase);
       pkt  = simple_data::type_id::create("pkt", this);
      cpkt  = constrained_data::type_id::create("cpkt", this);
   endfunction: build_phase

endclass: top_env

class base_test extends uvm_test;
   `uvm_component_utils(base_test)

   top_env env;
   uvm_table_printer printer;

   function new(string name, uvm_component parent);
      super.new(name, parent);
   endfunction: new

   virtual function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      env = top_env::type_id::create("env", this);

      //Override simple_data with constrained_data.  This will eventually be overriden again
      //by simple_data which is the original type.
      set_type_override_by_type(simple_data::get_type( ), constrained_data::get_type( ));
      printer = new( );
      printer.knobs.depth = 5;
   endfunction: build_phase

   virtual task run_phase(uvm_phase phase);
      assert(env.pkt.randomize( ));   
      assert(env.cpkt.randomize( ));   
      `uvm_info(get_type_name( ), $sformatf("  pkt: abc = %h xyz = %h id = %0b", env.pkt.get_abc, env.pkt.get_xyz, env.pkt.get_id), UVM_LOW)
      `uvm_info(get_type_name( ), $sformatf(" cpkt: abc = %h xyz = %h id = %0b", env.cpkt.get_abc, env.cpkt.get_xyz, env.cpkt.get_id), UVM_LOW)
   endtask: run_phase   
endclass: base_test

class test extends base_test;
   `uvm_component_utils(test)

   function new(string name, uvm_component parent);
      super.new(name, parent);
   endfunction: new

   virtual function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      set_type_override_by_type(simple_data::get_type( ), simple_data::get_type( ));
   endfunction: build_phase

   virtual task run_phase(uvm_phase phase);
      super.run_phase(phase);
      if(env.pkt.get_id( ) == env.cpkt.get_id) begin
         `uvm_error(get_type_name( ), "Packet IDs are the same so the override did not take affect.")
         $write("** UVM TEST FAILED **\n");
      end
      else
         $write("** UVM TEST PASSED **\n");
   endtask: run_phase

endclass: test

module top;
   initial begin
      run_test("test" );
   end
endmodule
