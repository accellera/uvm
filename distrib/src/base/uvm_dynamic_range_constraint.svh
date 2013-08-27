//
//----------------------------------------------------------------------
//   Copyright 2013 Freescale Semiconductor, Inc.
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

`ifndef UVM_DYNAMIC_RANGE_CONSTRAINT_SV
`define UVM_DYNAMIC_RANGE_CONSTRAINT_SV

class range_limits;
  int unsigned low;
  int unsigned high;

  function new(int unsigned l, int unsigned h);
    low  = l;
    high = h;
  endfunction: new
endclass: range_limits

class uvm_dynamic_range_constraint_parser;
  // Split the string parm to integers.  ";" is used as a delimiter to seperate triplets
  // And then ":" is used to deliminate the actual triplet values.
  // Example: "1:2:3;4:5:6"
  //  Becomes: "1:2:3", "4:5:6"
  //  Which then becomes 1,2,3,4,5,6
  static function void split_param_to_integer(string param, output int unsigned values[$]);
    string str_values_triplet[$];
    string str_values[$];

    // First split the param into strings using ";" as a delimiter
    uvm_split_string(param, ";", str_values_triplet);

    foreach(str_values_triplet[index])
    begin
      string str_values_tmp[$];
      uvm_split_string(str_values_triplet[index], ":", str_values_tmp);
      case(str_values_tmp.size())
        3: begin
             foreach(str_values_tmp[index_tmp])
               str_values.push_back(str_values_tmp[index_tmp]);
           end
        2: begin
               str_values.push_back(str_values_tmp[0]);
               str_values.push_back(str_values_tmp[1]);
               str_values.push_back("1");
           end
        1: begin
               str_values.push_back(str_values_tmp[0]);
               str_values.push_back(str_values_tmp[0]);
               str_values.push_back("1");
           end
        default: uvm_report_fatal("DYNAMICRANDOM",{str_values_triplet[index], " is not a valid dynamic constraint"}); 
      endcase
    end

    // Then convert the string into integers
    foreach(str_values[index])
      str_2_uint(str_values[index], values[index]);
  endfunction: split_param_to_integer


  // Once Mantis 4399 is implemented, this str_2_uint() will no longer
  // be needed.  Instead, radix processing will be integrated into the
  // CmdLineParser and we will be able to use that

  // Change the str into integer
  static function void str_2_uint(string str, output int unsigned data);
    string str_format;
    string str_orig = str;

    str = str.tolower();
    while (str.getc(0) == " ")  // Remove leading spaces
          str = str.substr(1, str.len()-1);

    if (str.len() == 0)  // If passed an empty string or a string only consisting of spaces
       uvm_report_fatal("DYNAMICRANDOM",{"\"", str_orig, "\" is not a valid dynamic constraint"}); 

    if (str.getc(0) == "0")
    case(str.getc(1))
      "h":      
        str_format = "0h%h";
      "x":      
        str_format = "0x%h";
      "d":      
        str_format = "0d%d";
      "o":      
        str_format = "0o%o";
      "b":     
        str_format = "0b%b";
      default:  
       // The second character was not a str_radix specifier, so
       // default to interpreting the entire string as decimal.
       str_format = "%d";
    endcase
    else
      // There was no leading zero character, so default to interpreting
      // the entire string as decimal.
      str_format = "%d";

    if (!$sscanf(str, str_format, data))
       uvm_report_fatal("DYNAMICRANDOM",{str, " could not be interpreted into an integer"});
  endfunction: str_2_uint
  
endclass: uvm_dynamic_range_constraint_parser


class uvm_dynamic_range_constraint #(string NAME="") extends uvm_object;
  typedef uvm_dynamic_range_constraint #(NAME) this_type;

  //Singleton
  static local this_type m_inst;

  static function this_type get_inst();
    if (m_inst == null)
       m_inst = new();
    return m_inst;
  endfunction: get_inst

  static function int unsigned get_rand_value();
    this_type inst = this_type::get_inst();
    void'(inst.randomize());
    return inst.value;
  endfunction: get_rand_value

  local function new();
    super.new(NAME);
    get_cmdline_param(); 
  endfunction: new

  local function void get_cmdline_param();
    uvm_cmdline_processor clp = uvm_cmdline_processor::get_inst();
    string params[$];
    string constraint_param;
    int unsigned values[$];
    int unsigned index = 0;
    int unsigned low;
    int arg_count = clp.get_arg_values({"+",NAME}, params);

    if (arg_count == 0)
       return;
    
    if (params[0].getc(0) != "=")
    begin
      uvm_report_warning("DYNAMICRANDOM", 
                          $sformatf("the format of the %s parameter is wrong", NAME));
      return;
    end
    else
       constraint_param = params[0].substr(1, params[0].len()-1);

    if (arg_count > 1)
    begin
      string max_constraint_param = params[0];
      for(int unsigned lindex = 1; lindex < params.size(); ++lindex)
        max_constraint_param = {max_constraint_param, ", ", params[lindex]};
      uvm_report_warning("DYNAMICRANDOM", 
                         $sformatf("Multiple (%0d) %s arguments provided on the command line.  '%s' will be used.  Provided list: %s.", 
                                    arg_count, NAME, params[0], max_constraint_param), UVM_NONE);
    end
    else
      uvm_report_info("DYNAMICRANDOM",
                      $sformatf("'%s=%s' provided on the command line is being applied.", NAME, params[0]), UVM_NONE);
    
    uvm_dynamic_range_constraint_parser::split_param_to_integer(constraint_param, values);

    //after parse the parameter add the constraint

    while(index + 3 <= values.size())
    begin
      add(values[index], values[index+1], values[index+2]);
      index += 3;
    end
 endfunction: get_cmdline_param

  local range_limits ranges[$];
  local range_limits weights[$];
  local int unsigned max_weight = 0;
  rand int unsigned weight_value;
  rand int unsigned value;
  rand int unsigned index;

  constraint valid_weight
  {
    weight_value inside {[0:max_weight-1]};
  }

  constraint weight_to_index
  {
    foreach (weights[current_index])
      if(weight_value inside {[weights[current_index].low:weights[current_index].high]})
        index == current_index;
  }

  constraint in_range
  {
    foreach (ranges[current_index])
      index != current_index || value inside {[ranges[current_index].low:ranges[current_index].high]};
  }

  constraint order 
  {
    solve weight_value before index;
    solve index before value;
  }

  local function void add(int unsigned min, int unsigned max, int unsigned weight);
    range_limits range;
    range_limits weight_range;
    int unsigned range_index;

    range = new(min, max);
    ranges.push_back(range);
    range_index = ranges.size()-1;

    weight_range = new(max_weight, max_weight+weight*(max-min+1)-1);
    weights.push_back(weight_range);
    max_weight += weight*(max-min+1);
  endfunction: add

endclass: uvm_dynamic_range_constraint

`endif //UVM_DYNAMIC_RANGE_CONSTRAINT_SV
