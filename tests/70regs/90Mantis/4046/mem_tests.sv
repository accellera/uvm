`ifndef __MEM_TESTS_SV__
`define __MEM_TESTS_SV__


class mem_base_test extends uvm_test;

   `uvm_component_utils(mem_base_test)

   mem_env top_env;
   uvm_table_printer printer;

   mem_reg_block reg_model;
   
   function new(string name = "mem_base_test",
                uvm_component parent = null);
      super.new(name,parent);
   endfunction // new

   
   virtual function void build_phase(uvm_phase phase);
      super.build_phase(phase);

      // Create the top level environment
      top_env = mem_env::type_id::create("top_env", this);

      // Create the CDMAHP register model
      reg_model = mem_reg_block::type_id::create("reg_model");
      reg_model.build();
      void'(reg_model.reset());
      uvm_config_db #(mem_reg_block)::set(this, "*", "reg_model", reg_model);
      
      // Create a specific depth printerr for printing the created topology
      printer = new();
      printer.knobs.depth = 4;
      printer.knobs.name_width  = 45;
      printer.knobs.type_width  = 30;
      printer.knobs.value_width = 30;

      //set a watchdog time (in ps)
      set_global_timeout(500000);        // 500ns
      set_global_stop_timeout(500000);   // 500ns
   endfunction // build_phase

   
   virtual task run_phase(uvm_phase phase);
      super.run_phase(phase);
      //set a drain-time for the environment if desired
      uvm_test_done.set_drain_time(this, 10000);
   endtask // run_phase
endclass // mem_base_test

/////////////////////////////////////////////////////////////////
// Tests from Test Plan /////////////////////////////////////////
/////////////////////////////////////////////////////////////////
//class mem_reg_model_test extends mem_base_test;
class test extends mem_base_test;

   `uvm_component_utils(test)
   
   // Sequences for running
   mem_reg_model_seq        seq;
   
      
   function new(string name = "mem_reg_model_test",
                uvm_component parent = null);
      super.new(name,parent);
   endfunction // new

   virtual task run_phase(uvm_phase phase);
      super.run_phase(phase);

      seq = mem_reg_model_seq::type_id::create("seq", , get_full_name());
      seq.start(top_env.mem_agt.sequencer, , -1, 1);
       $display("UVM TEST PASSED");
  endtask // run
endclass // mem_reg_model_test



`endif // __MEM_TESTS_SV__
