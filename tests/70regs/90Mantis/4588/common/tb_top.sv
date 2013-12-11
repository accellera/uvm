// 
// -------------------------------------------------------------
//    Copyright 2004-2011 Synopsys, Inc.
//    Copyright 2010 Mentor Graphics Corporation
//    Copyright 2010 Cadence Design Systems, Inc.
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

`include "apb.sv"
`include "dut.sv"
import uvm_pkg::*;

module tb_top;
   bit clk = 0;
   bit rst = 0;

   apb_if apb0(clk);
   slave dut(apb0);
   //slave dut(.paddr(apb0.paddr),.psel(apb0.psel),.penable(apb0.penable),.pwrite(apb0.pwrite),.prdata(apb0.prdata),.pwdata(apb0.pwdata),.clk(clk),.rst(rst));

   always #10 clk = ~clk;

   //initial
    //  uvm_resource_db#(virtual ral_slave_intf)::set("*", "uvm_reg_bkdr_if", intf);

endmodule: tb_top
