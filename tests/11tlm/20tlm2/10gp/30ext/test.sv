//---------------------------------------------------------------------- 
//   Copyright 2010-2011 Synopsys, Inc. 
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

`ifdef INCA

typedef class ext1;
typedef class ext2;
typedef class ext3;
typedef ext1 ext1_ext;
typedef ext2 ext2_ext;
typedef ext3 ext3_ext;

class ext1 extends uvm_tlm_extension#(ext1_ext);
   byte a;
   `uvm_object_utils_begin(ext1)      
     `uvm_field_int(a, UVM_DEFAULT)
   `uvm_object_utils_end

  function new(string name="ext1");
     super.new(name);
  endfunction

endclass

class ext2 extends uvm_tlm_extension#(ext2_ext);
   byte b;
   `uvm_object_utils_begin(ext2)      
     `uvm_field_int(b, UVM_DEFAULT)
   `uvm_object_utils_end

  function new(string name="ext2");
     super.new(name);
  endfunction

endclass

class ext3 extends uvm_tlm_extension#(ext3_ext);
   byte c;
   `uvm_object_utils_begin(ext3)      
     `uvm_field_int(c, UVM_DEFAULT)
   `uvm_object_utils_end

  function new(string name="ext3");
     super.new(name);
  endfunction

endclass

class ext3x extends ext3;
   `uvm_object_utils(ext3x)

  function new(string name="ext3x");
     super.new(name);
  endfunction

endclass

`else

class ext1 extends uvm_tlm_extension#(ext1);
 byte a;
   `uvm_object_utils_begin(ext1)      
     `uvm_field_int(a, UVM_DEFAULT)
   `uvm_object_utils_end


  function new(string name="ext1");
     super.new(name);
  endfunction

endclass

class ext2 extends uvm_tlm_extension#(ext2);
   byte b;
   `uvm_object_utils_begin(ext2)      
     `uvm_field_int(b, UVM_DEFAULT)
   `uvm_object_utils_end

  function new(string name="ext2");
     super.new(name);
  endfunction

endclass

class ext3 extends uvm_tlm_extension#(ext3);
 byte c;
   `uvm_object_utils_begin(ext3)      
     `uvm_field_int(c, UVM_DEFAULT)
   `uvm_object_utils_end

  function new(string name="ext3");
     super.new(name);
  endfunction

endclass

class ext3x extends ext3;
   `uvm_object_utils(ext3x)

  function new(string name="ext3x");
     super.new(name);
  endfunction

endclass

`endif

class test extends uvm_test;
   bit pass = 1;

   `uvm_component_utils(test)

   function new(string name, uvm_component parent = null);
      super.new(name, parent);
   endfunction

   virtual task run_phase(uvm_phase phase);
      uvm_tlm_gp gp1 = new;
      uvm_tlm_gp gp2 = new;
      uvm_tlm_gp gp3;
      ext1 x1 = new;
      ext2 x2 = new;
      ext3x x3x = new;
      ext3 x3 = x3x;
      ext1 y1;
      ext2 y2;
      ext3 y3;

      void'(gp1.set_extension(x1));
      if (gp1.get_num_extensions() != 1) begin
         `uvm_error("TEST", $sformatf("Number of GP1 extensions reported as %0d instead of 1", 
				      gp1.get_num_extensions()));
      end
      if (gp2.get_num_extensions() != 0) begin
         `uvm_error("TEST", $sformatf("Number of GP2 extensions reported as %0d instead of 0", 
				      gp2.get_num_extensions()));
      end
      void'(gp2.set_extension(x3));

      if (!$cast(y1, gp1.get_extension(ext1::ID()))) begin
         `uvm_error("TEST", "GP1 did not return the correct EXT1 extension");
      end
      if (y1 != x1) begin
         `uvm_error("TEST", "GP1 did not return the correct EXT1 instance");
      end
      if (!$cast(y2, gp1.get_extension(ext2::ID()))) begin
         `uvm_error("TEST", "GP1 did not return the correct EXT2 extension");
      end
      if (y2 != null) begin
         `uvm_error("TEST", "GP1 did not return the correct EXT2 instance");
      end
      if (!$cast(y3, gp1.get_extension(ext3::ID()))) begin
         `uvm_error("TEST", "GP1 did not return the correct EXT3 extension");
      end
      if (y3 != null) begin
         `uvm_error("TEST", "GP1 did not return the correct EXT3 instance");
      end
      
      if (!$cast(y1, gp2.get_extension(ext1::ID()))) begin
         `uvm_error("TEST", "GP2 did not return the correct EXT1 extension");
      end
      if (y1 != null) begin
         `uvm_error("TEST", "GP2 did not return the correct EXT1 instance");
      end
      if (!$cast(y2, gp2.get_extension(ext2::ID()))) begin
         `uvm_error("TEST", "GP2 did not return the correct EXT2 extension");
      end
      if (y2 != null) begin
         `uvm_error("TEST", "GP2 did not return the correct EXT2 instance");
      end
      if (!$cast(y3, gp2.get_extension(ext3::ID()))) begin
         `uvm_error("TEST", "GP2 did not return the correct EXT3 extension");
      end
      if (y3 != x3) begin
         `uvm_error("TEST", "GP2 did not return the correct EXT3 instance");
      end

      if (!$cast(gp3, gp2.clone()) || gp3 == null) begin
         `uvm_error("TEST", "Unable to clone GP2");
      end
      
      if (!$cast(y1, gp3.get_extension(ext1::ID()))) begin
         `uvm_error("TEST", "GP3 did not return the correct EXT1 extension");
      end
      if (y1 != null) begin
         `uvm_error("TEST", "GP3 did not return the correct EXT1 instance");
      end
      if (!$cast(y2, gp3.get_extension(ext2::ID()))) begin
         `uvm_error("TEST", "GP3 did not return the correct EXT2 extension");
      end
      if (y2 != null) begin
         `uvm_error("TEST", "GP3 did not return the correct EXT2 instance");
      end
      if (!$cast(y3, gp3.get_extension(ext3::ID()))) begin
         `uvm_error("TEST", "GP3 did not return the correct EXT3 extension");
      end
      if (y3 == null) begin
         `uvm_error("TEST", "GP3 does not have a EXT3 instance");
      end
      if (y3 == x3) begin
         `uvm_error("TEST", "GP3 did not deep-copy EXT3 instance");
      end
      gp1.print();

     gp1.clear_extensions();
      if (gp1.get_num_extensions() != 0) begin
         `uvm_error("TEST", $sformatf("Number of GP1 extensions reported as %0d instead of 0", 
				      gp1.get_num_extensions()));
      end

      gp3.print();

      uvm_top.stop_request();
   endtask

   virtual function void report();
      uvm_report_server svr = uvm_report_server::get_server();
      if (svr.get_severity_count(UVM_ERROR) > 0) pass = 0;
      $write("** UVM TEST %sED **\n", (pass) ? "PASS" : "FAIL");
   endfunction
endclass

initial
begin
   run_test(); 
end
endprogram

