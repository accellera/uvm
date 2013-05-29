module test();

  import uvm_pkg::*;
`include "uvm_macros.svh"

  string seqlist[$];

  class seq_base extends uvm_sequence;
    
    `uvm_object_utils(seq_base)

    function new(string name = "seq_base");
      super.new(name);
    endfunction
    
    task body();
      seqlist.push_back({get_type_name(),"(",get_name(),")"});
    endtask
  endclass

  class seq1 extends seq_base;
    `uvm_object_utils(seq1)
    
    function new(string name = "seq1");
      super.new(name);
    endfunction
  endclass

  class seq2 extends seq_base;
    `uvm_object_utils(seq2)
    
    function new(string name = "seq2");
      super.new(name);
    endfunction
  endclass

  class seq3 extends seq_base;
    `uvm_object_utils(seq3)
    
    function new(string name = "seq3");
      super.new(name);
    endfunction
  endclass

  class seq4 extends seq_base;
    `uvm_object_utils(seq4)
    
    function new(string name = "seq4");
      super.new(name);
    endfunction
  endclass

  class seq5 extends seq_base;
    `uvm_object_utils(seq5)
    
    function new(string name = "seq5");
      super.new(name);
    endfunction
  endclass

  class my_seqr extends uvm_sequencer;

    `uvm_component_utils(my_seqr)
    
    function new(string name = "my_seqr", uvm_component parent = null);
      super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
      seq1 s = new("s");
      super.build_phase(phase);
      uvm_config_db#(uvm_object_wrapper)::set(this, "reset_phase",          "default_sequence", seq1::get_type());
      uvm_config_db#(uvm_object_wrapper)::set(this, "post_reset_phase",     "default_sequence", seq1::get_type());
      uvm_config_db#(uvm_object_wrapper)::set(this, "configure_phase",      "default_sequence", seq1::get_type());
      uvm_config_db#(uvm_object_wrapper)::set(this, "post_configure_phase", "default_sequence", seq1::get_type());
      uvm_config_db#(uvm_sequence_base)::set(this,  "main_phase",           "default_sequence", s);
      uvm_config_db#(uvm_sequence_base)::set(this,  "post_main_phase",      "default_sequence", s);
      uvm_config_db#(uvm_sequence_base)::set(this,  "shutdown_phase",       "default_sequence", s);
      uvm_config_db#(uvm_sequence_base)::set(this,  "post_shutdown_phase",  "default_sequence", s);
    endfunction
  endclass

  class my_env extends uvm_env;

    my_seqr sqr;
    
    `uvm_component_utils(my_env)
    
    function new(string name = "my_env", uvm_component parent = null);
      super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
      seq2 s = new("s");

      super.build_phase(phase);

      sqr = new("sqr", this);

      uvm_config_db#(uvm_sequence_base)::set(this,  "*.configure_phase",      "default_sequence", s);
      uvm_config_db#(uvm_sequence_base)::set(this,  "*.post_configure_phase", "default_sequence", s);
      uvm_config_db#(uvm_object_wrapper)::set(this, "*.shutdown_phase",       "default_sequence", seq2::get_type());
      uvm_config_db#(uvm_object_wrapper)::set(this, "*.post_shutdown_phase",  "default_sequence", seq2::get_type());
    endfunction
  endclass

  class base_test extends uvm_test;

    my_env env;
    
    `uvm_component_utils(base_test)
    
    function new(string name = "base_test", uvm_component parent = null);
      super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
      seq3 s = new("s");

      super.build_phase(phase);

      env = new("env", this);

      uvm_config_db#(uvm_object_wrapper)::set(this, "*.post_reset_phase",     "default_sequence", seq3::get_type());
      uvm_config_db#(uvm_object_wrapper)::set(this, "*.post_configure_phase", "default_sequence", seq3::get_type());
      uvm_config_db#(uvm_sequence_base)::set(this,  "*.post_main_phase",      "default_sequence", s);
      uvm_config_db#(uvm_sequence_base)::set(this,  "*.post_shutdown_phase",  "default_sequence", s);
    endfunction
  endclass

  class test extends base_test;

    `uvm_component_utils(test)

    function new(string name = "test", uvm_component parent = null);
      super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
    endfunction


    function void report_phase(uvm_phase phase);

      string exp[$];
      int err;

      exp.push_back("seq1(seq1)");
      exp.push_back("seq3(seq3)");
      exp.push_back("seq2(s)");
      exp.push_back("seq3(seq3)");
      exp.push_back("seq1(s)");
      exp.push_back("seq3(s)");
      exp.push_back("seq2(seq2)");
      exp.push_back("seq3(s)");
      
      $write("Sequences run:\n");
      foreach (seqlist[i]) begin
        $write("  - %s", seqlist[i]);
        if (seqlist[i] != exp[i]) begin
          err++;
          $write(" ERROR: Expected %s\n", exp[i]);
        end
        else $write("\n");
      end

      if (seqlist.size() != 8) begin
        $write("%d sequences were executed instead of 8.\n", seqlist.size());
        err++;
      end
      
       if (err > 0) begin
         $write("** UVM TEST FAILED **\n");
       end
       else begin
         $write("** UVM TEST PASSED **\n");
       end
    endfunction : report_phase
     
  endclass

  initial
    run_test();

endmodule
