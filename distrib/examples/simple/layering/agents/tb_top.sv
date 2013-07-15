//----------------------------------------------------------------------
//   Copyright 2013 Synopsys, Inc.
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

import uvm_pkg::*;

`include "lower_pkg.sv"
`include "lower_if.sv"
import lower_pkg::*;

`include "upperA_pkg.sv"
`include "upperA_if.sv"
import upperA_pkg::*;

`include "upperB_pkg.sv"
`include "upperB_if.sv"
import upperB_pkg::*;

`include "lower_passthru_seq.sv"
`include "layerA_drv.sv"
`include "layerB_drv.sv"
`include "layerA_mon.sv"
`include "layerB_mon.sv"
`include "tb_env.sv"
`include "base_test.sv"
`include "tb_test.sv"

module test;


lower_if lif();

initial
begin
  uvm_config_db#(virtual lower_if)::set(null, "*.env.low", "vif", lif);
  run_test();
end
endmodule
