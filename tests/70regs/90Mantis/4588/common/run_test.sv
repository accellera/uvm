/*********************************************************************
 * SYNOPSYS CONFIDENTIAL                 			     *
 *                               				     *
 * This is an unpublished, proprietary work of Synopsys, Inc., and   *
 * is fully protected under copyright and trade secret laws. You may *
 * not view, use, disclose, copy, or distribute this file or any     *
 * information contained herein except pursuant to a valid written   *
 * license from Synopsys.                                            *
 ********************************************************************/

typedef class dut_reset_seq;

class base_test extends uvm_test;

   `uvm_component_utils(base_test)
   tb_env env;

   function new(string name, uvm_component parent);
      super.new(name, parent);
   endfunction
  
   virtual function void build_phase(uvm_phase phase);
     $cast(env, uvm_top.find("env"));
 
   endfunction : build_phase

endclass: base_test   

class reset_test extends base_test;
   `uvm_component_utils(reset_test)
   function new(string name, uvm_component parent);
      super.new(name, parent);
   endfunction
   virtual task run_phase(uvm_phase phase);
     
      phase.raise_objection(this);
      begin
         dut_reset_seq rst_seq;
         rst_seq = dut_reset_seq::type_id::create("rst_seq", this);
         rst_seq.start(null);
      end
      phase.drop_objection(this);
   endtask:run_phase

endclass: reset_test

class test extends reset_test;

   `uvm_component_utils(test)

   function new(string name, uvm_component parent);
      super.new(name, parent);
   endfunction

   virtual task run_phase(uvm_phase phase);
      phase.raise_objection(this);
      
      $cast(env, uvm_top.find("env"));

      begin
         dut_reset_seq rst_seq;
         rst_seq = dut_reset_seq::type_id::create("rst_seq", this);
         rst_seq.start(null);
      end
      env.model.reset();
      void'(env.model.set_coverage(UVM_CVR_ALL));
   	
      begin
         uvm_cmdline_processor opts = uvm_cmdline_processor::get_inst();

         uvm_reg_sequence  seq;
         string            seq_name;

         void'(opts.get_arg_value("+UVM_REG_SEQ=", seq_name));
         
         if (!$cast(seq, factory.create_object_by_name(seq_name,
                                                       get_full_name(),
                                                       "seq"))
             || seq == null) begin
            `uvm_fatal("TEST/CMD/BADSEQ", {"Sequence ", seq_name,
                                           " is not a known sequence"})
         end
         seq.model = env.model;
         seq.start(null);
      end

      phase.drop_objection(this);
   endtask : run_phase

    function void report_phase(uvm_phase phase);
      uvm_report_server svr;
      svr = _global_reporter.get_report_server();

      if (svr.get_id_count("uvm_reg_hw_reset_seq") >0)
	 `uvm_error("BLK_EXEC", "uvm_reg_hw_reset_seq has been executed on register block");

      if (svr.get_severity_count(UVM_FATAL) +
          svr.get_severity_count(UVM_ERROR) == 0)
         $write("** UVM TEST PASSED **\n");
      else
         $write("!! UVM TEST FAILED !!\n");
   endfunction


endclass : test



