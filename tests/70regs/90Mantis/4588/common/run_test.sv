//---------------------------------------------------------------------- 
//   Copyright 2011 Synopsys, Inc.
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
	 uvm_factory factory =uvm_factory::get();
	 
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

    function void report_phase(uvm_phase phase); uvm_coreservice_t cs_ = uvm_coreservice_t::get();

      uvm_report_server svr;
      svr = cs_.get_report_server();

      if (svr.get_id_count("uvm_reg_hw_reset_seq") >0)
	 `uvm_error("BLK_EXEC", "uvm_reg_hw_reset_seq has been executed on register block");

      if (svr.get_severity_count(UVM_FATAL) +
          svr.get_severity_count(UVM_ERROR) == 0)
         $write("** UVM TEST PASSED **\n");
      else
         $write("!! UVM TEST FAILED !!\n");
   endfunction


endclass : test



