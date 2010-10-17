//----------------------------------------------------------------------
//   Copyright 2007-2009 Cadence Design Systems, Inc.
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

module dut_regs(
  input wire clock,
  input wire reset,
  input wire [15:0] addr,
  input wire read,
  input wire [7:0] write_data,
  output reg [7:0] read_data);

  parameter int NUM_OF_BLOCK_REGS=4;
  bit[3:0]  st;
  // RW Register : config_reg
  reg [1:0] dest;
  reg [3:2] kind;
  reg [7:4] rsvd;

  // User access policy register
  // This register updates whenever it is written (it is a counter).
  reg [7:0] user_reg;

  // -- Shared Register --
  // Shared register (rd)
  reg [7:0] shared_rd_reg;
  // Shared register (wr)
  reg [7:0] shared_wr_reg;

  // -- Indirect Register --
  // Address register for indirect-addressing register
  reg [2:0] addr_reg;
  // Registers holding values of indirect register
  reg [7:0] id_reg_values [0:7];
  // A few RW registers
  reg [7:0] rw_regs[0:NUM_OF_BLOCK_REGS-1];
  // A few RO registers
  reg [7:0] ro_regs[0:NUM_OF_BLOCK_REGS-1];
  // A few WO registers
  reg [7:0] wo_regs[0:NUM_OF_BLOCK_REGS-1];

  // Memory
  reg [7:0] mem [0:255];
  reg [7:0] mem_offset;
  // Local variable that saves index to register block
  reg[1:0] regs_index;

  always @(posedge clock or posedge reset) begin
     if(reset) begin
       addr_reg <= 3'b1;
       dest <=2'h0;
       kind <=2'h0;
       rsvd <=4'hf;
       user_reg <= 8'h00;
       shared_rd_reg <= 8'ha5;
       shared_wr_reg <= 8'h00;
       for(int i=0; i<8; i++)
         id_reg_values[i]<='h0;
       for(int i=0; i<NUM_OF_BLOCK_REGS; i++)
       begin
         rw_regs[i]<='h5a;
         ro_regs[i]<='ha5;
         wo_regs[i]<='h55;
       end
       st <= 0;
       read_data <= 8'h00;
       regs_index <= 0;
     end
     else begin
       case(st)
         0: begin //Begin out of Reset
           if((addr > 'h1007 && addr <'h100d) || (addr>='h1010 && addr<'h101c) ||
             (addr>='h1100 && addr<'h1200))
           begin
             case(addr[11:0])
               8'h8:
                 if(read)
                   read_data <= addr_reg;
                 else
                   st <= 1;
               8'h9:
                 if(read)
                   read_data <= {rsvd, kind, dest};
                 else
                   st <= 2;
               8'ha:
                 if(read)
                   read_data <= user_reg;
                 else
                   st <= 3;
               8'hb:
                 if(read)
                   read_data <= shared_rd_reg;
                 else
                   st <= 4;
               8'hc:
               begin
                 if(read)
                   read_data <= id_reg_values[addr_reg];
                 else
                   st <= 5;
               end
               // RW reg block
               8'h10,8'h11,8'h12,8'h13 :
               begin
                 regs_index<=addr[1:0]; 
                 if(read)
                 begin
                   read_data <= rw_regs[addr[1:0]];
                 end
                 else
                   st <= 6;
               end
               // RO reg block
               8'h14,8'h15,8'h16,8'h17 :
               begin
                 regs_index<=addr[1:0]; 
                 if(read)
                   read_data <= ro_regs[addr[1:0]];
                 else
                   st <= 7;
               end
               // WO reg block
               8'h18,8'h19,8'h1a,8'h1b :
               begin
                 regs_index<=addr[1:0]; 
                 if(read)
                   read_data <= 0;
                 else
                   st <= 8;
               end
               default :
               begin
                 mem_offset <= addr[7:0];
                 if(read)
                   read_data <= mem[addr[7:0]];
                 else
                   st <= 9;
               end
             endcase
           end
         end
         1: begin
           addr_reg <= write_data;
           st <= 0;
         end
         2: begin
           {rsvd, kind, dest} <= write_data;
           st <= 0;
         end
         3: begin
           user_reg <= user_reg+1;
           st <= 0;
         end
         4: begin
           shared_wr_reg <= write_data;
           st <= 0;
         end
         // Indirect register
         5: begin
           id_reg_values[addr_reg] <= write_data;
           st <= 0;
         end
         // RW register block
         6: begin
           rw_regs[regs_index] <= write_data;
           st <= 0;
         end
         7: begin
           st <= 0;
         end
         // WO register block. Dont do anything
         8: begin
           wo_regs[regs_index] <= write_data;
           st <= 0;
         end
         9: begin
           mem[mem_offset] <= write_data;
           st <= 0;
         end
       endcase
     end
   end
endmodule

module dut_dummy( 
  input wire xbus_clock,
  input wire xbus_reset,
  xbus_if xio
  );
  bit[2:0]   st;

  reg read_write_n;
  wire [7:0] read_data;

  assign xio.sig_wait = 0;
  assign xio.sig_error = 0;
  assign xio.sig_data = read_write_n ? read_data : 8'hZZ;

  dut_regs reg_file(
    .clock(xbus_clock),
    .reset(xbus_reset),
    .addr(xio.sig_addr),
    .read(xio.sig_read),
    .write_data(xio.sig_data),
    .read_data(read_data));

  // Basic arbiter, supports two masters, 0 has priority over 1

   always @(posedge xbus_clock or posedge xbus_reset) begin
     if(xbus_reset) begin
       xio.sig_start <= 1'b0;
       st<=3'h0;
     end
       else
         case(st)
         0: begin //Begin out of Reset
             xio.sig_start <= 1'b1;
             st<=3'h3;
         end
         3: begin //Start state
             xio.sig_start <= 1'b0;
             if((xio.sig_grant[0]==0) && (xio.sig_grant[1]==0)) begin
                 st<=3'h4;
             end
             else
                 st<=3'h1;
         end
         4: begin // No-op state
             xio.sig_start <= 1'b1;
             st<=3'h3;
         end
         1: begin // Addr state
             st<=3'h2;
             xio.sig_start <= 1'b0;
         end
         2: begin // Data state
             if((xio.sig_error==1) || ((xio.sig_bip==0) && (xio.sig_wait==0))) begin
                 st<=3'h3;
                 xio.sig_start <= 1'b1;
             end
             else begin
                 st<=3'h2;
                 xio.sig_start <= 1'b0;
             end
         end
         endcase
     end

   always @(negedge xbus_clock or posedge xbus_reset) begin
     if(xbus_reset == 1'b1) begin
       xio.sig_grant[0] <= 0;
       xio.sig_grant[1] <= 0;
     end
     else begin
       if(xio.sig_start && xio.sig_request[0]) begin
         xio.sig_grant[0] <= 1;
         xio.sig_grant[1] <= 0;
       end
       else if(xio.sig_start && !xio.sig_request[0] && xio.sig_request[1]) begin
         xio.sig_grant[0] <= 0;
         xio.sig_grant[1] <= 1;
       end
       else begin
         xio.sig_grant[0] <= 0;
         xio.sig_grant[1] <= 0;
       end
     end
   end

   always @(posedge xbus_clock or posedge xbus_reset) begin
     if(xbus_reset)
       read_write_n <= 1'b0;
     else if(xio.sig_read===0 && xio.sig_write===1)
       read_write_n <= 1'b0;
     else if(xio.sig_read===1 && xio.sig_write===0)
       read_write_n <= 1'b1;
     //else
     //  read_write_n <= 1'b0;
   end

endmodule

