

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

class my_obj extends uvm_object;

   function new(string name);
      super.new(name);
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

   uvm_object obj;
   my_obj o1;
   my_sobj s1;
   uvm_scoped_object s2;
   my_tree t1, t2, t3;

   o1 = new("o1");
   s1 = new("s1", o1);
   t1 = new("t1", s1);
   t2 = new("t2a", t1);
   obj = t2;
   s2 = t2;
   t2 = new("t2b", t1);
   t3 = new("t3", t2);

   `uvm_info("TEST", "Checking hierarchical names...", UVM_NONE)
   
   if (t3.get_full_name() != "o1.s1.t1.t2b.t3") begin
      `uvm_error("TEST", {"Full name of t3 is \"", t3.get_full_name(), "\" instead of \"o1.s1.t1.t2b.t3\"."})
   end

   `uvm_info("TEST", "Checking renaming...", UVM_NONE)

   o1.set_name("o11");
   s1.set_name("s11");
   obj.set_name("t22a");
   t2.set_name("t22b");
   if (t3.get_full_name() != "o11.s11.t1.t22b.t3") begin
      `uvm_error("TEST", {"Full name of t3 is \"", t3.get_full_name(), "\" instead of \"o11.s11.t1.t22b.t3\"."})
   end
   if (obj.get_full_name() != "o11.s11.t1.t22a") begin
      `uvm_error("TEST", {"Full name of t2a is \"", obj.get_full_name(), "\" instead of \"o11.s11.t1.t22a\"."})
   end

   `uvm_info("TEST", "Checking set_context_object()...", UVM_NONE)

   s2.set_context_object(t3);
   t1.set_context_object(null);
   if (s2.get_full_name() != "t1.t22b.t3.t22a") begin
      `uvm_error("TEST", {"Full name of s2 is \"", s2.get_full_name(), "\" instead of \"t1.t22b.t3.t22a\"."})
   end

   `uvm_info("TEST", "Checking context cycle detection()...", UVM_NONE)

   begin
      my_catcher c = new();
      uvm_report_cb::add(null, c);
   end
   
   t1.set_context_object(s1);
   s1.set_context_object(s2);
   if (my_catcher::seen != 1) begin
      `uvm_error("TEST", "Context cycle #1 was not detected")
   end
   my_catcher::seen = 0;

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
