//----------------------------------------------------------------------
//   Copyright 2011 Cypress Semiconductor Corporation
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
// class: uvm_cl_parser
//----------------------------------------------------------------------
class uvm_cl_parser;

  local uvm_cmdline_processor cl;
  local uvm_cl_lexer lexer;
  local uvm_parsed_options opts;
  local uvm_token_e lookahead;

  //--------------------------------------------------------------------
  // function: parse
  //--------------------------------------------------------------------
  function void parse();

    string arg;
    string args[$];
    name_value_pair nvp;

    lexer = new();
    cl = uvm_cmdline_processor::get_inst();
    cl.get_uvm_args(args);
    opts = new();

    foreach (args[i]) begin
      arg = args[i];
      $display("arg %0d: %s", i, arg);
      lexer.start(arg);
      lookahead = lexer.get_token();
      uvm_option();
    end

    opts.print();

    opts.gen_resources();

  endfunction

  //--------------------------------------------------------------------
  // function uvm_option
  //
  // option :: '+' 'UVM' ':' assignments
  //        || '+' assignments
  //            the first symbol must have a "UVM" or "uvm" prefix
  // +UVM is a special case which we ignore
  //--------------------------------------------------------------------
  function void uvm_option();

    string lexeme;

    match(UVM_TOKEN_PLUS);
    lexeme = lexer.get_lexeme();

    // We ignore +UVM or +uvm
    if(lexeme == "UVM" || lexeme == "uvm") begin
      match(UVM_TOKEN_ID);
      case(lookahead)
        UVM_TOKEN_SEPARATOR : match(UVM_TOKEN_SEPARATOR);
        UVM_TOKEN_EOL       : return;
        default             : parse_error(lookahead.name());
      endcase
    end
      
    assignments();
    
  endfunction

  //--------------------------------------------------------------------
  // function: assignments
  //
  // assignments :: assignment ':' assignments
  //             || assignment
  //--------------------------------------------------------------------
  function void assignments();
    assignment();
    if(lookahead == UVM_TOKEN_SEPARATOR) begin
      match(UVM_TOKEN_SEPARATOR);
      assignments();
    end
    else
      if(lookahead != UVM_TOKEN_EOL)
        parse_error(lexer.get_lexeme());
  endfunction

  //--------------------------------------------------------------------
  // function: assignment
  //
  // assignment :: id
  //            || id scope
  //            || id '=' value
  //            || id '=' value scope
  //--------------------------------------------------------------------
  function void assignment();

    string name;

    name = match_and_get_lexeme(UVM_TOKEN_ID);

    if(lookahead != UVM_TOKEN_EQUAL) begin
      nvp#(bit) nv = new(name, "1");
      nv.set(1);
      scope(nv);
      opts.push(nv);
      return;
    end

    match(UVM_TOKEN_EQUAL);
    value(name);

  endfunction

  //--------------------------------------------------------------------
  // function: value
  //
  // value :: int
  //       || float
  //       || time
  //       || string
  //       || id
  //       || ON | on | OFF | off
  //       || TRUE | true | FALSE | false
  //       || !
  //
  // string is a string quoted with double quotes
  // id is treated like a string without quotes
  // time is a floating point value that has been scaled by the time unit.
  // ! represents a random number
  //--------------------------------------------------------------------
  function void value(string name);

    name_value_pair nvb;
    string lexeme = lexer.get_lexeme();

    case(lookahead)
      UVM_TOKEN_INT:
         begin
          nvp#(int) nv = new(name, lexeme);
          case(token_info.kind)
            UVM_TOKEN_KIND_INT: nv.set(lexeme.atoi());
            UVM_TOKEN_KIND_HEX: nv.set(lexeme.atohex());
            UVM_TOKEN_KIND_OCT: nv.set(lexeme.atooct());
            UVM_TOKEN_KIND_BIN: nv.set(lexeme.atobin());
            UVM_TOKEN_KIND_RAND_INT:
              begin
                nv.set($urandom());
              end
          endcase
          nvb = nv;
        end

      UVM_TOKEN_LOGIC:
        begin
          nvp#(logic [31:0]) nv = new(name, lexeme);
          case(token_info.kind)
            UVM_TOKEN_KIND_INT: nv.set(lexeme.atoi());
            UVM_TOKEN_KIND_HEX: nv.set(lexeme.atohex());
            UVM_TOKEN_KIND_OCT: nv.set(lexeme.atooct());
            UVM_TOKEN_KIND_BIN: nv.set(lexeme.atobin());
            UVM_TOKEN_KIND_RAND_INT:
              begin
                nv.set($urandom());
              end
          endcase
          nvb = nv;
        end

      UVM_TOKEN_FLOAT:
        begin
          nvp#(real) nv = new(name, lexeme);
          string s = strip_chars(lexeme, "_");
          nv.set(s.atoreal());
          nvb = nv;
        end

      UVM_TOKEN_TIME:
        begin
          real val;
          nvp#(real) nv = new(name, lexeme);
          string s = strip_chars(lexeme, "_");
          val = s.atoreal() * token_info.multiplier;
          nv.set(val);
          nvb = nv;
        end

      UVM_TOKEN_STRING:
        begin
          nvp#(string) nv = new(name, lexeme);
          nv.set(strip_chars(lexeme, "\""));
          nvb = nv;
        end

      UVM_TOKEN_ID:
        begin
          nvp#(string) nv = new(name, lexeme);
          nv.set(lexeme);
          nvb = nv;
        end

      UVM_TOKEN_ON:
        begin
          nvp#(bit) nv = new(name, lexeme);
          nv.set(1);
          nvb = nv;
        end

      UVM_TOKEN_OFF:
        begin
          nvp#(bit) nv = new(name, lexeme);
          nv.set(0);
          nvb = nv;
        end

      default:
        begin
          parse_error("value");
          return;
        end
    endcase

    match(lookahead);
    scope(nvb);
    opts.push(nvb);

  endfunction

  //--------------------------------------------------------------------
  // function: scope
  //
  // scope :: @ string
  //
  // where 'string' is a regular expression identifying the scopes
  // over which the option will be visible
  //--------------------------------------------------------------------
  function void scope(name_value_pair nvp);

    if(lookahead != UVM_TOKEN_AT) begin
      return;
    end

    match(UVM_TOKEN_AT);
    nvp.scope = strip_chars(match_and_get_lexeme(UVM_TOKEN_STRING), "\"");

  endfunction

  //--------------------------------------------------------------------
  // function: match_and_get_lexeme
  //
  // Matches token and advances lookahead.  Also returns the lexeme
  // associated with the matched token. Parse error is emitted if token
  // does not match.
  //--------------------------------------------------------------------
  function string match_and_get_lexeme(uvm_token_e t);

    string s;

    if(t == lookahead) begin
      s = lexer.get_lexeme();
      $display("match %s : %s", lookahead.name(), s);
      lookahead = lexer.get_token();
      return s;
    end

    parse_error(t.name());
    return "";

  endfunction

  //--------------------------------------------------------------------
  // function: match
  //
  // Matches token and advances lookahead.  Parse error is emitted if
  // token does not match.
  //--------------------------------------------------------------------
  function void match(uvm_token_e t);
    if(t == lookahead) begin
      $display("match %s : %s", lookahead.name(), lexer.get_lexeme());
      lookahead = lexer.get_token();
    end
    else
      parse_error(t.name());
  endfunction

  //--------------------------------------------------------------------
  // function: parse_error
  //
  // Emit a parse error
  //--------------------------------------------------------------------
  function void parse_error(string err);
    string lexeme = lexer.get_lexeme();
    if(lexeme == "")
      lexeme = "end-of-line";
    if(err == "")
      err = "end-of-line";
    $display("command line parse error at %s: expecting %s and saw %s instead",
             lexeme, err, lookahead.name());
  endfunction

  //--------------------------------------------------------------------
  // function: strip_chars
  //
  // remove all of one kind of character from a string
  //--------------------------------------------------------------------
  function string strip_chars(string s, byte c);
    string t;
    int unsigned i;

    for(i = 0; i < s.len(); i++) begin
      if(s[i] != c)
        t = { t, s[i] };
    end

    return t;

  endfunction

endclass