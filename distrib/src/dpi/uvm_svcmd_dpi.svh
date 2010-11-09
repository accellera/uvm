// Import DPI functions used by the interface to generate the
// lists.

import "DPI-C" function string dpi_get_next_arg_c ();
function string dpi_get_next_arg();
  return dpi_get_next_arg_c();
endfunction

import "DPI-C" function string dpi_get_tool_name_c ();
function string dpi_get_tool_name();
  return dpi_get_tool_name_c();
endfunction

import "DPI-C" function string dpi_get_tool_version_c ();
function string dpi_get_tool_version();
  return dpi_get_tool_version_c();
endfunction

import "DPI-C" function chandle dpi_regcomp(string regex);
import "DPI-C" function int dpi_regexec(chandle preg, string str);
import "DPI-C" function void dpi_regfree(chandle preg);

