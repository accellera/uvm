//----------------------------------------------------------------------
//   Copyright 2007-2010 Mentor Graphics Corporation
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
// The ctypes API is a collection of macros that emulate the C ctypes
// functions.  These macros ask if a character posseses certain
// characteristics. See ctypes.sv for the characteric definitions for
// each ASCII character.
//----------------------------------------------------------------------

`define _U      'h1        // upper case
`define _L      'h2        // lower case
`define _N      'h4        // numeric
`define _S      'h10       // whitespace
`define _P      'h20       // punctuation
`define _C      'h40       // control char
`define _X      'h100      // hexidecimal
`define _B      'h200      // blank

`define cmask   'h7f

`define	isalpha(c)	(((ctypes::_ctype[(c) & `cmask])&(`_U | `_L)) > 0)
`define isblank(c)	(((c) & `cmask) == ' ' || ((c) & `cmask) == '\t')
`define	isupper(c)	(((ctypes::_ctype[(c) & `cmask]) & `_U) > 0)
`define	islower(c)	(((ctypes::_ctype[(c) & `cmask]) & `_L) > 0)
`define	isdigit(c)	(((ctypes::_ctype[(c) & `cmask]) & `_N) > 0)
`define	isxdigit(c)	(((ctypes::_ctype[(c) & `cmask]) & (`_X | `_N)) > 0)
`define	isspace(c)	(((ctypes::_ctype[(c) & `cmask]) & `_S) > 0)
`define ispunct(c)	(((ctypes::_ctype[(c) & `cmask]) & `_P) > 0)
`define isalnum(c)	(((ctypes::_ctype[(c) & `cmask]) & (`_U | `_L | `_N)) > 0)
`define isprint(c)	(((ctypes::_ctype[(c) & `cmask]) & (`_P | `_U | `_L | `_N | `_B )) > 0)
