//---------------------------------------------------------------------- 
//   Copyright 2010-2011 Cadence Design Systems, Inc. 
//   Copyright 2010-2011 Mentor Graphics Corporation
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


module top;

    import uvm_pkg::*;
`include "uvm_macros.svh"

    // Test the simple setting of default sequences for a couple of
    // different phases, configure and main.
    string def_seqs[string];

    class myseq extends uvm_sequence #(uvm_sequence_item);
        `uvm_object_utils(myseq)

        function new(string name="myseq");
            super.new(name);
        endfunction
  
        task body();
            string name;
            if (starting_phase==null)
                `uvm_fatal("STARTING_PHASE_NULL", "Internal error. Sequence's starting_phase member is not defined")

                name = starting_phase.get_name();

            starting_phase.raise_objection(this);
            def_seqs[name] = get_name();
            `uvm_info(starting_phase.get_name(), "Starting myseq!!!", UVM_NONE)
            #10;
            `uvm_info(starting_phase.get_name(), "Ending myseq!!!", UVM_NONE)
            starting_phase.drop_objection(this);
        endtask
    endclass

    class myseq2 extends uvm_sequence #(uvm_sequence_item);
        `uvm_object_utils(myseq2)

        function new(string name="myseq");
            super.new(name);
        endfunction
  
        task body();
            string name;
            if (starting_phase==null)
                `uvm_fatal("STARTING_PHASE_NULL", "Internal error. Sequence's starting_phase member is not defined")

                name = starting_phase.get_name();

            starting_phase.raise_objection(this);
            def_seqs[name] = get_name();
            `uvm_info(starting_phase.get_name(), "Starting myseq2!!!", UVM_NONE)
            #10;
            `uvm_info(starting_phase.get_name(), "Ending myseq2!!!", UVM_NONE)
            starting_phase.drop_objection(this);
        endtask
    endclass



    class myseqr extends uvm_sequencer;
        function new(string name="myseqr", uvm_component parent);
            super.new(name,parent);
        endfunction
        `uvm_component_utils(myseqr)

        function void build_phase(uvm_phase phase);
            uvm_config_db #(uvm_object_wrapper)::set(this, "reset_phase", "default_sequence", myseq::type_id::get());
            uvm_config_db #(uvm_object_wrapper)::set(this, "configure_phase", "default_sequence", myseq::type_id::get());
            uvm_config_db #(uvm_object_wrapper)::set(this, "main_phase", "default_sequence", myseq::type_id::get());
            uvm_config_db #(uvm_object_wrapper)::set(this, "shutdown_phase", "default_sequence", myseq::type_id::get());
        endfunction

        function void phase_started(uvm_phase phase);
            `uvm_info(phase.get_name(), "Phase started",UVM_NONE)
        endfunction

    endclass


    class myenv extends uvm_env;
        myseqr seqr;
        function new(string name = "myenv", uvm_component parent = null);
            super.new(name, parent);
        endfunction

        `uvm_component_utils(myenv)

        function void build_phase(uvm_phase phase);
            myseq2 rst_seq = new("rst_seq");
            myseq2 cfg_seq = new("cfg_seq");
            myseq2 main_seq = new("main_seq");
            myseq2 shut_seq = new("shut_seq");
            seqr = new("seqr", this);
            uvm_config_db #(uvm_object_wrapper)::set(this, "seqr.reset_phase", "default_sequence", myseq2::type_id::get());
            uvm_config_db #(uvm_object_wrapper)::set(this, "seqr.configure_phase", "default_sequence", myseq2::type_id::get());
            uvm_config_db #(uvm_object_wrapper)::set(this, "seqr.main_phase", "default_sequence", myseq2::type_id::get());
            uvm_config_db #(uvm_object_wrapper)::set(this, "seqr.shutdown_phase", "default_sequence", myseq2::type_id::get());

            // Instances takes precedence...
            uvm_config_db #(uvm_sequence_base)::set(this, "seqr.reset_phase", "default_sequence", rst_seq);
            uvm_config_db #(uvm_sequence_base)::set(this, "seqr.configure_phase", "default_sequence", cfg_seq);
            uvm_config_db #(uvm_sequence_base)::set(this, "seqr.main_phase", "default_sequence", main_seq);
            uvm_config_db #(uvm_sequence_base)::set(this, "seqr.shutdown_phase", "default_sequence", shut_seq);
        endfunction
   
    endclass


    class test extends uvm_test;
        myenv env;
        string exp_def_seqs[string]; 
 
        function new(string name = "my_comp", uvm_component parent = null);
            super.new(name, parent);
            uvm_resource_options::turn_on_auditing();
      
            exp_def_seqs["reset"]="rst_seq";
            exp_def_seqs["main"]="myseq2";
            exp_def_seqs["shutdown"]="shut_seq";
      
        endfunction

        `uvm_component_utils(test)

        function void build_phase(uvm_phase phase);
            env = new("env", this);

            // RESET: disable type-based setting for reset-> no affect, instance setting takes precedence
            uvm_config_db #(uvm_object_wrapper)::set(this, "env.seqr.reset_phase", "default_sequence", null); // Expect rst_seq

            // CONFIGURE: disable both default seq settings for configure phase
            uvm_config_db #(uvm_object_wrapper)::set(this, "env.seqr.configure_phase", "default_sequence", null); // Expect no seq
            uvm_config_db #(uvm_sequence_base)::set(this, "env.seqr.configure_phase", "default_sequence", null);

            // MAIN:  disable only the instance, so type-based "bubbles" to the top
            uvm_config_db #(uvm_sequence_base)::set(this, "env.seqr.main_phase", "default_sequence", null); // Expect myseq2

            // SHUTDOWN: leave both settings in place->instance setting should run                               // Expect shut_seq

        endfunction
   
        function void report_phase(uvm_phase phase);
            bit err;

            uvm_resource_pool rp = uvm_resource_pool::get();
            rp.dump(1);

            if ($time != 30) begin
                `uvm_error("SIMTIME",$sformatf("Expected sim to end at 30, not %0t",$time))
                err = 1;
            end

            if (def_seqs.num() != 3) begin
                `uvm_error("NUMSEQS",$sformatf("Expected number of default sequences to be 3, not %0d",def_seqs.num()))
                err = 1;
            end

            foreach (exp_def_seqs[ph]) begin
                if (!def_seqs.exists(ph)) begin
                    `uvm_error("DEFSEQS",{"A default sequence did not run in the ", ph, " phase"})
                    err = 1;
                end
                else if (def_seqs[ph] != exp_def_seqs[ph]) begin
                    `uvm_error("DEFSEQS",{"The wrong default sequence ran in the ", ph, " phase. Expected ", exp_def_seqs[ph],", got ", def_seqs[ph]})
                    err = 1;
                end
            end

            if (!err)
                $display("*** UVM TEST PASSED ***");
            else
                $display("*** UVM TEST FAILED ***");
        endfunction
   
    endclass

    initial
    begin
        run_test();
    end

endmodule
