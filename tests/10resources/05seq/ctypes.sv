//----------------------------------------------------------------------
//   Copyright 2010 Mentor Graphics Corporation
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
// ctypes
//
// This is an implementation of the C library ctypes in SystemVerilog.
// Each element of the _cytpes array represents an ASCII character.  The
// contents of each array element is a bit field with each bit
// identifying a characteristic of the character.  A collection of
// macros is available which look like the C ctype functions for testing
// a character to see what characteristics it has.  See ctypes.svh for
// the definitions of the bit field and the macros.
//----------------------------------------------------------------------

package ctypes;

  `include "ctypes.svh"

  byte _ctype[128] = '{
    0,              //   0
    0,              //   1
    0,              //   2
    0,              //   3
    0,              //   4
    0,              //   5
    0,              //   6
    0,              //   7
    0,              //   8
    0 | `_S,        //   9
    0 | `_S,        //  10
    0 | `_S,        //  11
    0 | `_S,        //  12
    0 | `_S,        //  13
    0,              //  14
    0,              //  15
    0,              //  16
    0,              //  17
    0,              //  18
    0,              //  19
    0,              //  20
    0,              //  21
    0,              //  22
    0,              //  23
    0,              //  24
    0,              //  25
    0,              //  26
    0,              //  27
    0,              //  28
    0,              //  29
    0,              //  30
    0,              //  31
    0 | `_S | `_B,  //  32 =  
    0 | `_P,        //  33 = !
    0 | `_P,        //  34 = "
    0 | `_P,        //  35 = #
    0 | `_P,        //  36 = $
    0 | `_P,        //  37 = %
    0 | `_P,        //  38 = &
    0 | `_P,        //  39 = '
    0 | `_P,        //  40 = (
    0 | `_P,        //  41 = )
    0 | `_P,        //  42 = *
    0 | `_P,        //  43 = +
    0 | `_P,        //  44 = ,
    0 | `_P,        //  45 = -
    0 | `_P,        //  46 = .
    0 | `_P,        //  47 = /
    0 | `_N | `_X,  //  48 = 0
    0 | `_N | `_X,  //  49 = 1
    0 | `_N | `_X,  //  50 = 2
    0 | `_N | `_X,  //  51 = 3
    0 | `_N | `_X,  //  52 = 4
    0 | `_N | `_X,  //  53 = 5
    0 | `_N | `_X,  //  54 = 6
    0 | `_N | `_X,  //  55 = 7
    0 | `_N | `_X,  //  56 = 8
    0 | `_N | `_X,  //  57 = 9
    0 | `_P,        //  58 = :
    0 | `_P,        //  59 = ;
    0 | `_P,        //  60 = <
    0 | `_P,        //  61 = =
    0 | `_P,        //  62 = >
    0 | `_P,        //  63 = ?
    0 | `_P,        //  64 = @
    0 | `_U | `_X,  //  65 = A
    0 | `_U | `_X,  //  66 = B
    0 | `_U | `_X,  //  67 = C
    0 | `_U | `_X,  //  68 = D
    0 | `_U | `_X,  //  69 = E
    0 | `_U | `_X,  //  70 = F
    0 | `_U,        //  71 = G
    0 | `_U,        //  72 = H
    0 | `_U,        //  73 = I
    0 | `_U,        //  74 = J
    0 | `_U,        //  75 = K
    0 | `_U,        //  76 = L
    0 | `_U,        //  77 = M
    0 | `_U,        //  78 = N
    0 | `_U,        //  79 = O
    0 | `_U,        //  80 = P
    0 | `_U,        //  81 = Q
    0 | `_U,        //  82 = R
    0 | `_U,        //  83 = S
    0 | `_U,        //  84 = T
    0 | `_U,        //  85 = U
    0 | `_U,        //  86 = V
    0 | `_U,        //  87 = W
    0 | `_U,        //  88 = X
    0 | `_U,        //  89 = Y
    0 | `_U,        //  90 = Z
    0 | `_P,        //  91 = [
    0 | `_P,        //  92 = \
    0 | `_P,        //  93 = ]
    0 | `_P,        //  94 = ^
    0 | `_P,        //  95 = _
    0 | `_P,        //  96 = `
    0 | `_L | `_X,  //  97 = a
    0 | `_L | `_X,  //  98 = b
    0 | `_L | `_X,  //  99 = c
    0 | `_L | `_X,  // 100 = d
    0 | `_L | `_X,  // 101 = e
    0 | `_L | `_X,  // 102 = f
    0 | `_L,        // 103 = g
    0 | `_L,        // 104 = h
    0 | `_L,        // 105 = i
    0 | `_L,        // 106 = j
    0 | `_L,        // 107 = k
    0 | `_L,        // 108 = l
    0 | `_L,        // 109 = m
    0 | `_L,        // 110 = n
    0 | `_L,        // 111 = o
    0 | `_L,        // 112 = p
    0 | `_L,        // 113 = q
    0 | `_L,        // 114 = r
    0 | `_L,        // 115 = s
    0 | `_L,        // 116 = t
    0 | `_L,        // 117 = u
    0 | `_L,        // 118 = v
    0 | `_L,        // 119 = w
    0 | `_L,        // 120 = x
    0 | `_L,        // 121 = y
    0 | `_L,        // 122 = z
    0 | `_P,        // 123 = {
    0 | `_P,        // 124 = |
    0 | `_P,        // 125 = }
    0 | `_P,        // 126 = ~
    0               // 127
    };

endpackage
