import uvm_pkg::*;
`include "uvm_macros.svh"

class test extends uvm_component;

  `uvm_component_utils(test)

  int strtab[string];

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build();
    strtab["aa"] = 0;
    strtab["fred"] = 0;
    strtab["aaa"] = 0;
    strtab["bert"] = 0;
    strtab["boy"] = 0;
    strtab["ab"] = 0;
    strtab["abc"] = 0;
    strtab["abcd"] = 0;
    strtab["ernie"] = 0;
    strtab["barney"] = 0;
    strtab["bernie"] = 0;
  endfunction

  task run();
    $display("-- string table --");
    foreach(strtab[s]) begin
      $display("  %s", s);
    end
    $display("-- end table --");

    $display("\nspell checking...");

    void'(uvm_spell_chkr#(int)::check(strtab, "aa"));
    void'(uvm_spell_chkr#(int)::check(strtab, "a"));
    void'(uvm_spell_chkr#(int)::check(strtab, "ferd"));
    void'(uvm_spell_chkr#(int)::check(strtab, "acd"));
    void'(uvm_spell_chkr#(int)::check(strtab, "by"));
    void'(uvm_spell_chkr#(int)::check(strtab, "boyt"));
    void'(uvm_spell_chkr#(int)::check(strtab, "abce"));
    void'(uvm_spell_chkr#(int)::check(strtab, "qrstwy"));
    void'(uvm_spell_chkr#(int)::check(strtab, "barn"));
    void'(uvm_spell_chkr#(int)::check(strtab, "ern"));
    void'(uvm_spell_chkr#(int)::check(strtab, "erni"));

    global_stop_request();
  endtask

  function void report();
    uvm_report_server rs = get_report_server();
    if(rs.get_severity_count(UVM_ERROR) > 0)
      $display("** UVM TEST FAIL **");
    else
      $display("** UVM TEST PASSED **");
  endfunction

endclass

module top;

  initial run_test();

endmodule
