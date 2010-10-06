//----------------------------------------------------------------------
//   Copyright 2010 Synopsys, Inc.
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

`include "seq_lib.sv"

class cmd_line_seq_test extends uvm_test;

   `uvm_component_utils(cmd_line_seq_test);

   function new(string name = "cmd_line_seq_test", uvm_component parent = null);
      super.new(name, parent);
   endfunction: new

   
   virtual task run();
     string seq_cmd;
     string seqs[$];
     uvm_report_server svr;
     xbus_ral_env env;

     $cast(env, uvm_top.lookup("env"));

     svr = _global_reporter.get_report_server();
     svr.set_max_quit_count(10);

     uvm_top.print();

     if ($value$plusargs("UVM_SEQUENCE=%s",seq_cmd)) begin

       // Extract list of sequences
       int start_i = 0;
       foreach (seq_cmd[i]) begin
         if (seq_cmd[i] == ",") begin
           if (i > 0 && seq_cmd[i-1] != ",")
             seqs.push_back(seq_cmd.substr(start_i,i-(i<seq_cmd.len()-1)));
           start_i = i+1;
         end
       end
       if (start_i <= seq_cmd.len()-1)
         seqs.push_back(seq_cmd.substr(start_i,seq_cmd.len()-1));

       // No sequences found
       if (!seqs.size()) begin
         `uvm_fatal("BAD_CMD_LINE",
                   {"Command line +UVM_SEQUENCE value must be one or more sequences ",
                   "separated by commas with no spaces. Given value '",seq_cmd,
                   "' could not be parsed"})
       end

       // Execute sequences sequentially. Sequences must not depend on initial state.
       foreach (seqs[i]) begin
         uvm_ral_sequence seq;
         seq = uvm_utils #(uvm_ral_sequence)::create_type_by_name(seqs[i],"tb");
         if (seq == null) begin
            `uvm_fatal("SEQ_NOT_FOUND",
                       {"Command line +UVM_SEQUENCE specified a sequence '",seqs[i],
                        "' that was not registered with the factory"});
         end
         `uvm_info("CMD_LINE_SEQ_TEST",{"\n\nStarting sequence '",seqs[i],"' ..."},UVM_LOW)
         seq.ral = env.rdb;
         seq.start(null);
       end
       global_stop_request();
     end

     else begin
         `uvm_fatal("NO_SEQUENCE",
           "This test requires you to specify the sequence to run using +UVM_SEQUENCE=<name>");
     end

   endtask

endclass
