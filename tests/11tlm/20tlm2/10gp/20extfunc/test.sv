//----------------------------------------------------------------------
//   Copyright 2010-2011 Synopsys, Inc.
//   Copyright 2010 Mentor Graphics Corporation
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

`ifndef NUM_TRANS
`define NUM_TRANS 10
`endif


import uvm_pkg::*;
`include "uvm_macros.svh"

//------------------------------------------------------------------------------
// MODULE TOP
//------------------------------------------------------------------------------

module top;
     
initial run_test();
   
 `ifdef INCA
typedef class ext1;
typedef ext1 ext1_ext;

class ext1 extends uvm_tlm_extension#(ext1_ext);
   rand byte a;
   `uvm_object_utils_begin(ext1)      
     `uvm_field_int(a, UVM_DEFAULT)
   `uvm_object_utils_end

  function new(string name="ext1");
     super.new(name);
  endfunction

endclass

typedef class ext2;
typedef ext2 ext2_ext;

class ext2 extends uvm_tlm_extension#(ext2_ext);
 rand byte b;
 rand byte c;
   `uvm_object_utils_begin(ext2)      
     `uvm_field_int(b, UVM_DEFAULT)
     `uvm_field_int(c, UVM_DEFAULT)
   `uvm_object_utils_end


  function new(string name="ext2");
     super.new(name);
  endfunction

endclass

`else

class ext1 extends uvm_tlm_extension#(ext1);
 rand byte a;
   `uvm_object_utils_begin(ext1)      
     `uvm_field_int(a, UVM_DEFAULT)
   `uvm_object_utils_end


  function new(string name="ext1");
     super.new(name);
  endfunction

endclass

