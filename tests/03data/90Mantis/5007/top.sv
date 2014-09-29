import uvm_pkg::*;
`include "uvm_macros.svh"

//------------------------------------------------------------------------------
// MODULE TOP
//------------------------------------------------------------------------------

module top;

`define MY_INT_BUFF_SIZE 1000

class my_opt_packer extends uvm_packer;

  int unsigned m_ints [`MY_INT_BUFF_SIZE];
  int unsigned int_counter;
  int unsigned bit_offset;
  logic [63:0] bit_buffer;

  function void clear();
      reset();
      bit_buffer = 0;
      int_counter = 0;
      bit_offset = 0;
  endfunction

  function new();
      // m_ints = new [ (`MY_INT_BUFF_SIZE) ];
      clear();
  endfunction

  function void pack_field_int (uvm_integral_t value, int size);
      if (bit_offset != 0) begin
          m_packed_size += bit_offset;
          bit_offset = 0;
          int_counter++;
      end

      if (size <= 32) begin
          m_ints[int_counter++] = value[32:0];
          m_packed_size += 32;
      end
      else begin
          m_ints[int_counter++] = value[31:0];
          m_ints[int_counter++] = value[63:32];
          m_packed_size += 64;
      end
  endfunction : pack_field_int
  
  function void pack_field_array_element_int (logic [31:0] value, int size);
      // Assuming temporarily for speed that size is a power of 2

      if (size == 1) begin
          bit_buffer[bit_offset++] = value[0];
      end
      else begin
          bit_buffer[bit_offset +: 32] = value;
          bit_offset += size;
      end
      if (bit_offset == 32) begin
          bit_offset = 0;
          m_ints[int_counter++] = bit_buffer[31:0];
          m_packed_size += 32;
          bit_buffer = 0;
      end
  endfunction : pack_field_array_element_int

  function void get_ints(ref int unsigned ints[]);
      if (bit_offset != 0) begin
          m_packed_size += bit_offset;
          m_ints[int_counter++] = bit_buffer[31:0];
          int_counter++;
          bit_offset = 0;
          bit_buffer = 0;
      end

      ints = m_ints;
  endfunction : get_ints
  
  function int get_packed_size();
      return m_packed_size;
  endfunction
endclass : my_opt_packer
   
class my_data extends uvm_object;
  `uvm_object_utils(my_data)
      
  bit f1;
  int f2;
  bit f3;
  int f4;
  bit f5;
  int f6;
  bit f7;
  int f8;
  bit f9;
  int f10;
  bit f11;
  int f12;
  bit f13;
  int f14;
  bit f15;
  int f16;

  bit payload [100000];

  function new(string name="");
    super.new(name);
  endfunction : new

  virtual function int pack_opt (ref int unsigned ints[], input my_opt_packer packer);
      int j = 0;

      packer.pack_field_int(f1, $bits(f1));
      packer.pack_field_int(f2, $bits(f2));
      packer.pack_field_int(f3, $bits(f3));
      packer.pack_field_int(f4, $bits(f4));
      packer.pack_field_int(f5, $bits(f5));
      packer.pack_field_int(f6, $bits(f6));
      packer.pack_field_int(f7, $bits(f7));
      packer.pack_field_int(f8, $bits(f8));
      packer.pack_field_int(f9, $bits(f9));
      packer.pack_field_int(f10, $bits(f10));
      packer.pack_field_int(f11, $bits(f11));
      packer.pack_field_int(f12, $bits(f12));
      packer.pack_field_int(f13, $bits(f13));
      packer.pack_field_int(f14, $bits(f14));
      packer.pack_field_int(f15, $bits(f15));
      packer.pack_field_int(f16, $bits(f16));

      foreach (payload[j])
          packer.pack_field_array_element_int(payload[j], 1);

      packer.get_ints(ints);
      return packer.get_packed_size();
  endfunction : pack_opt

endclass : my_data

class my_data_non_opt extends my_data;
  `uvm_object_utils_begin(my_data_non_opt)
      `uvm_field_int(f1, UVM_PACK);
      `uvm_field_int(f2, UVM_PACK);
      `uvm_field_int(f3, UVM_PACK);
      `uvm_field_int(f4, UVM_PACK);
      `uvm_field_int(f5, UVM_PACK);
      `uvm_field_int(f6, UVM_PACK);
      `uvm_field_int(f7, UVM_PACK);
      `uvm_field_int(f8, UVM_PACK);
      `uvm_field_int(f9, UVM_PACK);
      `uvm_field_int(f10, UVM_PACK);
      `uvm_field_int(f11, UVM_PACK);
      `uvm_field_int(f12, UVM_PACK);
      `uvm_field_int(f13, UVM_PACK);
      `uvm_field_int(f14, UVM_PACK);
      `uvm_field_int(f15, UVM_PACK);
      `uvm_field_int(f16, UVM_PACK);

      `uvm_field_sarray_int(payload, UVM_PACK);
  `uvm_object_utils_end

     function new(string name="");
    super.new(name);
  endfunction : new

endclass

//////////////

virtual class test_base extends uvm_component;

  my_data d;

  function new(string name="", uvm_component parent = null);
      super.new(name, parent);
  endfunction : new
  
  virtual function void test_f();
  endfunction

  virtual task run_phase(uvm_phase phase);
      test_f();
  endtask

endclass

class test extends test_base;
  `uvm_component_utils(test)

  bit my_biststream[];

  function new(string name="", uvm_component parent = null);
    super.new(name, parent);
  endfunction : new
  
  function void test_f();
      my_data_non_opt dno;
      int k;

      dno = new;

      my_biststream = new [`MY_INT_BUFF_SIZE * 32];
      for  (k = 0; k < 2000; k++) begin
          assert (dno.pack(my_biststream) > 0);
      end
  endfunction: test_f

endclass : test

class test_opt extends test_base;
  int unsigned my_intstream[];

  `uvm_component_utils(test_opt)

  function new(string name="", uvm_component parent = null);
    super.new(name, parent);
  endfunction : new
  
  function void test_f();

      my_opt_packer packer;

      int unsigned ints[];
      int k = 0;

      packer = new;
      d = new;

      for  (k = 0; k < 2000; k++) begin
          packer.clear();
          assert (d.pack_opt(ints, packer) > 0);
      end
  endfunction: test_f

endclass : test_opt

initial begin
  run_test();
end

endmodule: top
