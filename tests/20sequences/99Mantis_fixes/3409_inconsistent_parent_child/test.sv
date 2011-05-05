module test();

  import uvm_pkg::*;
  `include "uvm_macros.svh"

  class error_catcher extends uvm_report_catcher;
     int unsigned count=0;
     virtual function action_e catch();
        if("SEQFINERR" != get_id()) return THROW;
        if(get_severity() != UVM_ERROR) return THROW;
        uvm_report_info("ERROR CATCHER", $psprintf("Error Catched caught: '%s'", get_message()), UVM_MEDIUM , `uvm_file, `uvm_line );
        count++; 
        return CAUGHT;
     endfunction
  endclass

  class my_item extends uvm_sequence_item;
    rand bit[7:0] addr;
    `uvm_object_utils_begin(my_item)
      `uvm_field_int(addr, UVM_ALL_ON)
    `uvm_object_utils_end
    function new(string name = "unnamed-my_item");
      super.new(name);
    endfunction
  endclass

  typedef class my_sequencer;

  class other_sequence extends uvm_sequence #(my_item);
    `uvm_object_utils(other_sequence)
    function new(string name = "other_sequence");
      super.new(name);
    endfunction
    task body();
      `uvm_info(get_type_name(), $psprintf("body starting"), UVM_HIGH)
`ifndef WORSE
      #50;
`else
      #300;
`endif
      `uvm_info(get_type_name(), $psprintf("placing request"), UVM_HIGH)
      `uvm_do(req)
      `uvm_info(get_type_name(), $psprintf("item done, sequence is finishing"), UVM_HIGH)
    endtask
  endclass

  class my_sequence extends uvm_sequence #(my_item);
    other_sequence os;
    `uvm_object_utils(my_sequence)
    `uvm_declare_p_sequencer(my_sequencer)
    function new(string name = "my_sequence");
      super.new(name);
    endfunction
    task body();
      `uvm_info(get_type_name(), $psprintf("body starting"), UVM_HIGH)
      #100;
      fork begin
        os = other_sequence::type_id::create("os");
        os.start(p_sequencer, this);
      end
      join_none
      `uvm_info(get_type_name(), $psprintf("placing request"), UVM_HIGH)
      `uvm_do(req)
      `uvm_info(get_type_name(), $psprintf("item done, sequence is finishing"), UVM_HIGH)
    endtask
  endclass

  class my_sequencer extends uvm_sequencer #(my_item);
    `uvm_component_utils_begin(my_sequencer)
    `uvm_component_utils_end
    function new(string name, uvm_component parent);
      super.new(name, parent);
    endfunction
  endclass
  
  class my_driver extends uvm_driver #(my_item);
    `uvm_component_utils(my_driver)
    function new(string name, uvm_component parent);
      super.new(name, parent);
    endfunction
    task run();
      forever begin
        seq_item_port.get_next_item(req);
        #100;
        `uvm_info(get_type_name(), $psprintf("Request is:\n%s", req.sprint()), UVM_HIGH)
        seq_item_port.item_done();
      end
    endtask
  endclass

  class my_agent extends uvm_agent;
    my_sequencer ms;
    my_driver md;
    `uvm_component_utils(my_agent)
    function new(string name, uvm_component parent);
      super.new(name, parent);
    endfunction
    function void build();
      super.build();
      ms = my_sequencer::type_id::create("ms", this);
      md = my_driver::type_id::create("md", this);
    endfunction
    function void connect();
      md.seq_item_port.connect(ms.seq_item_export);
    endfunction
  endclass
  
  class test extends uvm_test;
    my_agent ma0;
    error_catcher ec;

    `uvm_component_utils_begin(test)
    `uvm_component_utils_end
    function new(string name, uvm_component parent);
      super.new(name, parent);
    endfunction
    function void build();
      super.build();
      ec = new;
      uvm_report_cb::add(null,ec);
      ma0 = my_agent::type_id::create("ma0", this);
      uvm_default_table_printer.knobs.value_width = 40;
    endfunction
    function void end_of_elaboration();
      `uvm_info(get_type_name(), $psprintf("The topology:\n%s", this.sprint()), UVM_HIGH)
    endfunction
    task run();
      my_sequence msq;
      uvm_test_done.raise_objection(this);
      msq = my_sequence::type_id::create("msq", this);
      msq.start(ma0.ms);
      #1000;
      uvm_test_done.drop_objection(this);
    endtask // run

    function void report_phase(uvm_phase phase);
       if (ec.count != 1)
         begin
            $display("** UVM TEST FAILED **");
         end
       else
         begin
            $display("** UVM TEST PASSED **");
         end
    endfunction : report_phase
     
  endclass

  initial
    run_test();

endmodule
