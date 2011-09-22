//---------------------------------------------------------------------- 
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
//----------------------------------------------------------------------

//Field Macros print test
//Pass/Fail criteria:
//If the printer output matches the expected string.
//

string expected = {
"-----------------------------------------------------------------------\n",
"Name               Type               Size  Value                      \n",
"-----------------------------------------------------------------------\n",
"uvm_sequence_item  myobject           -     -                          \n",
"  i                integral           32    'h5555                     \n",
"  b                integral           8     aa                         \n",
"  bigint           integral           129   'h1aaaa5555aaaa5555aaaaaaaa\n",
"  s                string             7     ABCDEFG                    \n",
"  ob               subobject          -     -                          \n",
"    i              integral           32    'h0                        \n",
"    str            string             7     default                    \n",
"  r                real               64    123.456000                 \n",
"  ia               da(integral)       4     -                          \n",
"    [0]            integral           32    'h0                        \n",
"    [1]            integral           32    'h1                        \n",
"    [2]            integral           32    'h2                        \n",
"    [3]            integral           32    'h3                        \n",
"  ba               da(integral)       4     -                          \n",
"    [0]            integral           8     'd0                        \n",
"    [1]            integral           8     -1                         \n",
"    [2]            integral           8     -2                         \n",
"    [3]            integral           8     -3                         \n",
"  biginta          da(integral)       4     -                          \n",
"    [0]            integral           129   'h1aaaa5555aaaa5555aaaa5555\n",
"    [1]            integral           129   'h1aaaa5555aaaa5555aaaa5556\n",
"    [2]            integral           129   'h1aaaa5555aaaa5555aaaa5557\n",
"    [3]            integral           129   'h1aaaa5555aaaa5555aaaa5558\n",
"  numa             array(numbers)     4     -                          \n",
"  sa               da(string)         4     -                          \n",
"    [0]            string             2     S1                         \n",
"    [1]            string             2     S2                         \n",
"    [2]            string             2     S3                         \n",
"    [3]            string             2     S4                         \n",
"  ca               da(object)         4     -                          \n",
"    [0]            subobject          -     -                          \n",
"      i            integral           32    'h64                       \n",
"      str          string             2     S3                         \n",
"    [1]            subobject          -     -                          \n",
"      i            integral           32    'h65                       \n",
"      str          string             2     S4                         \n",
"    [2]            subobject          -     -                          \n",
"      i            integral           32    'h66                       \n",
"      str          string             2     S1                         \n",
"    [3]            subobject          -     -                          \n",
"      i            integral           32    'h67                       \n",
"      str          string             2     S2                         \n",
"  iq               da(integral)       4     -                          \n",
"    [0]            integral           32    'h1000                     \n",
"    [1]            integral           32    'h2000                     \n",
"    [2]            integral           32    'h3000                     \n",
"    [3]            integral           32    'h4000                     \n",
"  bq               da(integral)       4     -                          \n",
"    [0]            integral           8     'd0                        \n",
"    [1]            integral           8     -1                         \n",
"    [2]            integral           8     -2                         \n",
"    [3]            integral           8     -3                         \n",
"  bigintq          da(integral)       4     -                          \n",
"    [0]            integral           129   'h1aaaa5555aaaa5555aaaa5555\n",
"    [1]            integral           129   'h1aaaa5555aaaa5555aaaa5556\n",
"    [2]            integral           129   'h1aaaa5555aaaa5555aaaa5557\n",
"    [3]            integral           129   'h1aaaa5555aaaa5555aaaa5558\n",
"  numq             array(numbers)     4     -                          \n",
"  sq               da(string)         4     -                          \n",
"    [0]            string             2     S1                         \n",
"    [1]            string             2     S2                         \n",
"    [2]            string             2     S3                         \n",
"    [3]            string             2     S4                         \n",
"  cq               da(object)         4     -                          \n",
"    [0]            subobject          -     -                          \n",
"      i            integral           32    'ha                        \n",
"      str          string             2     S1                         \n",
"    [1]            subobject          -     -                          \n",
"      i            integral           32    'hb                        \n",
"      str          string             2     S2                         \n",
"    [2]            subobject          -     -                          \n",
"      i            integral           32    'hc                        \n",
"      str          string             2     S3                         \n",
"    [3]            subobject          -     -                          \n",
"      i            integral           32    'hd                        \n",
"      str          string             2     S4                         \n",
"  isa              sa(integral)       4     -                          \n",
"    [0]            integral           32    'h0                        \n",
"    [1]            integral           32    'h1                        \n",
"    [2]            integral           32    'h2                        \n",
"    [3]            integral           32    'h3                        \n",
"  bsa              sa(integral)       4     -                          \n",
"    [0]            integral           8     'd0                        \n",
"    [1]            integral           8     -1                         \n",
"    [2]            integral           8     -2                         \n",
"    [3]            integral           8     -3                         \n",
"  bigintsa         sa(integral)       4     -                          \n",
"    [0]            integral           129   'h1aaaa5555aaaa5555aaaa5555\n",
"    [1]            integral           129   'h1aaaa5555aaaa5555aaaa5556\n",
"    [2]            integral           129   'h1aaaa5555aaaa5555aaaa5557\n",
"    [3]            integral           129   'h1aaaa5555aaaa5555aaaa5558\n",
"  numsa            array(numbers)     4     -                          \n",
"  ssa              sa(string)         4     -                          \n",
"    [0]            string             2     S1                         \n",
"    [1]            string             2     S2                         \n",
"    [2]            string             2     S3                         \n",
"    [3]            string             2     S4                         \n",
"  csa              sa(object)         4     -                          \n",
"    [0]            subobject          -     -                          \n",
"      i            integral           32    'h12c                      \n",
"      str          string             2     S4                         \n",
"    [1]            subobject          -     -                          \n",
"      i            integral           32    'h12d                      \n",
"      str          string             2     S1                         \n",
"    [2]            subobject          -     -                          \n",
"      i            integral           32    'h12e                      \n",
"      str          string             2     S2                         \n",
"    [3]            subobject          -     -                          \n",
"      i            integral           32    'h12f                      \n",
"      str          string             2     S3                         \n",
"  aa_is            aa(int,string)     4     -                          \n",
"    [S1]           integral           32    'h0                        \n",
"    [S2]           integral           32    'h1                        \n",
"    [S3]           integral           32    'h2                        \n",
"    [S4]           integral           32    'h3                        \n",
"  aa_ii            aa(int,int)        4     -                          \n",
"    [0]            integral           32    'h0                        \n",
"    [1]            integral           32    'h1                        \n",
"    [2]            integral           32    'h2                        \n",
"    [3]            integral           32    'h3                        \n",
"  aa_ss            aa(string,string)  4     -                          \n",
"    [S1]           string             2     S3                         \n",
"    [S2]           string             2     S4                         \n",
"    [S3]           string             2     S1                         \n",
"    [S4]           string             2     S2                         \n",
"  aa_os            aa(object,string)  4     -                          \n",
"    [S1]           subobject          -     -                          \n",
"      i            integral           32    'ha                        \n",
"      str          string             2     S1                         \n",
"    [S2]           subobject          -     -                          \n",
"      i            integral           32    'hb                        \n",
"      str          string             2     S2                         \n",
"    [S3]           subobject          -     -                          \n",
"      i            integral           32    'hc                        \n",
"      str          string             2     S3                         \n",
"    [S4]           subobject          -     -                          \n",
"      i            integral           32    'hd                        \n",
"      str          string             2     S4                         \n",
"  aa_oi            aa(object,int)     4     -                          \n",
"    [0]            subobject          -     -                          \n",
"      i            integral           32    'ha                        \n",
"      str          string             2     S1                         \n",
"    [1]            subobject          -     -                          \n",
"      i            integral           32    'hb                        \n",
"      str          string             2     S2                         \n",
"    [2]            subobject          -     -                          \n",
"      i            integral           32    'hc                        \n",
"      str          string             2     S3                         \n",
"    [3]            subobject          -     -                          \n",
"      i            integral           32    'hd                        \n",
"      str          string             2     S4                         \n",
"  aa_ibu           aa(int,int)        4     -                          \n",
"    [0]            integral           32    'h0                        \n",
"    [1]            integral           32    'h1                        \n",
"    [2]            integral           32    'h2                        \n",
"    [3]            integral           32    'h3                        \n",
"  aa_iiu           aa(int,int)        4     -                          \n",
"    [0]            integral           32    'h0                        \n",
"    [1]            integral           32    'h1                        \n",
"    [2]            integral           32    'h2                        \n",
"    [3]            integral           32    'h3                        \n",
"  aa_inum          aa_numbers         4     -                          \n",
"    [ONE]          integral           32    'h0                        \n",
"    [TWO]          integral           32    'h1                        \n",
"    [THREE]        integral           32    'h2                        \n",
"    [FOUR]         integral           32    'h3                        \n",
"-----------------------------------------------------------------------\n"
};

