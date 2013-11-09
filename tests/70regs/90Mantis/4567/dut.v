// -------------------------------------------------------------
//    Copyright 2013 Synopsys, Inc.
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
//    permissions and limitations under t,he License.
// -------------------------------------------------------------
// 
module dut(input  [7:0] wdata, 
           output reg [7:0] rdata, 
           input  [31:0] addr, 
           input  direction, 
           input  enable,
           input  clk,
           input  rst_n);

reg [7:0] ctrl_reg;
reg [7:0] data_reg;
reg [7:0] status_reg;

always @(posedge clk or negedge rst_n)
begin
  if (!rst_n) begin
    ctrl_reg <= 8'h00;
    data_reg <= 8'h00;
    status_reg <= 8'h00;
  end
  else begin
     status_reg[0] <= 1;
     status_reg[4] <= 1;
    if (enable && direction) begin //write
      case (addr)
        32'h0 : ctrl_reg <= wdata; 
        32'h01 : data_reg <= wdata;
        default: data_reg <= wdata;
      endcase
    end
    else if (enable && ~direction) begin //read
      case (addr)
        32'h00 : rdata <= ctrl_reg;
        32'h01 : rdata <= data_reg;
        32'h02 : rdata <= status_reg;
        default: rdata <= 8'h00;
      endcase
    end
  end
end   

endmodule
