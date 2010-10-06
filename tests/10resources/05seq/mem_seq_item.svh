typedef enum
{
  MEM_READ,
  MEM_WRITE
//  MEM_NOP
} mem_op_t;

//----------------------------------------------------------------------
// mem_seq_item
//----------------------------------------------------------------------
class mem_seq_item #(int unsigned ADDR_SIZE=16, int unsigned DATA_SIZE=8)
  extends uvm_sequence_item;

  typedef mem_seq_item #(ADDR_SIZE, DATA_SIZE) this_type;
  `uvm_object_param_utils(this_type)

  rand bit [DATA_SIZE-1:0] data;
  rand bit [ADDR_SIZE-1:0] addr;
  rand mem_op_t op;

  function string convert2string();
    string s;
    string fmt;

    // Set up address and data print formats based on size
    int unsigned data_chars = ((DATA_SIZE >> 2) + ((DATA_SIZE & 'h3) > 0));
    int unsigned addr_chars = ((ADDR_SIZE >> 2) + ((ADDR_SIZE & 'h3) > 0));
    $sformat(fmt, "%%s: addr=%%0%0dx  data=%%0%0dx", addr_chars, data_chars);

    $sformat(s, fmt, op.name(), addr, data);

    return s;
  endfunction

endclass
