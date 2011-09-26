//----------------------------------------------------------------------
//   Copyright 2011 Cypress Semiconductor Corporation
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

import uvm_ctypes::_uvm_ctype;

// tokens
typedef enum {UVM_TOKEN_PLUS,
              UVM_TOKEN_UVM,
              UVM_TOKEN_MINUS,
              UVM_TOKEN_ID,
              UVM_TOKEN_INT,
              UVM_TOKEN_RAND_INT,
              UVM_TOKEN_LOGIC,
              UVM_TOKEN_FLOAT,
              UVM_TOKEN_TIME,
              UVM_TOKEN_STRING,
              UVM_TOKEN_ON,
              UVM_TOKEN_OFF,
              UVM_TOKEN_EQUAL,
              UVM_TOKEN_AT,
              UVM_TOKEN_SEMI,
              UVM_TOKEN_SEPARATOR,
              UVM_TOKEN_EOL,
              UVM_TOKEN_ERROR
             } uvm_token_e;

//----------------------------------------------------------------------
// uvm_cl_lexer
//
// lexical analyzer.  Breaks a string into lexical tokens
//----------------------------------------------------------------------
class uvm_cl_lexer;

  // variable: input character stream
  local string s;

  // variable: pointer (index) to the current character in the stream
  local int unsigned p;

  // variable: pointer (index) to the beginning of the current lexeme
  local int unsigned lexp;

  //--------------------------------------------------------------------
  // start
  // initialize the string to be analyzed
  //--------------------------------------------------------------------
  function void start(string _s);
    s = _s;
    p = 0;
    lexp = 0;
    $display("lexer input stream: %s", s);
  endfunction

  //--------------------------------------------------------------------
  // get_loc
  // return the location of the last lexeme
  //--------------------------------------------------------------------
  function int unsigned get_loc();
    return lexp;
  endfunction

  //--------------------------------------------------------------------
  // function: getc
  //
  // return the next character from the input stream
  //--------------------------------------------------------------------
  local function byte getc();
    byte b;

    if(s.len() > 0 && p < s.len()) begin
      b = s[p];
      p++;
      return b;
    end

    return 0; // 0 is end-of-line (EOL)

  endfunction

  //--------------------------------------------------------------------
  // function: putc
  //
  // return the last character back to the input stream
  //--------------------------------------------------------------------
  local function void putc();
    if(p > 0) begin
      if(p < s.len())
        p--;
      else
        p = s.len() - 1;
    end
  endfunction

  //--------------------------------------------------------------------
  // function: more
  //
  // Answers the question: Are there more characters left in the 
  // input stream?
  //--------------------------------------------------------------------
  function bit more();
    return (p < s.len()); 
  endfunction

  //--------------------------------------------------------------------
  // function: mark_lexeme
  //
  // Mark the beginnning of a lexeme by setting the lexp pointer.  Take
  // care not to go past the end of the input string.
  //--------------------------------------------------------------------
  local function void mark_lexeme();
    lexp = p;
    if(p > 0)
      lexp--;
  endfunction

  //--------------------------------------------------------------------
  // function: get_lexeme
  //
  // Return the current lexeme.  This is the string between the mark
  // (lexp) and the current character pointed to by p.
  //--------------------------------------------------------------------
  function string get_lexeme();
    string lexeme = "";
    lexeme = s.substr(lexp, p-1);
    return lexeme; 
  endfunction

  //--------------------------------------------------------------------
  // function: get_int_size
  //
  // Returns the size component of a sized integer.  This is a special
  // convenience function to be called only from lex_num().  This is not
  // a general purpose function.
  //--------------------------------------------------------------------
  local function int unsigned get_int_size();
    string lexeme = s.substr(lexp, p-2);
    return lexeme.atoi();
  endfunction

  //--------------------------------------------------------------------
  // function: get_token
  //
  // Retrieve the next token from the input stream.
  //--------------------------------------------------------------------
  function uvm_token_e get_token();

    byte c;

    // skip whitespace
    for(c = getc(); `isspace(c); c = getc() );

    mark_lexeme();

    // if we have an alphabetic character then
    // the next token is an id
    if(`isalpha(c)) begin
      putc();
      for(c = getc; `isalnum(c) || c == "_"; c = getc());
      if(c != 0)
        putc();
      case(get_lexeme())
        "off"   : return UVM_TOKEN_OFF;
        "OFF"   : return UVM_TOKEN_OFF;
        "on"    : return UVM_TOKEN_ON;
        "ON"    : return UVM_TOKEN_ON;
        "true"  : return UVM_TOKEN_ON;
        "TRUE"  : return UVM_TOKEN_ON;
        "false" : return UVM_TOKEN_OFF;
        "FALSE" : return UVM_TOKEN_OFF;
        default : return UVM_TOKEN_ID;
      endcase
    end

    // a quote indicates the beginning of a string
    if(c == "\"") begin
      for(c = getc(); c != "\""; c = getc());
      return UVM_TOKEN_STRING;
    end

    // if we have a digit or a dot then the
    // next token is a number
    if(`isdigit(c) || c == "-") begin
      putc();
      return lex_num();
    end

    case (c)
      0           : return UVM_TOKEN_EOL;
      "+"         : return UVM_TOKEN_PLUS;
      "="         : return UVM_TOKEN_EQUAL;
      "@"         : return UVM_TOKEN_AT;
      ":"         : return UVM_TOKEN_SEPARATOR;
      ";"         : return UVM_TOKEN_SEMI;
      "!"         : begin
                      token_info = new();
                      token_info.kind = UVM_TOKEN_KIND_RAND_INT;
                      return UVM_TOKEN_INT;
                    end
      default     : return UVM_TOKEN_ERROR;
    endcase
  endfunction

  local function uvm_token_e lex_num();

    typedef enum {
                  STATE_START,
                  STATE_SIGN,
                  STATE_DIGIT,
                  STATE_UNDERBAR,
                  STATE_DECIMAL_POINT,
                  STATE_DECIMAL,
                  STATE_DECIMAL_UNDERBAR,
                  STATE_EXPONENT,
                  STATE_EXP_SIGN,
                  STATE_EXP_DIGIT,
                  STATE_S,
                  STATE_TIME,
                  STATE_SIGNED,
                  STATE_HEX,
                  STATE_HEX_DIGIT,
                  STATE_OCT,
                  STATE_OCT_DIGIT,
                  STATE_BIN,
                  STATE_BIN_DIGIT
                 } state_e;

    byte c;
    state_e state = STATE_START;
    string lexeme;

    token_info = new();


    forever begin
 
      c = getc();

      $display("state = %s : c = %s", state.name(), ((c==0)?"EOL":c));

      case(state)
        STATE_START:
          begin
            if(c == "+" || c == "-")
              state = STATE_SIGN;
            else
              if(`isdigit(c))
                state = STATE_DIGIT;
              else
                return UVM_TOKEN_ERROR;
          end

        STATE_SIGN:
          begin
            if(`isdigit(c))
              state = STATE_DIGIT;
            else
              return UVM_TOKEN_ERROR;
          end

        STATE_DIGIT:
          begin
            case(c)  
              "." : state = STATE_DECIMAL_POINT;
              "e" : state = STATE_EXPONENT;
              "E" : state = STATE_EXPONENT;
              "_" : state = STATE_UNDERBAR;
              "h" :
                begin
                  token_info.size = get_int_size();
                  state = STATE_HEX;
                end
              "H" :
                begin
                  token_info.size = get_int_size();
                  state = STATE_HEX;
                end
              "o" :
                begin
                  token_info.size = get_int_size();
                  state = STATE_OCT;
                end
              "O" :
                begin
                  token_info.size = get_int_size();
                  state = STATE_OCT;
                end
              "b" :
                begin
                  token_info.size = get_int_size();
                  state = STATE_BIN;
                end
              "B" :
                begin
                  token_info.size = get_int_size();
                  state = STATE_BIN;
                end
              "S" : 
                begin
                  token_info.is_signed = 1;
                  state = STATE_SIGNED;
                end
              "s" : state = STATE_S;
              "m" : state = STATE_TIME;
              "u" : state = STATE_TIME;
              "n" : state = STATE_TIME;
              "p" : state = STATE_TIME;
              "f" : state = STATE_TIME;
              default :
                begin
                  if(!`isdigit(c)) begin
                    if(c != 0) putc();
                    token_info.kind = UVM_TOKEN_KIND_INT;
                    return UVM_TOKEN_INT;
                  end
                end
            endcase
          end

        STATE_S:
          begin
            case(c)
              "h" : state = STATE_HEX;
              "H" : state = STATE_HEX;
              "o" : state = STATE_OCT;
              "O" : state = STATE_OCT;
              "b" : state = STATE_BIN;
              "B" : state = STATE_BIN;
              default:
                begin
                  if(c != 0)
                    putc();
                  return UVM_TOKEN_TIME;
                end
            endcase
          end

        STATE_UNDERBAR:
          begin
            case(c)
              "." : state = STATE_DECIMAL_POINT;
              "e" : state = STATE_EXPONENT;
              "E" : state = STATE_EXPONENT;
              "m" : state = STATE_TIME;
              "u" : state = STATE_TIME;
              "n" : state = STATE_TIME;
              "p" : state = STATE_TIME;
              "f" : state = STATE_TIME;
              "s" : 
                begin
                  state = STATE_TIME;
                  putc();
                end
              default:
                begin
                  if(!`isdigit(c) && c != "_") begin
                    if(c != 0) putc();
                    token_info.kind = UVM_TOKEN_KIND_INT;
                    return UVM_TOKEN_INT;
                  end
                 end
             endcase
          end

        STATE_DECIMAL_POINT:
          begin
            if(`isdigit(c))
              state = STATE_DECIMAL;
            else
              return UVM_TOKEN_ERROR;
          end

        STATE_DECIMAL:
          begin
            case(c)
              "e": state = STATE_EXPONENT;
              "E": state = STATE_EXPONENT;
              "_": state = STATE_DECIMAL_UNDERBAR;
              "m": state = STATE_TIME;
              "u": state = STATE_TIME;
              "n": state = STATE_TIME;
              "p": state = STATE_TIME;
              "f": state = STATE_TIME;
              "s": 
                begin
                  return UVM_TOKEN_TIME;
                end
              default:
                begin
                  if(!`isdigit(c)) begin
                    putc();
                    return UVM_TOKEN_FLOAT;
                  end
                end
            endcase
          end

        STATE_DECIMAL_UNDERBAR:
          begin
            case(c)
              "e": state = STATE_EXPONENT;
              "E": state = STATE_EXPONENT;
              "_": state = STATE_DECIMAL_UNDERBAR;
              "m": state = STATE_TIME;
              "u": state = STATE_TIME;
              "n": state = STATE_TIME;
              "p": state = STATE_TIME;
              "f": state = STATE_TIME;
              "s": 
                begin
                  return UVM_TOKEN_TIME;
                end
              default:
                begin
                  if(!`isdigit(c))
                    return UVM_TOKEN_FLOAT;
                end
            endcase
          end

        STATE_EXPONENT:
          begin
            if(c == "+" || c == "-")
              state = STATE_EXP_SIGN;
            else
              if(`isdigit(c))
                state = STATE_EXP_DIGIT;
              else
                return UVM_TOKEN_ERROR;
          end

        STATE_EXP_SIGN:
          begin
            if(`isdigit(c))
              state = STATE_EXP_DIGIT;
            else
              return UVM_TOKEN_ERROR;
          end

        STATE_EXP_DIGIT:
          begin
            case(c)
              "m": state = STATE_TIME;
              "u": state = STATE_TIME;
              "n": state = STATE_TIME;
              "p": state = STATE_TIME;
              "f": state = STATE_TIME;
              "s": 
                begin
                  state = STATE_TIME;
                  putc();
                end
              default:
                begin
                  if(!`isdigit(c)) begin
                    putc();
                    return UVM_TOKEN_FLOAT;
                  end
                end
            endcase
          end

        STATE_TIME:
          begin
            if(c != "s")
              return UVM_TOKEN_ERROR;

            putc();
            putc();
            c = getc();
            case(c)
              "m": token_info.multiplier = 1.0e-3;
              "u": token_info.multiplier = 1.0e-6;
              "n": token_info.multiplier = 1.0e-9;
              "p": token_info.multiplier = 1.0e-12;
              "f": token_info.multiplier = 1.0e-15;
              default: return UVM_TOKEN_ERROR;
            endcase
            c = getc();
            return UVM_TOKEN_TIME;
          end

        STATE_SIGNED:
          begin
            case(c)
              "h" : state = STATE_HEX;
              "H" : state = STATE_HEX;
              "o" : state = STATE_OCT;
              "O" : state = STATE_OCT;
              "b" : state = STATE_BIN;
              "B" : state = STATE_BIN;
              default:
                begin
                  putc();
                  return UVM_TOKEN_TIME;
                end
            endcase
          end

        STATE_HEX:
          begin
            if(c == "!") begin
              token_info.kind = UVM_TOKEN_KIND_RAND_INT;
              return UVM_TOKEN_INT;
            end
            if(`isxdigit(c) || `islogic(c)) begin
              mark_lexeme();
              token_info.is_logic |= `islogic(c);
              state = STATE_HEX_DIGIT;
            end
            else
              return UVM_TOKEN_ERROR;
          end

        STATE_HEX_DIGIT:
          begin
            if( !`isxdigit(c) && c != "_" && !`islogic(c)) begin
              if(c != 0) putc();
              token_info.kind = UVM_TOKEN_KIND_HEX;
              return token_info.is_logic ? UVM_TOKEN_LOGIC : UVM_TOKEN_INT;
            end
            token_info.is_logic |= `islogic(c);
          end

        STATE_OCT:
          begin
            if(c == "!") begin
              token_info.kind = UVM_TOKEN_KIND_RAND_INT;
              return UVM_TOKEN_INT;
            end
            if(`isodigit(c) || `islogic(c)) begin
              mark_lexeme();
              token_info.is_logic |= `islogic(c);
              state = STATE_OCT_DIGIT;
            end
            else
              return UVM_TOKEN_ERROR;
          end

        STATE_OCT_DIGIT:
          begin
            if( !`isodigit(c) && c !== "_" && !`islogic(c)) begin
              if(c != 0) putc();
              lexeme = get_lexeme();
              token_info.kind = UVM_TOKEN_KIND_OCT;
              return token_info.is_logic ? UVM_TOKEN_LOGIC : UVM_TOKEN_INT;
            end
            token_info.is_logic |= `islogic(c);
          end

        STATE_BIN:
          begin
            if(c == "!") begin
              token_info.kind = UVM_TOKEN_KIND_RAND_INT;
              return UVM_TOKEN_INT;
            end
            if(c == "0" || c == "1"  || `islogic(c)) begin
              mark_lexeme();
              token_info.is_logic |= `islogic(c);
              state = STATE_BIN_DIGIT;
            end
            else
              return UVM_TOKEN_ERROR;
          end

        STATE_BIN_DIGIT:
          begin
            if(! (c == "0" || c == "1")  && !`islogic(c)) begin
              if(c != 0) putc();
              token_info.kind = UVM_TOKEN_KIND_BIN;
              return token_info.is_logic ? UVM_TOKEN_LOGIC : UVM_TOKEN_INT;
            end
            token_info.is_logic |= `islogic(c);
          end

      endcase

    end  // forever

  endfunction

endclass
