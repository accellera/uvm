`ifndef __MEM_SEQUENCES_SV__
`define __MEM_SEQUENCES_SV__


////////////////////////////////////
// VBUSM Sequences /////////////////
////////////////////////////////////
class mem_base_seq extends uvm_sequence #(mem_transfer);

   `uvm_object_utils(mem_base_seq)

   function new(string name = "mem_base_seq");
      super.new(name);
   endfunction // new

   // Raise in pre_body so the objection is only raised for root sequences.
   // There is no need to raise for sub-sequences since the root sequence
   // will encapsulate the sub-sequence. 
   virtual task pre_body();
      m_sequencer.uvm_report_info(get_type_name(),
                                  $psprintf("%s pre_body() raising an uvm_test_done objection", 
                                            get_sequence_path()), 
                                  UVM_FULL);
      uvm_test_done.raise_objection(this);
   endtask // pre_body

   // Drop the objection in the post_body so the objection is removed when
   // the root sequence is complete. 
   virtual task post_body();
      m_sequencer.uvm_report_info(get_type_name(),
                                  $psprintf("%s post_body() dropping an uvm_test_done objection", 
                                            get_sequence_path()), 
                                  UVM_FULL);
      uvm_test_done.drop_objection(this);
   endtask // post_body
endclass // vbusm_base_seq


class mem_reg_model_seq extends uvm_sequence;
   `uvm_object_utils(mem_reg_model_seq)

   function new(string name = "mem_reg_model_seq");
      super.new(name);
   endfunction // new

   // Raise in pre_body so the objection is only raised for root sequences.
   // There is no need to raise for sub-sequences since the root sequence
   // will encapsulate the sub-sequence. 
   virtual task pre_body();
      m_sequencer.uvm_report_info(get_type_name(),
                                  $psprintf("%s pre_body() raising an uvm_test_done objection", 
                                            get_sequence_path()), 
                                  UVM_FULL);
      uvm_test_done.raise_objection(this);
   endtask // pre_body

   // Drop the objection in the post_body so the objection is removed when
   // the root sequence is complete. 
   virtual task post_body();
      m_sequencer.uvm_report_info(get_type_name(),
                                  $psprintf("%s post_body() dropping an uvm_test_done objection", 
                                            get_sequence_path()), 
                                  UVM_FULL);
      uvm_test_done.drop_objection(this);
   endtask // post_body

   
   virtual task body();
      uvm_status_e    status;
      uvm_reg_data_t  value[];    
      int             uvm_reg_width_bytes = (`UVM_REG_DATA_WIDTH + 7) / 8;
      int             size = (512 + (uvm_reg_width_bytes-1)) / uvm_reg_width_bytes;
      mem_reg_block   reg_model;

      if (!uvm_config_db #(mem_reg_block)::get(null, {"uvm_test_top.", get_full_name()}, "reg_model", reg_model))
        `uvm_fatal("BAD_CONFIG","Cannot get() reg_model from uvm_config_db!");
      
      value = new[size];

      for (int i = 0; i < size; i++) begin
	 int loop_size = uvm_reg_width_bytes;
	 for (int j = 0; j < loop_size; j++) begin
	    value[i][(j*8)+7-:8] = (i*16)+j;
	 end
      end

      // Write to the VBUSM memory
      reg_model.mem.burst_write(.status(status), 
                                .offset(32'h0000_0000), 
                                .value(value));
   endtask // body   
endclass // mem_reg_model_seq



`endif // __MEM_SEQUENCES_SV__