module test;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  typedef enum bit [1:0] { ONE, TWO, THREE, FOUR } numbers;
  typedef enum bit [2:0] { RED, ORANGE, YELLOW, GREEN, BLUE, INDIGO, VIOLET } colors;

  string strings[$];

  class subobject extends uvm_object;
    colors color = RED;
    int    i = 0;
    string str = "default";

    `uvm_object_utils_begin(subobject)
      `uvm_field_enum(colors, color, UVM_DEFAULT)
      `uvm_field_int(i, UVM_DEFAULT)
      `uvm_field_string(str, UVM_DEFAULT)
    `uvm_object_utils_end

  function new(string name="subobject");
     super.new(name);
  endfunction

  endclass

  class myobject extends uvm_sequence_item;
    int i;
    byte b;
    logic [128:0] bigint;
    string s; 
    subobject ob;
    numbers num;
    real r;

    int ia[];
    byte ba[];
    logic [128:0] biginta[];
    string sa[]; 
    subobject ca[];
    numbers numa[];

    int isa[4];
    byte bsa[4];
    logic [128:0] bigintsa[4];
    string ssa[4]; 
    subobject csa[4];
    numbers numsa[4];

    int iq[$];
    byte bq[$];
    logic [128:0] bigintq[$];
    string sq[$]; 
    subobject cq[$];
    numbers numq[$];

    int aa_is[string];
    int aa_ii[int];

    string aa_ss[string];

    subobject aa_os[string];
    subobject aa_oi[int];

    int aa_ibu[byte unsigned];
    int aa_iiu[int unsigned];
    int aa_inum[numbers];


    `uvm_object_utils_begin(myobject)
      `uvm_field_int(i, UVM_DEFAULT)
      `uvm_field_int(b, UVM_DEFAULT|UVM_DEC)
      `uvm_field_int(bigint, UVM_DEFAULT)
      `uvm_field_enum(numbers, num, UVM_DEFAULT)
      `uvm_field_string(s, UVM_DEFAULT)
      `uvm_field_object(ob, UVM_DEFAULT)
      `uvm_field_real(r, UVM_DEFAULT)

      `uvm_field_array_int(ia, UVM_DEFAULT)
      `uvm_field_array_int(ba, UVM_DEFAULT|UVM_DEC)
      `uvm_field_array_int(biginta, UVM_DEFAULT)
      `uvm_field_array_enum(numbers, numa, UVM_DEFAULT)
      `uvm_field_array_string(sa, UVM_DEFAULT)
      `uvm_field_array_object(ca, UVM_DEFAULT)

      `uvm_field_queue_int(iq, UVM_DEFAULT)
      `uvm_field_queue_int(bq, UVM_DEFAULT|UVM_DEC)
      `uvm_field_queue_int(bigintq, UVM_DEFAULT)
      `uvm_field_queue_enum(numbers, numq, UVM_DEFAULT)
      `uvm_field_queue_string(sq, UVM_DEFAULT)
      `uvm_field_queue_object(cq, UVM_DEFAULT)

      `uvm_field_sarray_int(isa, UVM_DEFAULT)
      `uvm_field_sarray_int(bsa, UVM_DEFAULT|UVM_DEC)
      `uvm_field_sarray_int(bigintsa, UVM_DEFAULT)
      `uvm_field_sarray_enum(numbers, numsa, UVM_DEFAULT)
      `uvm_field_sarray_string(ssa, UVM_DEFAULT)
      `uvm_field_sarray_object(csa, UVM_DEFAULT)

      `uvm_field_aa_int_string(aa_is, UVM_DEFAULT)
      `uvm_field_aa_int_int(aa_ii, UVM_DEFAULT)

      `uvm_field_aa_string_string(aa_ss, UVM_DEFAULT)

      `uvm_field_aa_object_string(aa_os, UVM_DEFAULT)
      `uvm_field_aa_object_int(aa_oi, UVM_DEFAULT)

      `uvm_field_aa_int_byte_unsigned(aa_ibu, UVM_DEFAULT)
      `uvm_field_aa_int_int_unsigned(aa_iiu, UVM_DEFAULT)
      `uvm_field_aa_int_enumkey(numbers, aa_inum, UVM_DEFAULT)

    `uvm_object_utils_end

    function new(string name="myobject_inst");
      i = 'h5555;
      b = 'haa;
      bigint = 128'h1aaaa5555aaaa5555aaaa5555;
      s = "ABCDEFG";
      ob = new;
      r = 123.456;
      num = TWO;

      ia = new[4];
      ba = new[4];
      biginta = new[4];
      sa = new[4];
      ca = new[4];
      numa = new[4];

      foreach (ia[i]) begin
        // dynamic arrays
        ia[i] = i;
        ba[i] = -i;
        biginta[i] = 128'h1aaaa5555aaaa5555aaaa5555+i;
        sa[i] = strings[i];
        ca[i] = new;
         ca[i].color = colors'(2+i);
         ca[i].i = 100+i;
         ca[i].str = strings[3 & (i + 2)];
        numa[i] = numbers'(i);

        // queues
        iq.push_back('h1000 + i*'h1000);
        bq.push_back(-i);
        bigintq.push_back(128'h1aaaa5555aaaa5555aaaa5555+i);
        sq.push_back(strings[i]);
        numq.push_back(numbers'(3&(1+i)));
        begin
          subobject s = new;
          s.color = colors'(i);
          s.i = 10+i;
          s.str = strings[i];
          cq.push_back(s);
        end

        // static arrays
        isa[i] = i;
        bsa[i] = -i;
        bigintsa[i] = 128'h1aaaa5555aaaa5555aaaa5555+i;
        ssa[i] = strings[i];
        csa[i] = new;
         csa[i].color = colors'(3+i);
         csa[i].i = 300+i;
         csa[i].str = strings[3 & (3+i)];
        numsa[i] = numbers'(i);
      end

      // assoc arrays
      foreach (strings[i]) begin
        aa_ii[i] = i;
        aa_is[strings[i]] = i;
        aa_ss[strings[i]] = strings[3&(i+2)];
        aa_ibu[i] = i;
        aa_iiu[i] = i;
        aa_inum[numbers'(i)] = i;
        begin
          subobject s = new, o = new;
          s.color = colors'(i);
          s.i = 10+i;
          s.str = strings[i];
          aa_os[strings[i]] = s;
          s.color = colors'(i);
          s.i = 10+i;
          s.str = strings[i];
          aa_oi[i] = s;
        end
      end

      for (i=4; i <= 14; i++)
        iq.push_back('h1000 + i*'h1000);

    endfunction

  endclass
  class test extends uvm_test;
     string str;
     integer diff;
     integer fd;
    `uvm_new_func
    `uvm_component_utils(test)
    myobject obj = new;

    task run;
      integer mcd;
      int error;
      bit fail;

      obj.print();

      mcd = $fopen("actual_table.log");
      uvm_default_table_printer.knobs.mcd = mcd;
      uvm_default_table_printer.knobs.reference = 0;
      obj.print(uvm_default_table_printer);
      $fclose(mcd);

      mcd = $fopen("actual_tree.log");
      uvm_default_tree_printer.knobs.mcd = mcd;
      uvm_default_tree_printer.knobs.reference = 0;
      obj.print(uvm_default_tree_printer);
      $fclose(mcd);

      mcd = $fopen("actual_line.log");
      uvm_default_line_printer.knobs.mcd = mcd;
      uvm_default_line_printer.knobs.reference = 0;
      obj.print(uvm_default_line_printer);
      $fclose(mcd);
      
       $system("rm -f diff.log; diff expected_table.txt actual_table.log >  diff.log ");      
       fd = $fopen("diff.log","r"); diff= $fgets(str, fd);  $fclose(fd);       
      if (diff >0) begin
        `uvm_error("BAD_TABLE_PRINTER","Table printer actual output not as expected")
        fail = 1;
      end

       $system("rm -f diff.log; diff expected_tree.txt actual_tree.log >  diff.log ");      
       fd = $fopen("diff.log","r"); diff= $fgets(str, fd);  $fclose(fd);
      if (diff >0) begin
        `uvm_error("BAD_TREE_PRINTER","Tree printer actual output not as expected")
        fail = 1;
      end

       $system("rm -f diff.log; diff expected_line.txt actual_line.log >  diff.log ");      
       fd = $fopen("diff.log","r"); diff= $fgets(str, fd);  $fclose(fd);
      if (diff >0) begin
        `uvm_error("BAD_LINE_PRINTER","Line printer actual output not as expected")
        fail = 1;
      end

      if (fail)
        uvm_report_info("FAILED", "*** UVM TEST FAILED ***", UVM_NONE);
      else
        uvm_report_info("PASSED", "*** UVM TEST PASSED ***", UVM_NONE);

    endtask
  endclass

  initial begin
    strings.push_back("S1");
    strings.push_back("S2");
    strings.push_back("S3");
    strings.push_back("S4");
    run_test();
  end

endmodule
