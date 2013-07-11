module test_mod;

   import uvm_pkg::*;
`include "uvm_macros.svh"

// Tests the key points in the schedule:
// First Phase (0 Pred, 1 Succ)
// Fork Phase (1 Pred, 2 Succ)
// Join Phase (2 Pred, 1 Succ)
// Last Phase (1 Pred, 0 Succ)
   
class test extends uvm_component;

   `uvm_component_utils(test);

   bit fail;
   uvm_phase phase_array[];
   
   function new(string name, uvm_component parent);
      super.new(name, parent);
   endfunction : new

   virtual function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      phase.get_adjacent_predecessor_nodes(phase_array);
      if (phase_array.size() != 0) begin
         fail = 1;
         `uvm_fatal("FAIL",
                    $sformatf("Expected '0' predecessors, got '%0d'",
                              phase_array.size()))
      end

      phase.get_adjacent_successor_nodes(phase_array);
      if (phase_array.size() != 1) begin
         fail = 1;
         `uvm_fatal("FAIL",
                    $sformatf("Expected '1' successor, got '%0d'",
                              phase_array.size()))
      end
      else begin
         if (!phase_array[0].is(uvm_connect_phase::get())) begin
            `uvm_fatal("FAIL",
                       $sformatf("Expected 'connect_phase' as successor, got '%s'", phase_array[0].get_name()))
         end
      end
   endfunction // build_phase

   virtual function void start_of_simulation_phase(uvm_phase phase);
      super.start_of_simulation_phase(phase);
      phase.get_adjacent_predecessor_nodes(phase_array);
      if (phase_array.size() != 1) begin
         fail = 1;
         `uvm_fatal("FAIL",
                    $sformatf("Expected '1' predecessors, got '%0d'",
                              phase_array.size()))
      end
      else begin
         if (!phase_array[0].is(uvm_end_of_elaboration_phase::get())) begin
            `uvm_fatal("FAIL",
                       $sformatf("Expected 'end_of_elaboration_phase' as predecessor, got '%s'", phase_array[0].get_name()))
         end
      end // else: !if(phase_array.size() != 1)

      phase.get_adjacent_successor_nodes(phase_array);
      if (phase_array.size() != 2) begin
         fail = 1;
         `uvm_fatal("FAIL",
                    $sformatf("Expected '2' successors, got '%0d'",
                              phase_array.size()))
      end
      else begin
         if (!phase_array[0].is(uvm_run_phase::get()) && !phase_array[1].is(uvm_run_phase::get())) begin
            `uvm_fatal("FAIL",
                       $sformatf("Expected 'run_phase' as successor, but didn't get it"))
         end
         if (!phase_array[0].is(uvm_pre_reset_phase::get()) && !phase_array[1].is(uvm_pre_reset_phase::get())) begin
            `uvm_fatal("FAIL",
                       $sformatf("Expected 'pre_reset_phase' as successor, but didn't get it"))
         end
      end
   endfunction // 
      
   virtual function void extract_phase(uvm_phase phase);
      super.extract_phase(phase);
      phase.get_adjacent_predecessor_nodes(phase_array);
      if (phase_array.size() != 2) begin
         fail = 1;
         `uvm_fatal("FAIL",
                    $sformatf("Expected '2' predecessors, got '%0d'",
                              phase_array.size()))
      end
      else begin
         if (!phase_array[0].is(uvm_run_phase::get()) && !phase_array[1].is(uvm_run_phase::get())) begin
            `uvm_fatal("FAIL",
                       $sformatf("Expected 'run_phase' as predecessor, but didn't get it"))
         end
         if (!phase_array[0].is(uvm_post_shutdown_phase::get()) && !phase_array[1].is(uvm_post_shutdown_phase::get())) begin
            `uvm_fatal("FAIL",
                       $sformatf("Expected 'post_shutdown_phase' as predecessor, but didn't get it"))
         end
      end // else: !if(phase_array.size() != 1)

      phase.get_adjacent_successor_nodes(phase_array);
      if (phase_array.size() != 1) begin
         fail = 1;
         `uvm_fatal("FAIL",
                    $sformatf("Expected '1' successor, got '%0d'",
                              phase_array.size()))
      end
      else begin
         if (!phase_array[0].is(uvm_check_phase::get())) begin
            `uvm_fatal("FAIL",
                       $sformatf("Expected 'check_phase' as successor, but didn't get it"))
         end
      end
   endfunction // 
      
   virtual function void final_phase(uvm_phase phase);
      super.final_phase(phase);
      phase.get_adjacent_predecessor_nodes(phase_array);
      if (phase_array.size() != 1) begin
         fail = 1;
         `uvm_fatal("FAIL",
                    $sformatf("Expected '1' predecessor, got '%0d'",
                              phase_array.size()))
      end
      else begin
         if (!phase_array[0].is(uvm_report_phase::get()) ) begin
            `uvm_fatal("FAIL",
                       $sformatf("Expected 'report_phase' as predecessor, but didn't get it"))
         end
      end // else: !if(phase_array.size() != 1)

      phase.get_adjacent_successor_nodes(phase_array);
      if (phase_array.size() != 0) begin
         fail = 1;
         `uvm_fatal("FAIL",
                    $sformatf("Expected '0' successors, got '%0d'",
                              phase_array.size()))
      end

      if (fail == 0)
        $display("*** UVM TEST PASSED ***");
      else
        $display("*** UVM TEST FAILED ***");
   endfunction // 

endclass // test

   initial
     run_test();

endmodule // test_mod

   
