module mod_test();

   import uvm_pkg::*;
`include "uvm_macros.svh"

class child_t extends uvm_object;

   `uvm_object_utils(child_t)

   function new(string name="unnamed-child");
      super.new(name);
   endfunction : new

endclass : child_t

class parent_t extends uvm_object;

   uvm_object child1;
   uvm_object child2;

   `uvm_object_utils(parent_t)
   
   function new(string name="unnamed-parent");
      super.new(name);
   endfunction : new

   function bit do_compare(uvm_object rhs, uvm_comparer comparer);
      parent_t _rhs;
      do_compare = super.do_compare(rhs, comparer);

      $cast(_rhs, rhs);

      do_compare &= comparer.compare_object("child1", child1, _rhs.child1);
      do_compare &= comparer.compare_object("child2", child2, _rhs.child2);
   endfunction : do_compare

endclass : parent_t
   
class test extends uvm_test;
   
   `uvm_component_utils(test)

   function new(string name,
                uvm_component parent);
      super.new(name, parent);
   endfunction : new

   task run_phase(uvm_phase phase);
      bit failed;
      
      parent_t parent1 = new ("parent1");
      parent_t parent2 = new ("parent2");

      parent1.child1 = child_t::type_id::create("child1");
      parent1.child2 = parent1.child1.clone();

      parent2.child1 = parent1.child1.clone();
      parent2.child2 = parent2.child1;

      if (!parent1.compare(parent2)) begin
         `uvm_error("FAIL_ONE", "parent1 != parent2")
         failed = 1;
      end

      if (!parent2.compare(parent1)) begin
         `uvm_error("FAIL_TWO", "parent2 != parent1")
         failed = 1;
      end

      parent1.child2 = parent1.child1;

      if (!parent1.compare(parent2)) begin
         `uvm_error("FAIL_THREE", "parent1 != parent2")
         failed = 1;
      end

      if (!parent2.compare(parent1)) begin
         `uvm_error("FAIL_FOUR", "parent2 != parent1")
         failed = 1;
      end

      parent1.child2 = parent2.child1;
      parent2.child2 = parent1.child1;

      if (!parent1.compare(parent2)) begin
         `uvm_error("FAIL_FIVE", "parent1 != parent2")
         failed = 1;
      end

      if (!parent2.compare(parent1)) begin
         `uvm_error("FAIL_SIX", "parent2 != parent1")
         failed = 1;
      end

      if (!failed) begin
         `uvm_info("PASS", "*** UVM TEST PASSED ***", UVM_NONE)
      end
      else begin
         `uvm_fatal("FAIL", "*** UVM  TEST FAILED ***")
      end
   endtask : run_phase

endclass // test

   initial begin
      run_test();
   end
   
endmodule

   
