// 
// -------------------------------------------------------------
//    Copyright 2004-2008 Synopsys, Inc.
//    Copyright 2010 Mentor Graphics Corp.
//    All Rights Reserved Worldwide
// 
//    Licensed under the Apache License, Version 2.0 (the
//    "License"); you may not use this file except in
//    compliance with the License.  You may obtain a copy of
//    the License at
// 
//        http://www.apache.org/licenses/LICENSE-2.0
// 
//    Unless required by applicable law or agreed to in
//    writing, software distributed under the License is
//    distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
//    CONDITIONS OF ANY KIND, either express or implied.  See
//    the License for the specific language governing
//    permissions and limitations under the License.
// -------------------------------------------------------------
// 


program test;

import uvm_pkg::*;
import apb_pkg::*;

`include "reg_model.sv"
`include "tb_env.sv"

`include "user_test.sv"
`include "hw_reset.sv"

initial
begin
   tb_env env = new("env");
   apb_config apb_cfg = new;

   apb_cfg.vif = $root.tb_top.apb0;
   set_config_object("env.apb.*","config",apb_cfg,0);

   run_test();
end

endprogram

