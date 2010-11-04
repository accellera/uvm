//----------------------------------------------------------------------
//   Copyright 2007-2009 Cadence Design Systems, Inc.
//   Copyright 2010 Synopsys, Inc.
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
//----------------------------------------------------------------------


`define XBUS_ADDR_WIDTH 16

`include "uvm_macros.svh"

`include "dut.sv"
`include "xbus_if.sv"

module xbus_reg_tb_top;

  import uvm_pkg::*;

  `include "xbus_test.sv"

  xbus_reg_env env;

  xbus_if xi0();
  
  dut_dummy dut(
    xi0.sig_clock,
    xi0.sig_reset,
    xi0
  );

  initial begin
    xi0.sig_clock <= 1'b0;
    xi0.sig_reset <= 1'b1;
    repeat (5) @(posedge xi0.sig_clock);
    xi0.sig_reset = 1'b0;
  end

  initial begin
    static vif_container xbus_vif = new;
    env = new("env", null);
    xbus_vif.vif = xi0;
    set_config_object("*","xbus_vif",xbus_vif,0);
    run_test();
  end
   
  always #5 xi0.sig_clock = ~xi0.sig_clock;

endmodule
