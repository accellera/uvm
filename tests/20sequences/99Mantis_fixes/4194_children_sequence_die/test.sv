// Test for mantis 4194, children sequences become
// zombies if their parent is killed

module test;

   import uvm_pkg::*;
`include "uvm_macros.svh"

class simple_item extends uvm_sequence_item;
   `uvm_object_utils(simple_item)

     function new(string name="unnamed-simple_item");
        super.new(name);
     endfunction : new
endclass : simple_item

class child_sequence extends uvm_sequence#(simple_item);
   `uvm_object_utils(child_sequence)

   function new(string name="unnamed-child_sequence");
      super.new(name);
   endfunction : new

   task body();
      `uvm_info("CHILD_BODY", "before do", UVM_LOW)
      `uvm_do(req)
      `uvm_info("CHILD_BODY", "after do", UVM_LOW)
   endtask : body

   function void do_kill();
      `uvm_info("CHILD_KILLED",
                $sformatf("'%s' was killed", get_full_name()),
                UVM_LOW)
   endfunction : do_kill

endclass : child_sequence
   
class parent_sequence extends uvm_sequence;
   `uvm_object_utils(parent_sequence)

   uvm_sequencer#(simple_item) real_sequencer;
   child_sequence c;

   function new(string name="unnamed-parent_sequence");
      super.new(name);
   endfunction : new

   task body();
      c = child_sequence::type_id::create("c");

      c.start(real_sequencer, this);
   endtask : body
     
   function void do_kill();
      `uvm_info("PARENT_KILLED",
                $sformatf("'%s' was killed", get_full_name()),
                UVM_LOW)
   endfunction : do_kill

endclass : parent_sequence

class simple_driver extends uvm_driver#(simple_item);
   `uvm_component_utils(simple_driver)

   function new(string name="unnamed-simple_driver", uvm_component parent=null);
      super.new(name, parent);
   endfunction : new

   task run_phase(uvm_phase phase);
      simple_item item;
      forever begin
         #10;
         `uvm_info("DRIVER_GET", "fetching item", UVM_LOW)
         seq_item_port.get(item);
         `uvm_info("DRIVER_GOT", "received item", UVM_LOW)
      end
   endtask : run_phase

endclass : simple_driver

class test extends uvm_test;
   `uvm_component_utils(test)

   parent_sequence p;
   simple_driver driver;
   uvm_sequencer#(simple_item) sequencer;
   uvm_sequencer virtual_sequencer;

   function new(string name="unnamed-test", uvm_component parent=null);
      super.new(name, parent);
   endfunction : new

   function void build_phase(uvm_phase phase);
      super.build_phase(phase);

      driver = new("driver");
      sequencer = new("sequencer");
      virtual_sequencer = new("virtual_sequencer");
      
   endfunction : build_phase

   function void connect_phase(uvm_phase phase);
      super.connect_phase(phase);
      driver.seq_item_port.connect(sequencer.seq_item_export);
   endfunction : connect_phase
   
   task run_phase(uvm_phase phase);
      phase.raise_objection(this);

      p = parent_sequence::type_id::create("p1");
      p.real_sequencer = sequencer;
      fork : first_fork
         p.start(virtual_sequencer);
      join_none : first_fork
      #1;
      p.kill();

      begin
         uvm_sequence_state_enum m_state = p.c.get_sequence_state();
         `uvm_info("TEST", $sformatf("after first kill, p1.c.state = '%s'", m_state.name()), UVM_LOW)
      end

      p = parent_sequence::type_id::create("p2");
      p.real_sequencer = sequencer;
      fork : second_fork
         p.start(virtual_sequencer);
      join_none : second_fork

      #15;
      phase.drop_objection(this);
   endtask : run_phase

   function void report_phase(uvm_phase phase);
      if (p.get_sequence_state() != UVM_FINISHED) begin
         $display("*** UVM TEST FAILED ***");
      end
      else begin
         $display("*** UVM TEST PASSED ***");
      end
   endfunction : report_phase

endclass : test
   
   initial run_test();

endmodule : test

     
