//----------------------------------------------------------------------
// class: checker_base#(T)
//----------------------------------------------------------------------
class checker_base #(type T=int);

  typedef uvm_resource#(T) rsrc_t;

  virtual function string convert2string(rsrc_t rsrc);
    return "<empty>";
  endfunction

  virtual function bit match(T a, T b);
    return (a == b);
  endfunction

  function void lookfor_and_match(string name, T t, string scope="CL::");

    rsrc_t rsrc;
    T val;
    string msg;

    rsrc = get(name, scope);
    if(rsrc == null)
      return;

    val = rsrc.read(null);
    if(!match(val, t)) begin
      $sformat(msg, "resource value of %s does not match expected value", convert2string(rsrc));
      uvm_report_error("mismatch", msg);
    end
    else begin
      $sformat(msg, "resource value of %s matches expected value", convert2string(rsrc));
      uvm_report_info("match", msg);
    end

  endfunction

  function rsrc_t get(string name, string scope = "CL::");

    string msg;
    rsrc_t rsrc = rsrc_t::get_by_name(scope, name);

    if(rsrc == null) begin
      string msg;
      $sformat(msg, "resource %s in scope %s is not in resources database", name, scope);
      uvm_report_error("no resource", msg);
      return null;
    end
    else begin
      $sformat(msg, "%s: %s = %s", name, rsrc.get_scope(), convert2string(rsrc));
      uvm_report_info("found", msg);
    end
    return rsrc;
  endfunction

  function void lookfor(string name, scope = "CL::");
    rsrc_t rsrc = get(name, scope);
  endfunction
endclass

`define EPSILON 1.0e-29

class checker_float extends checker_base#(real);

  function string convert2string(rsrc_t rsrc);
    string s;
    $sformat(s, "%12.6g", rsrc.read(null));
    return s;
  endfunction

  function bit match(real a, real b);
    return ( (b - a) <= `EPSILON );
  endfunction 

endclass

class checker_int extends checker_base#(int);

  function string convert2string(rsrc_t rsrc);
    string s;
    $sformat(s, "%0d", rsrc.read(null));
    return s;
  endfunction

endclass

class checker_bit extends checker_base#(bit);

  function string convert2string(rsrc_t rsrc);
    string s;
    $sformat(s, "%0b", rsrc.read(null));
    return s;
  endfunction

endclass

class checker_string extends checker_base#(string);
  
  function string convert2string(rsrc_t rsrc);
    return rsrc.read(null);
  endfunction

endclass


class checker_logic32 extends checker_base#(logic [31:0]);
  
  function string convert2string(rsrc_t rsrc);
    string s;
    $sformat(s, "%0x", rsrc.read(null));
    return s;
  endfunction

  function bit match(logic [31:0] a, logic [31:0] b);
    return (a === b);
  endfunction 

endclass
