//This test shows how individual phases of UVM is synchronized with vmm_env methods

`define VMM_ON_TOP 

`include "uvm_vmm_pkg.sv"
`include "vmm_other.sv"
`include "uvm_other.sv"


program example_06_env_step_by_step;
   vmm_log log    = new("example_06_env_step_by_step","program");
   uvm_comp_ext c = new("comp");
   vmm_env_ext  e = new("env");

  initial begin
    e.gen_cfg();
    #100  `vmm_note(log, $psprintf("%t *** between GEN_CFG and BUILD",$time));
    e.build();
    #100  `vmm_note(log, $psprintf("%t *** between BUILD and RESET_DUT",$time));
    e.reset_dut();
    #100 `vmm_note(log, $psprintf("%t *** between RESET_DUT and CFG_DUT",$time));
    e.cfg_dut();
    #100  `vmm_note(log, $psprintf("%t *** between CFG_DUT and CLEANUP",$time));
     e.wait_for_end();
     e.cleanup();
    #100  `vmm_note(log, $psprintf("%t *** between CLEANUP and run",$time));
    e.run();
    #100  `vmm_note(log, $psprintf("%t *** after full run",$time));
  end

endprogram