package tc;

`include "uvm_macros.svh"

  import uvm_pkg::*;

  typedef bit[46:0] ADDR_t;


class uvm_obj_a_t extends uvm_object;

  function new(string name = "");
    super.new(name);
  endfunction

endclass


class uvm_obj_b_t extends uvm_object;

  uvm_obj_a_t uvm_obj_a_t_aa_h [ ADDR_t ];

  `uvm_object_utils_begin(uvm_obj_b_t)
    `uvm_field_aa_object_int(uvm_obj_a_t_aa_h, UVM_DEFAULT)
  `uvm_object_utils_end

  function new(string name = "");
    super.new(name);
  endfunction

endclass


endpackage



module tb_top();
  import uvm_pkg::*;
  import tc::*;

  initial begin
    static uvm_obj_b_t uvm_obj_b_h = new();
    $display("UVM TEST PASSED");

   begin
      uvm_coreservice_t cs;
      uvm_report_server svr;
      cs = uvm_coreservice_t::get();
      svr = cs.get_report_server();

      svr.report_summarize();

      if (svr.get_severity_count(UVM_FATAL) +
          svr.get_severity_count(UVM_ERROR) == 0)
         $write("** UVM TEST PASSED **\n");
      else
         $write("!! UVM TEST FAILED !!\n");
   end
 end
endmodule
