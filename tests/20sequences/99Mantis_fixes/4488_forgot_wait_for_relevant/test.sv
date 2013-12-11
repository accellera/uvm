//
//------------------------------------------------------------------------------
//   Copyright 2013 Cisco Systems, Inc.
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
//------------------------------------------------------------------------------



module test();

  import uvm_pkg::*;
  `include "uvm_macros.svh"


  class my_item extends uvm_sequence_item;
    `uvm_object_utils(my_item)
    function new(string name = "my_item_");
      super.new(name);
    endfunction
  endclass


  typedef class my_sequencer;
  typedef class my_driver;


  class my_sequence extends uvm_sequence #(my_item);
    `uvm_object_utils(my_sequence)
    `uvm_declare_p_sequencer(my_sequencer)
    function new(string name = "my_sequence");
      super.new(name);
    endfunction
    task body();
      $display("%0t %s body() starting", $time, get_type_name());
      `uvm_do(req)
      $display("%0t %s body() ending", $time, get_type_name());
      $display("Did not see expected UVM_FATAL for loop!!");
      $display("** UVM TEST FAILED **");
    endtask
    int loop_counter = 0;
    function bit is_relevant();
      return p_sequencer.rel_var;
    endfunction
    task wait_for_relevant();
      //@(p_sequencer.rel_var); //oops, forgot to wait for the relevant to change
      //following just for debug info in test
      $display("%0t %s wait_for_relevant() call iteration %0d", $time, get_type_name(), loop_counter);
      loop_counter++ ;
    endtask
  endclass



  class my_sequencer extends uvm_sequencer #(my_item);
    bit rel_var = 0;// starting at relevant = 0
    `uvm_component_utils(my_sequencer)
    function new(string name, uvm_component parent);
      super.new(name, parent);
    endfunction
  endclass

  


  class my_driver extends uvm_driver #(my_item);
    `uvm_component_utils(my_driver)
    function new(string name, uvm_component parent);
      super.new(name, parent);
    endfunction
    task run_phase(uvm_phase phase);
      phase.raise_objection(this);
      #1;
      $display("%t calling get_next_item...", $time);
      seq_item_port.get_next_item(req);
      $display("%t back from get_next_item...", $time);
      if (req != null) begin
        req.print();
        $display("%t get_next_item completed", $time);
        seq_item_port.item_done();
      end
      else begin
        $display("%t get_next_item returned null", $time);
      end
      phase.drop_objection(this);
    endtask
  endclass


  class fatal_error_catcher extends uvm_report_catcher;
     virtual function action_e catch();
     if(get_severity() == UVM_FATAL && get_id()=="SEQRELEVANTLOOP") begin
        set_action(UVM_EXIT);
        uvm_report_info("FATAL CATCHER", "Caught FATAL for SEQRELEVANTLOOP", UVM_MEDIUM , `uvm_file, `uvm_line );
        $display("** UVM TEST PASSED **");
     end
        return THROW;
     endfunction
  endclass
  

  
  class test extends uvm_test;

    my_sequencer ms0;
    my_driver md0;

    `uvm_component_utils_begin(test)
    `uvm_component_utils_end

    function new(string name, uvm_component parent);
      super.new(name, parent);
    endfunction

    function void build();
      super.build();
      ms0 = my_sequencer::type_id::create("ms0", this);
      md0 = my_driver::type_id::create("md0", this);
      begin
         fatal_error_catcher fec ;
         fec = new ;
         uvm_report_cb::add(null,fec);
      end
    endfunction

    function void connect();
      md0.seq_item_port.connect(ms0.seq_item_export);
    endfunction

    task run_phase(uvm_phase phase);
      my_sequence the_seq;
      the_seq = my_sequence::type_id::create("the_seq", this);
      phase.raise_objection(this);
      fork
        the_seq.start(ms0);
      join_none
      #1;
      for (int i = 0; i < 6; i++) begin
        #0;
      end
      #300;
      ms0.rel_var = 1;
      phase.drop_objection(this);
    endtask

  endclass

  initial run_test();

endmodule

