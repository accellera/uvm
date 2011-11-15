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

`include "uvm_macros.svh"
program top;

    import uvm_pkg::*;

    string called[$];

    class trans extends uvm_sequence_item;
        `uvm_object_utils(trans)

        function new(string name = "");
            super.new(name);
        endfunction
    endclass


    class leaf_seq extends uvm_sequence#(trans);
        `uvm_object_utils(leaf_seq)

        function new(string name = "");
            super.new(name);
        endfunction

        task pre_start();
            called.push_back("leaf.pre_start()");
        endtask
   
        task pre_body();
            called.push_back("leaf.pre_body()");
        endtask
   
        task pre_do(bit is_item);
            called.push_back($sformatf("leaf.pre_do(%0d)", is_item));
        endtask
   
        function void mid_do(uvm_sequence_item this_item);
            called.push_back($sformatf("leaf.mid_do(%s)", this_item.get_type_name()));
        endfunction
   
        task body();
            called.push_back("leaf.body()");
            `uvm_do(req)
        endtask

        function void post_do(uvm_sequence_item this_item);
            called.push_back($sformatf("leaf.post_do(%s)", this_item.get_type_name()));
        endfunction
   
        task post_body();
            called.push_back("leaf.post_body()");
        endtask
   
        task post_start();
            called.push_back("leaf.post_start()");
        endtask
   
    endclass


    class mid_seq extends uvm_sequence;
        `uvm_object_utils(mid_seq)

        leaf_seq seq;
   
        function new(string name = "");
            super.new(name);
        endfunction
   
        task pre_start();
            called.push_back("mid.pre_start()");
        endtask
   
        task pre_body();
            called.push_back("mid.pre_body()");
        endtask
   
        task pre_do(bit is_item);
            called.push_back($sformatf("mid.pre_do(%0d)", is_item));
        endtask
   
        function void mid_do(uvm_sequence_item this_item);
            called.push_back($sformatf("mid.mid_do(%s)", this_item.get_type_name()));
        endfunction
   
        task body();
            called.push_back("mid.body()");
            `uvm_do(seq)
        endtask

        function void post_do(uvm_sequence_item this_item);
            called.push_back($sformatf("mid.post_do(%s)", this_item.get_type_name()));
        endfunction
   
        task post_body();
            called.push_back("mid.post_body()");
        endtask
   
        task post_start();
            called.push_back("mid.post_start()");
        endtask
   
    endclass


    class top_seq extends uvm_sequence;
        `uvm_object_utils(top_seq)

        mid_seq seq;
   
        function new(string name = "");
            super.new(name);
        endfunction
   
        task pre_start();
            called.push_back("top.pre_start()");
            if (starting_phase != null) starting_phase.raise_objection(this);
        endtask
   
        task pre_body();
            called.push_back("top.pre_body()");
        endtask
   
        task pre_do(bit is_item);
            called.push_back($sformatf("top.pre_do(%0d)", is_item));
        endtask
   
        function void mid_do(uvm_sequence_item this_item);
            called.push_back($sformatf("top.mid_do(%s)", this_item.get_type_name()));
        endfunction
   
        task body();
            called.push_back("top.body()");
            seq = new("seq");
            seq.start(get_sequencer(), this);
        endtask

        function void post_do(uvm_sequence_item this_item);
            called.push_back($sformatf("top.post_do(%s)", this_item.get_type_name()));
        endfunction
   
        task post_body();
            called.push_back("top.post_body()");
        endtask
   
        task post_start();
            called.push_back("top.post_start()");
            if (starting_phase != null) starting_phase.drop_objection(this);
        endtask
   
    endclass


    class test extends uvm_test;

        `uvm_component_utils(test)

        string exp[$];

        uvm_sequencer#(trans) sqr;
        uvm_seq_item_pull_port#(trans) seq_item_port;

        function new(string name, uvm_component parent = null);
            super.new(name, parent);

            begin
                exp.push_back("top.pre_start()");
                exp.push_back( "top.pre_body()");
                exp.push_back( "top.body()");
                exp.push_back( "mid.pre_start()");
                exp.push_back( "mid.pre_body()");
                exp.push_back( "top.pre_do(0)");
                exp.push_back( "top.mid_do(mid_seq)");
                exp.push_back( "mid.body()");
                exp.push_back( "leaf.pre_start()");
                exp.push_back( "mid.pre_do(0)");
                exp.push_back( "mid.mid_do(leaf_seq)");
                exp.push_back( "leaf.body()");
                exp.push_back( "leaf.pre_do(1)");
                exp.push_back( "leaf.mid_do(trans)");
                exp.push_back( "doing trans");
                exp.push_back( "leaf.post_do(trans)");
                exp.push_back( "mid.post_do(leaf_seq)");
                exp.push_back( "leaf.post_start()");
                exp.push_back( "top.post_do(mid_seq)");
                exp.push_back( "mid.post_body()");
                exp.push_back( "mid.post_start()");
                exp.push_back( "top.post_body()");
                exp.push_back( "top.post_start()");
              
            end
        endfunction

        virtual function void build_phase(uvm_phase phase);
            sqr = new("sqr", this);
            seq_item_port = new("seq_item_port", this);

            uvm_config_db#(uvm_object_wrapper)::set(this, "sqr.reset_phase",
                "default_sequence",
                top_seq::get_type());
        endfunction
   
        function void connect_phase(uvm_phase phase);
            seq_item_port.connect(sqr.seq_item_export);
        endfunction

        virtual task run_phase(uvm_phase phase);
            forever begin
                trans tr;
                seq_item_port.get_next_item(tr);
                called.push_back("doing trans");
                seq_item_port.item_done();
            end
        endtask

        virtual task post_reset_phase(uvm_phase phase);
            phase.raise_objection(this);

            if (exp != called) begin
                `uvm_error("TEST", "Bad callback call sequence in reset_phase")
                foreach (called[i]) begin
                    $write("Called: %s    Expected: %s\n", called[i],
                        (i < exp.size()) ? exp[i] : "(none)");
                end
                for(int i = called.size(); i <exp.size(); i++) begin
                    $write("Called: (none)   Expected: %s\n", exp[i]);
                end
            end
      
            called.delete();
      
            phase.drop_objection(this);
        endtask
   
        virtual task configure_phase(uvm_phase phase);
            top_seq seq = new("top");
      
            phase.raise_objection(this);
            seq.start(sqr);
            phase.drop_objection(this);
        endtask

        virtual task post_configure_phase(uvm_phase phase);
            phase.raise_objection(this);

            if (exp != called) begin
                `uvm_error("TEST", "Bad callback call sequence in reset_phase")
                foreach (called[i]) begin
                    $write("Called: %s    Expected: %s\n", called[i],
                        (i < exp.size()) ? exp[i] : "(none)");
                end
                for(int i = called.size(); i <exp.size(); i++) begin
                    $write("Called: (none)   Expected: %s\n", exp[i]);
                end
            end
      
            called.delete();

            phase.drop_objection(this);
        endtask
   
        function void report_phase(uvm_phase phase);
            uvm_report_server svr;
            svr = _global_reporter.get_report_server();

            if (svr.get_severity_count(UVM_FATAL) +
                    svr.get_severity_count(UVM_ERROR) == 0)
                $write("** UVM TEST PASSED **\n");
            else
                $write("!! UVM TEST FAILED !!\n");
        endfunction
    endclass


    initial run_test("test");

endprogram
