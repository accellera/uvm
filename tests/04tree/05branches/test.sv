

program top;

import uvm_pkg::*;

class my_catcher extends uvm_report_catcher;
   static int seen = 0;
   virtual function action_e catch();
      if (get_id() == "UVM/CTXT/CYC") begin
         set_severity(UVM_INFO);
         seen++;
      end
      return THROW;
   endfunction
endclass

class my_sobj extends uvm_scoped_object;

   function new(string name, uvm_object ctxt = null);
      super.new(name, ctxt);
   endfunction
endclass

class my_tree extends uvm_tree;

   function new(string name, uvm_object ctxt = null);
      super.new(name, ctxt);
   endfunction
endclass

initial
begin
   my_sobj s1;
   my_tree t1, t2, b11, b12, b112, b1, b;

   t1 = new("t1");
   s1 = new("s1", t1);
   t2 = new("t2", s1);
   b11  = new("t11",  t1);
   b    = new("t111", b11);
   b112 = new("t112", b11);
   b12  = new("t12",  t1);
   b    = new("t13",  t1);
   b    = new("t21",  t2);
   b    = new("t22",  t2);
   b    = new("t221", b);

   `uvm_info("TEST", "Checking branch counts...", UVM_NONE)
   
   if (t1.get_num_branches() != 3) begin
      `uvm_error("TEST", $sformatf("t1 has %0d branches instead of 3", t1.get_num_branches()))
   end
   if (t2.get_num_branches() != 2) begin
      `uvm_error("TEST", $sformatf("t2 has %0d branches instead of 2", t2.get_num_branches()))
   end

   `uvm_info("TEST", "Checking branch predicate...", UVM_NONE)
   
   if (!t1.is_branch(b11)) begin
      `uvm_error("TEST", "b11 is not a branch of t1")
   end
   if (!t1.is_branch(b112)) begin
      `uvm_error("TEST", "b112 is not a branch of t1")
   end
   if (t2.is_branch(b112)) begin
      `uvm_error("TEST", "b112 is a branch of t2")
   end
   if (!t2.is_branch(b)) begin
      `uvm_error("TEST", "b221 is not a branch of t2")
   end
   if (t1.is_branch(b)) begin
      `uvm_error("TEST", "b221 is a branch of t1")
   end
   if (!b112.is_context_object(t1)) begin
      `uvm_error("TEST", "t1 is not a context of b112")
   end
   if (!b.is_context_object(t1)) begin
      `uvm_error("TEST", "t1 is a not context of b221")
   end
   if (!b.is_context_object(t2)) begin
      `uvm_error("TEST", "t2 is a not context of b221")
   end
   if (b112.is_context_object(b)) begin
      `uvm_error("TEST", "b112 is a context of b221")
   end


   `uvm_info("TEST", "Checking grafting...", UVM_NONE)

   `ifdef XXX
   b2.set_context(b12);
   b1.set_context(null);
   if (s2.get_full_name() != "t1.t22b.t3.t22a") begin
      `uvm_error("TEST", {"Full name of s2 is \"", s2.get_full_name(), "\" instead of \"t1.t22b.t3.t22a\"."})
   end
   `endif
   
   begin
      uvm_report_server svr;
      svr = _global_reporter.get_report_server();

      if (svr.get_severity_count(UVM_FATAL) +
          svr.get_severity_count(UVM_ERROR) == 0)
         $write("** UVM TEST PASSED **\n");
      else
         $write("!! UVM TEST FAILED !!\n");

      svr.summarize();
   end
end

endprogram
