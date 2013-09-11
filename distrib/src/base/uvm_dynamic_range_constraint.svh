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

//------------------------------------------------------------------------------
//
// CLASS: uvm_dynamic_range_constraint_parser
//
// The uvm_dynamic_range_constraint_parser class used to parse 
// the string with the range constraint into triplet.
// ";" is used as delimiter to seperate distributions.
// ":" is used as delimiter to seperate the range and weight.
// The format of the distribution is range_low:range_high:weight.
// If the weight is not specified, it is set to 1 by default.
// If the range_high is not specified, it is set to range_low by default
// Example: "1:2:3;4:5:6" => 1,2,3,4,5,6
//          "1:2;4" => 1,2,1,4,4,1
// 
//------------------------------------------------------------------------------

class uvm_dynamic_range_constraint_parser extends uvm_object;

  // Function: get_range_constraint
  //
  // Parses the constraint_param with the format of range constraint
  // into the integer array.

  static function void get_range_constraint(string constraint_param, output int unsigned values[]);
    string str_values_triplet[$];
    string str_values[];

    // First split the constraint_param into strings using ";" as a delimiter
    uvm_split_string(constraint_param, ";", str_values_triplet);
    str_values = new [str_values_triplet.size()*3];
    values = new[str_values.size()];

    foreach(str_values_triplet[index])
    begin
      string str_values_tmp[$];
      uvm_split_string(str_values_triplet[index], ":", str_values_tmp);
      case(str_values_tmp.size())
        3: begin  // Min, Max, & Weight Provided
             foreach(str_values_tmp[index_tmp])
               str_values[index*3+index_tmp] = str_values_tmp[index_tmp];
           end
        2: begin  // Min, Max Provided; Weight defaulted to "1"
               str_values[index*3+0] = str_values_tmp[0];
               str_values[index*3+1] = str_values_tmp[1];
               str_values[index*3+2] = "1";
           end
        1: begin // Single constraint provided; Use it as both Min & Max
                 // and set Weight to "1"
               str_values[index*3+0] = str_values_tmp[0];
               str_values[index*3+1] = str_values_tmp[0];
               str_values[index*3+2] = "1";
           end
        default: `uvm_fatal("DYNAMICRANDOM",{str_values_triplet[index], " is not a valid dynamic constraint"}) 
      endcase
    end

    // Then convert the string into integers
    foreach(str_values[index])
      str_2_uint(str_values[index], values[index]);
  endfunction: get_range_constraint

  // Function: str_2_uint
  //
  // Changes the string into integer
  //
  // Once Mantis 4399 is implemented, str_2_uint() will no longer
  // be needed.  Instead, radix processing will be integrated into the
  // CmdLineParser and we will be able to use that
  static function void str_2_uint(string str, output int unsigned data);
    string str_format;
    string str_orig = str;

    str = str.tolower();
    while (str.getc(0) == " ")  // Remove leading spaces
          str = str.substr(1, str.len()-1);

    if (str.len() == 0)  // If passed an empty string or a string
                         // consisting only of spaces
       `uvm_fatal("DYNAMICRANDOM",{"\"", str_orig, "\" is not a valid dynamic constraint"}) 

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
       `uvm_fatal("DYNAMICRANDOM",{str, " could not be interpreted into an integer"})
  endfunction: str_2_uint
  
endclass: uvm_dynamic_range_constraint_parser

//------------------------------------------------------------------------------
//
// CLASS: uvm_dynamic_range_constraint
//
// The uvm_dynamic_range_constraint class is the random class 
// to randomize the value based on the range constraint on the command line
//
// If other constraint for value are specified in the derived class,
// it will intersect with the range constraint
// 
//------------------------------------------------------------------------------

class uvm_dynamic_range_constraint extends uvm_object;

  static local int unsigned m_values[string][];
  
  // Variable: constraint_param
  //
  // This string is in the format of range constraint.
  // It is set by the commandline using +uvm_set_config_string.

  string constraint_param="";
  local int constraint_set = 0;
  local range_limits ranges[];
  local longint weights[];
  local longint max_weight = 0;
  local int unsigned range_index = 0;
  local rand int unsigned dist_choose[];
  local rand int unsigned sum_dist_choose[];
  local rand int unsigned index;

  // Variable: value
  //
  // The random value obey the range constraint.

  rand int unsigned value;

  `uvm_object_utils_begin(uvm_dynamic_range_constraint)
    `uvm_field_string(constraint_param, UVM_DEFAULT)
  `uvm_object_utils_end

  // Function: new
  //
  // Creates a new object with the given ~name~.

  function new(string name = "");
    super.new(name);
  endfunction: new

  // Function: add_range_constraint
  //
  // Adds the range constraint.
  // the ~range~ is in the format of range constraint.

  function void add_range_constraint(string range);
    int unsigned i = 0;

    if(!m_values.exists(range))
      uvm_dynamic_range_constraint_parser::get_range_constraint(range, m_values[range]);

    if( ranges.size() == 0 )
    begin
      ranges = new[m_values[range].size()/3];
      weights = new[m_values[range].size()/3];
      dist_choose = new[m_values[range].size()/3];
      sum_dist_choose = new[m_values[range].size()/3];
    end
    else
    begin
      ranges = new[ranges.size()+m_values[range].size()/3](ranges);
      weights = new[weights.size()+m_values[range].size()/3](weights);
      dist_choose = new[dist_choose.size()+m_values[range].size()/3](dist_choose);
      sum_dist_choose = new[dist_choose.size()+m_values[range].size()/3](sum_dist_choose);
    end

    // After parsing the parameter, add the constraint
    while(i + 3 <= m_values[range].size())
    begin
      add(m_values[range][i], m_values[range][i+1], m_values[range][i+2]);
      i += 3;
    end

  endfunction: add_range_constraint

  // Function: pre_randomize
  //
  // Adds the command line range constraint.
  // Uses the [0:0xFFFFFFFF] as the default if constraint_param is not set yet.

  function void pre_randomize();
    int override = 1;

    super.pre_randomize();

    if(constraint_set == 0)
    begin
      constraint_set = 1;
      if(constraint_param == "")
      begin
        `uvm_info("DYNAMICRANDOM", $sformatf("The parameter is not correctly set for %s, using the default [0:0xFFFFFFFF]", get_full_name()), UVM_FULL);
        constraint_param = "0:0xFFFFFFFF";
      end

      add_range_constraint(constraint_param);
    end

  endfunction: pre_randomize

  constraint range_weight
  {
    foreach(dist_choose[i])
      dist_choose[i] dist { 0:= max_weight-weights[i], 1:=weights[i]};
  }

  constraint one_active
  {
    sum_dist_choose[0] == dist_choose[0];
    foreach(dist_choose[current_index])
      current_index > 0 -> sum_dist_choose[current_index] == (sum_dist_choose[current_index-1]+dist_choose[current_index]);
    sum_dist_choose[range_index-1] == 1;
  }

  constraint choose_index
  {
    foreach(dist_choose[current_index])
      dist_choose[current_index] == 0 || index == current_index;
  }

  constraint in_range
  {
    foreach (ranges[current_index])
      index != current_index || value inside {[ranges[current_index].low:ranges[current_index].high]};
  }

  local function void add(int unsigned min, int unsigned max, int unsigned weight);
    range_limits range;
    range = new(min, max);
    ranges[range_index] = range;

    weights[range_index] = weight*(max-min+1);
    max_weight += weights[range_index];
    range_index ++;
  endfunction: add

endclass: uvm_dynamic_range_constraint

`endif //UVM_DYNAMIC_RANGE_CONSTRAINT_SV
