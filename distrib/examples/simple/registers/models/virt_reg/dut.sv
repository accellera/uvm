// 
// -------------------------------------------------------------
//    Copyright 2004-2011 Synopsys, Inc.
//    Copyright 2010 Mentor Graphics Corporation
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


module dut #(int BASE_ADDR='h0) (apb_if apb, input bit rst);

reg [7:0] RAM[1024];


reg  [31:0] pr_data;
wire [31:0] pr_addr;
wire in_range;

assign pr_addr = apb.paddr - BASE_ADDR;
assign in_range = 0 <= pr_addr && pr_addr < 1024;

assign apb.prdata = (apb.psel && apb.penable && !apb.pwrite && in_range) ? pr_data : 'z;

always @ (posedge apb.pclk)
begin
   if (rst) begin
      pr_data <= 0;
   end
   else begin
      // Wait for a SETUP+READ or ENABLE+WRITE cycle
      if (apb.psel == 1'b1 && apb.penable == apb.pwrite && in_range) begin
         pr_data <= RAM[pr_addr];
         if (apb.pwrite) begin
            RAM[pr_addr] <= apb.pwdata;
         end
      end
   end
end

endmodule


