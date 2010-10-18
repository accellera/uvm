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

`include "xbus_reg_env.sv"
`include "xbus_example_master_seq_lib.sv"
`include "seq_lib.sv"

class cmd_line_seq_test extends uvm_test;

   `uvm_component_utils(cmd_line_seq_test);

   function new(string name = "cmd_line_seq_test", uvm_component parent = null);
      super.new(name, parent);
   endfunction: new

   typedef uvm_queue #(string) q_of_strings;
   bit virtual_seq_mode; 
   
   virtual task run();
     string seq_cmd;
     q_of_strings seqs[$]; 
     q_of_strings qos = new;
     uvm_report_server svr;
     xbus_reg_env env;

     $cast(env, uvm_top.lookup("env"));

     uvm_default_printer = uvm_default_line_printer;

     svr = _global_reporter.get_report_server();
     svr.set_max_quit_count(10);

     uvm_top.print(uvm_default_table_printer);

     if ($test$plusargs("VIRTUAL_SEQ")) begin
       virtual_seq_mode = 1;
     end

     if ($value$plusargs("UVM_SEQUENCE=%s",seq_cmd)) begin

       // Extract list of sequences
       int start_i = 0;
       string last = "";
       foreach (seq_cmd[i]) begin
         if (seq_cmd[i] == "," || seq_cmd[i] == "=") begin
           if (i > 0 && seq_cmd[i] == "," && seq_cmd[i-1] != "," && seq_cmd[i-1] != "=") begin
             if (last == "=") begin
               qos.push_back(seq_cmd.substr(start_i,i-(i<seq_cmd.len()-1)));
               if (qos.size())
                 seqs.push_back(qos);
               qos = new;
             end
             if (last == "" || last == ",") begin
               if (qos.size())
                 seqs.push_back(qos);
               qos = new;
               qos.push_back(seq_cmd.substr(start_i,i-(i<seq_cmd.len()-1)));
             end
             last = ",";
           end
           if (i > 0 && seq_cmd[i] == "=" && seq_cmd[i-1] != "," && seq_cmd[i-1] != "=") begin
             if (last == "" || last == ",") begin
               if (qos.size())
                 seqs.push_back(qos);
               qos = new;
             end
             qos.push_back(seq_cmd.substr(start_i,i-(i<seq_cmd.len()-1)));
             last = "=";
           end
           start_i = i+1;
         end
       end
       if (start_i <= seq_cmd.len()-1) begin
         if (last == "=") begin
           qos.push_back(seq_cmd.substr(start_i,seq_cmd.len()-1));
           seqs.push_back(qos);
         end
         else begin
           if (qos.size())
             seqs.push_back(qos);
           qos = new;
           qos.push_back(seq_cmd.substr(start_i,seq_cmd.len()-1));
           seqs.push_back(qos);
         end
       end

       // No sequences found
       if (!seqs.size()) begin
         `uvm_fatal("BAD_CMD_LINE",
                   {"Command line +UVM_SEQUENCE value must be one or more sequences ",
                   "separated by commas or equals with no spaces. Given value '",seq_cmd,
                   "' could not be parsed"})
       end

       // Execute sequences. Sequences must not depend on initial state.
       begin
         string msg;
         foreach (seqs[i]) begin
           string i_str;
           i_str.itoa(i+1);
           msg = {msg, "Group ",i_str,":\n  ",seqs[i].convert2string(),"\n"};
         end
         `uvm_info("SEQ_SCHED",{"Executing sequences as follows ",
            "(sequences within a group execute concurrently):\n",msg},UVM_LOW)
       end

       foreach (seqs[i]) begin
         uvm_sequencer_base sequencer;
         q_of_strings qos = seqs[i];
       $display("\n\n******* HERE i=%0d\n\n", i);
         for (int j=0; j<qos.size();j++) begin
           uvm_reg_sequence reg_seq;
           uvm_sequence_base seq;
       $display("\n\n******* HERE j=%0d\n\n", i);
           seq = uvm_utils #(uvm_sequence_base)::create_type_by_name(qos.get(j),"tb");
           if (seq == null) begin
              `uvm_fatal("SEQ_NOT_FOUND",
                         {"Command line +UVM_SEQUENCE specified a sequence '",qos.get(j),
                          "' that was not registered with the factory"});
           end
           `uvm_info("CMD_LINE_SEQ_TEST",{"\n\nStarting sequence '",qos.get(j),"' ..."},UVM_LOW)
           void'(seq.randomize());
           if ($cast(reg_seq,seq))
             reg_seq.regmem = env.rdb;

           if (virtual_seq_mode)
             sequencer = null;
           else
             sequencer = env.masters[0].sequencer;

           if (qos.size() == 1) begin
             seq.start(sequencer);
           end
           else begin
             fork
               seq.start(sequencer);
             join_none
           end
         end
         if (qos.size() != 1)
           wait fork;
       end
       global_stop_request();
     end

     else begin
         `uvm_fatal("NO_SEQUENCE",
           "This test requires you to specify the sequence to run using +UVM_SEQUENCE=<name>");
     end

   endtask

endclass
