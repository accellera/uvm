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
// uvm_ctypes
//
// The uvm_ctypes API is a collection of macros that emulate the C ctypes
// functions.  These macros ask if a character posseses certain
// characteristics. See uvm_ctypes.sv for the characteric definitions for
// each ASCII character.
//----------------------------------------------------------------------

`define _U      'h1        // upper case
`define _L      'h2        // lower case
`define _N      'h4        // numeric
`define _S      'h8        // whitespace
`define _P      'h10       // punctuation
`define _C      'h20       // control char
`define _X      'h40       // hexidecimal
`define _B      'h80       // blank

`define cmask   'h7f

`define	isalpha(c)	(((uvm_ctypes::_uvm_ctype[(c) & `cmask])&(`_U | `_L)) > 0)
`define isblank(c)	(((c) & `cmask) == ' ' || ((c) & `cmask) == '\t')
`define	isupper(c)	(((uvm_ctypes::_uvm_ctype[(c) & `cmask]) & `_U) > 0)
`define	islower(c)	(((uvm_ctypes::_uvm_ctype[(c) & `cmask]) & `_L) > 0)
`define	isdigit(c)	(((uvm_ctypes::_uvm_ctype[(c) & `cmask]) & `_N) > 0)
`define	isxdigit(c)	(((uvm_ctypes::_uvm_ctype[(c) & `cmask]) & `_X) > 0)
`define	isspace(c)	(((uvm_ctypes::_uvm_ctype[(c) & `cmask]) & `_S) > 0)
`define ispunct(c)	(((uvm_ctypes::_uvm_ctype[(c) & `cmask]) & `_P) > 0)
`define isalnum(c)	(((uvm_ctypes::_uvm_ctype[(c) & `cmask]) & (`_U | `_L | `_N)) > 0)
`define isprint(c)	(((uvm_ctypes::_uvm_ctype[(c) & `cmask]) & (`_P | `_U | `_L | `_N | `_B )) > 0)
`define isodigit(c) ((((c) & `cmask) >= 48) &&(((c) & `cmask) <= 55))
`define islogic(c)  (((c) == "x") || ((c) == "X") || ((c) == "z") || ((c) == "Z"))
