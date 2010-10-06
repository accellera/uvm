//----------------------------------------------------------------------
// mem_seq_rand
//----------------------------------------------------------------------
class mem_seq_rand #(int unsigned ADDR_SIZE=16, int unsigned DATA_SIZE=8)
  extends uvm_sequence #(mem_seq_item #(ADDR_SIZE, DATA_SIZE));

  typedef mem_seq_rand #(ADDR_SIZE, DATA_SIZE) this_type;
  typedef mem_seq_item #(ADDR_SIZE, DATA_SIZE) item_t;
  `uvm_object_param_utils(this_type)

  int unsigned loop_count;

  function new(string name="mem_seq_rand");
    super.new(name);
  endfunction

  task pre_body();

    // obtain the loop count from the resources database
    if(!uvm_resource_proxy#(int unsigned)::read_by_name("loop_count", "mem_seq", loop_count, this))
      loop_count = 5;

    $display("loop_count = %0d", loop_count);

  endtask

  task body();

    item_t item;
    int unsigned i;

    for(i = 0; i < loop_count; i++) begin
      assert($cast(item, create_item(item_t::get_type(),
                   m_sequencer, "mem_item")));
      start_item(item);
      assert(item.randomize());
      finish_item(item);
      get_response(item);
    end
  endtask

endclass
