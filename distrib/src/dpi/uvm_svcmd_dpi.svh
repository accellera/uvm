// Import DPI functions used by the interface to generate the
// lists.

`ifndef UVM_CMDLINE_NO_DPI
import "DPI-C" function string dpi_get_next_arg_c ();
import "DPI-C" function string dpi_get_tool_name_c ();
import "DPI-C" function string dpi_get_tool_version_c ();

function string dpi_get_next_arg();
  return dpi_get_next_arg_c();
endfunction

function string dpi_get_tool_name();
  return dpi_get_tool_name_c();
endfunction

function string dpi_get_tool_version();
  return dpi_get_tool_version_c();
endfunction

import "DPI-C" function chandle dpi_regcomp(string regex);
import "DPI-C" function int dpi_regexec(chandle preg, string str);
import "DPI-C" function void dpi_regfree(chandle preg);

`else
function string dpi_get_next_arg();
  return "";
endfunction

function string dpi_get_tool_name();
  return "?";
endfunction

function string dpi_get_tool_version();
  return "?";
endfunction

`endif