class ext2 extends uvm_tlm_extension#(ext2);
 rand byte b;
 rand byte c;
   `uvm_object_utils_begin(ext2)      
     `uvm_field_int(b, UVM_DEFAULT)
     `uvm_field_int(c, UVM_DEFAULT)
   `uvm_object_utils_end


  function new(string name="ext2");
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


   function void filter(ref string s1, ref string s2);
     int i,j;
     string tmp;
     
 /*    
     tmp = s1.substr(i,i+6);
     while (tmp != "address") begin
       i++;
       tmp = s1.substr(i,i+6);
     end
     s1 = s1.substr(i,s1.len()-1);
     s2 = s2.substr(i,s2.len()-1);
     i = 0;
     tmp = s1.substr(i,i+8);
     while (tmp != "ext1_inst") begin
       i++;
       tmp = s1.substr(i,i+8);
     end
     j = i+1;
     while (s1[j] != "\n")
       j++;
     s1 = {s1.substr(0,i+8),s1.substr(j,s1.len()-1)};
     s2 = {s2.substr(0,i+8),s2.substr(j,s2.len()-1)};
     */
     strip_id(s1);
     strip_id(s2);
     
    endfunction

    function void strip_id(ref string s);
        bit in_id=0;
        int i=0;
        bit p;
        while(i<s.len()) begin
            if(in_id && s[i] inside {["0":"9"]," "})
                if(p==0)
                    begin s[i]="X"; p=1; end
                else begin
                    s={s.substr(0,i-1),s.substr(i+1,s.len()-1)}; 
                    i--;
                end
            else
                in_id=0;
                    
            if(s[i]=="@") begin in_id=1; p=0; end
           
           i++;   
        end
    endfunction

   // compare without considering extensions
   function bit compare_base_gp (uvm_tlm_gp gp1, uvm_tlm_gp gp2);
      if ( !(gp1.m_address == gp2.m_address &&
             gp1.m_command == gp2.m_command &&
             gp1.m_length == gp2.m_length &&
             gp1.m_byte_enable_length == gp2.m_byte_enable_length &&
             gp1.m_streaming_width == gp2.m_streaming_width) )
        return 0;
      for (int i=0; i< gp1.m_length; i++)
        if (gp1.m_data[i] != gp2.m_data[i])
          return 0;
      for (int i=0; i< gp1.m_byte_enable_length; i++)
        if (gp1.m_byte_enable[i] != gp2.m_byte_enable[i])
          return 0;
      return 1;
   endfunction

   task run_phase(uvm_phase phase);
      uvm_tlm_gp  obj1=new,obj2=new;
      uvm_tlm_gp  save_gp;
      uvm_object obj;
      bit bits[];

      ext1 x1 = new("ext1_inst1");
      ext1 x2 = new("ext1_inst2");
      ext2 x3 = new("ext2_inst1");
     
      phase.raise_objection(this);

      assert(x1.randomize());
      assert(x2.randomize() with {a != x1.a;});
      assert(x3.randomize());
   
      void'(obj1.set_extension(x1));

    uvm_default_packer.use_metadata = 1;
    uvm_default_packer.big_endian = 0;

    uvm_top.set_report_id_action("ILLEGALNAME",UVM_NO_ACTION);

    //obj1.enable_recording("obj1");

    $display("\NUM_TRANS=%0d",`NUM_TRANS);

    for (int i=0; i<`NUM_TRANS; i++) begin

       $display("*** TRANS %0d ***",i);

       assert( obj1.randomize() with { 
          m_address >= 0 && m_address < 256; 
          m_length == `NUM_TRANS; 
          m_data.size == m_length;
          m_byte_enable_length <= m_length;
          (m_byte_enable_length % 4) == 0;
          m_byte_enable.size == m_byte_enable_length;
          foreach (m_byte_enable[i])
            m_byte_enable[i] inside { 0, 255 };
          m_streaming_width == m_length; 
				     } );

       assert( obj2.randomize() with { 
          m_address != obj1.m_address; 
          m_length == obj1.m_length-1; //ensure different sizes
          m_data.size == m_length;
          m_byte_enable_length <= m_length;
          (m_byte_enable_length % 4) == 0;
          m_byte_enable.size == m_byte_enable_length;
          foreach (m_byte_enable[i])
            m_byte_enable[i] inside { 0, 255 };
          m_streaming_width == m_length; 
				     } );

       obj = obj2.clone();
       $cast(save_gp,obj2.clone());

     //---------------------------------
     // COPY
     //---------------------------------

     obj2.copy(obj1);

     //---------------------------------
     // COMPARE
     //---------------------------------

     if(!obj1.compare(obj2))
       `uvm_fatal("MISCOMPARE",$sformatf("MISCOMPARE detected on generic payload!"));
        
     //---------------------------------
     // CONVERT2STRING
     //---------------------------------

     begin
     string s1,s2;

     s1 = obj1.convert2string();
     s2 = obj2.convert2string();
     if (s1 != s2)
       `uvm_fatal("MISCOMPARE",$sformatf("convert2string different!\nobj1=%s\nobj2=%s",s1,s2))
     end

     //---------------------------------
     // PRINT/SPRINT
     //---------------------------------

     begin
     string s1,s2;


     s1 = obj1.sprint(uvm_default_table_printer);
     s2 = obj2.sprint(uvm_default_table_printer);
     filter(s1,s2); 
     if (s1 != s2)
       `uvm_fatal("MISCOMPARE",{"Sprint table:\nobj1=\n",s1,"\nobj2=\n",s2})

     s1 = obj1.sprint(uvm_default_tree_printer);
     s2 = obj2.sprint(uvm_default_tree_printer);
     filter(s1,s2); 
     if (s1 != s2)
       `uvm_fatal("MISCOMPARE",{"Sprint tree:\nobj1=\n|",s1," \nobj2=\n|",s2,"|"})

     s1 = obj1.sprint(uvm_default_line_printer);
     s2 = obj2.sprint(uvm_default_line_printer);
     filter(s1,s2); 
     if (s1 != s2)
       `uvm_fatal("MISCOMPARE",{"Sprint line:\nobj1=\n",s1,"\nobj2=\n",s2})

     end

     //---------------------------------
     // PACK/UNPACK
     //---------------------------------

     // reset obj2, add extension
     obj2 = save_gp;
     void'(obj2.set_extension(x2));
     void'(obj2.set_extension(x3));

     void'(obj1.pack(bits));
     void'(obj2.unpack(bits));

     if (!compare_base_gp(obj1, obj2))
     if (!obj1.compare(obj2)) begin
                  `uvm_error("TEST", "obj2's base properties should be equal to obj1's");
       obj1.print();
       obj2.print();
     end

     // confirm obj2's extension is untouched
     if (obj2.get_extension(ext1::ID()) != x2)
     //if (obj2.get_extension(ext2.get_type_handle()) != ext2)
                  `uvm_error("TEST", "obj2's extensions should be untouched");
    
    
     //---------------------------------
     // RECORD
     //---------------------------------

     void'(obj1.begin_tr());
     #10;
     obj1.m_data[i] = i;
     obj1.end_tr();


   end // for (..NUM_TRANS..)

     //---------------------------------
     // PRINT - take 2
     //---------------------------------

     // test output of sprint(table); need to make data deterministic (i.e. assign constants)
     begin
       string exp;
       string act;
       byte unsigned data[];
       uvm_default_printer.knobs.reference = 0;
       data = new[4];
       data = '{'h11,'h22,'h33,'h44};
       obj2.set_data(data);
       obj2.set_byte_enable_length(0);
       obj2.set_data_length(4);
       obj2.set_address(64'h1234567890abcdef);
       obj2.set_command(UVM_TLM_WRITE_COMMAND);
       obj2.set_response_status(UVM_TLM_OK_RESPONSE);
       obj2.set_streaming_width('h87654321);
       x2.a = 'hff;
       x3.b = 'h55;
       x3.c = 'haa;
       obj2.print();
       exp = {exp, "-------------------------------------------------------------------------\n"};
       exp = {exp, "Name               Type                       Size  Value                \n"};
       exp = {exp, "-------------------------------------------------------------------------\n"};
       exp = {exp, "<unnamed>          uvm_tlm_generic_payload    -     -                    \n"};
       exp = {exp, "  address          integral                   64    'h1234567890abcdef   \n"};
       exp = {exp, "  command          uvm_tlm_command_e          32    UVM_TLM_WRITE_COMMAND\n"};
       exp = {exp, "  response_status  uvm_tlm_response_status_e  32    UVM_TLM_OK_RESPONSE  \n"};
       exp = {exp, "  streaming_width  integral                   32    'h87654321           \n"};
       exp = {exp, "  data             darray(byte)               4     -                    \n"};
       exp = {exp, "    [0]            byte                       8     'h11                 \n"};
       exp = {exp, "    [1]            byte                       8     'h22                 \n"};
       exp = {exp, "    [2]            byte                       8     'h33                 \n"};
       exp = {exp, "    [3]            byte                       8     'h44                 \n"};
       exp = {exp, "  extensions       aa(obj,obj)                2     -                    \n"};
       exp = {exp, "    [ext1_inst2]   ext1                       -     -                    \n"};
       exp = {exp, "      a            integral                   8     'hff                 \n"};
       exp = {exp, "    [ext2_inst1]   ext2                       -     -                    \n"};
       exp = {exp, "      b            integral                   8     'h55                 \n"};
       exp = {exp, "      c            integral                   8     'haa                 \n"};
       exp = {exp, "-------------------------------------------------------------------------\n"};
       act = obj2.sprint(uvm_default_table_printer);
       if (act != exp)  begin
          `uvm_error("TEST", "obj2's print output is unexpected");
          $display("\nEXPECT:\n%s\n\n",exp);
          $display("\nACTUAL:\n%s\n\n",act);
        end
     end

  phase.drop_objection(this);

endtask // run_phase
   
   virtual function void report_phase(uvm_phase phase);
      uvm_report_server svr = uvm_report_server::get_server();
      if (svr.get_severity_count(UVM_ERROR) > 0) pass = 0;
       $write("** UVM TEST %sED **\n", (pass) ? "PASS" : "FAIL");
endfunction
endclass
endmodule
