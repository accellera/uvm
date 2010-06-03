//----------------------------------------------------------------------
//   Copyright 2007-2009 Mentor Graphics Corporation
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

//----------------------------------------------------------------------
// This is a collection of parameters needed to connect an FPU to an
// hfpb bus. To use these parmaeters, include them in an object
// parameterized with DATA_SIZE and ADDR_SIZE, the same parameters used
// to parameterize hfpb components.  For example,
//
//  class my_fpu #(type int DATA_SIZE=8, type ADDR_SIZE=16);
//
//    `include "hfpb_parameters.svh"
//    ...
//  endclass
//----------------------------------------------------------------------

  // OPSIZE is the size in bits of the FPU operand
  // WORDS is the number of words, including partial words, in an FPU
  // operand.  The number of bits in a word is defined by the parameter
  // DATA_SIZE.

  //localparam int unsigned OPSIZE = 32;
  //localparam int unsigned WORDS = (OPSIZE / DATA_SIZE) +
  //                   ((OPSIZE - ((OPSIZE / DATA_SIZE) * DATA_SIZE)) > 0);
  `define OPSIZE 32
  `define WORDS (`OPSIZE / DATA_SIZE) + \
                     ((`OPSIZE - ((`OPSIZE / DATA_SIZE) * DATA_SIZE)) > 0)

  // addresses in FPU connected to bus
  //localparam int unsigned A_addr      = 0;
  //localparam int unsigned B_addr      = 1*WORDS;
  //localparam int unsigned R_addr      = 2*WORDS;
  //localparam int unsigned op_addr     = 3*WORDS;
  //localparam int unsigned round_addr  = 3*WORDS+1;
  //localparam int unsigned status_addr = 3*WORDS+2;
  const int unsigned A_addr      = 0;
  const int unsigned B_addr      = 1*`WORDS;
  const int unsigned R_addr      = 2*`WORDS;
  const int unsigned op_addr     = 3*`WORDS;
  const int unsigned round_addr  = 3*`WORDS+1;
  const int unsigned status_addr = 3*`WORDS+2;

  typedef bit [`OPSIZE-1:0] operand_t;
  typedef bit [DATA_SIZE-1:0] data_t;
  typedef bit [ADDR_SIZE-1:0] addr_t;
  typedef hfpb_transaction #(DATA_SIZE, ADDR_SIZE) hfpb_tr_t;


