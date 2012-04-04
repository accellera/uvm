

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

initial
begin

   uvm_object obj;
   my_obj o1;
   my_sobj s1, s2, s3;

   o1 = new("o1");
   s1 = new("s1");
   s2 = new("s2", s1);
   s3 = new("s3", o1);

   `uvm_info("TEST", "Checking hierarchical names...", UVM_NONE)
   
   if (s1.get_full_name() != "s1") begin
      `uvm_error("TEST", {"Full name of s1 is \"", s1.get_full_name(), "\" instead of \"s1\"."})
   end

   if (s2.get_full_name() != "s1.s2") begin
      `uvm_error("TEST", {"Full name of s2 is \"", s2.get_full_name(), "\" instead of \"s1.s2\"."})
   end
   obj = s3;
   if (obj.get_full_name() != "o1.s3") begin
      `uvm_error("TEST", {"Full name of s3 is \"", obj.get_full_name(), "\" instead of \"o1.s3\"."})
   end
   
   `uvm_info("TEST", "Checking renaming...", UVM_NONE)

   o1.set_name("o11");
   s2.set_name("s22");
   obj.set_name("s33");
   if (s2.get_full_name() != "s1.s22") begin
      `uvm_error("TEST", {"Full name of s2 is \"", s2.get_full_name(), "\" instead of \"s1.s22\"."})
   end
   if (obj.get_full_name() != "o11.s33") begin
      `uvm_error("TEST", {"Full name of s3 is \"", obj.get_full_name(), "\" instead of \"o11.s33\"."})
   end

   `uvm_info("TEST", "Checking set_context()...", UVM_NONE)

   s2.set_context(o1);
   s3.set_context(null);
   if (s2.get_full_name() != "o11.s22") begin
      `uvm_error("TEST", {"Full name of s2 is \"", s2.get_full_name(), "\" instead of \"o11.s22\"."})
   end
   if (obj.get_full_name() != "s33") begin
      `uvm_error("TEST", {"Full name of s3 is \"", obj.get_full_name(), "\" instead of \"s33\"."})
   end

   `uvm_info("TEST", "Checking context cycle detection()...", UVM_NONE)

   begin
      my_catcher c = new();
      uvm_report_cb::add(null, c);
   end
   
   s2.set_context(s1);
   s1.set_context(s3);
   if (s2.get_full_name() != "s33.s1.s22") begin
      `uvm_error("TEST", {"Full name of s2 is \"", s2.get_full_name(), "\" instead of \"s33.s1.s22\"."})
   end

   s3.set_context(s3);
   if (my_catcher::seen != 1) begin
      `uvm_error("TEST", "Context cycle #1 was not detected")
   end
   my_catcher::seen = 0;

   s3.set_context(s1);
   if (s2.get_full_name() != "s33.s1.s22") begin
      `uvm_error("TEST", {"Full name of s2 is \"", s2.get_full_name(), "\" instead of \"s33.s1.s22\"."})
   end
   if (my_catcher::seen != 1) begin
      `uvm_error("TEST", "Context cycle #2 was not detected")
   end

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
