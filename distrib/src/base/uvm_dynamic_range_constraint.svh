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

virtual class uvm_dynamic_range_constraint_parser extends uvm_object;

  function new(string name = "");
    super.new(name);
  endfunction: new

  //parse the range constraint with the provided name from command line
  //split the constraint into triplet
  pure virtual function void get_range_constraint(string param_name, output int unsigned values[]);

  // Split the string parm to integers.  ";" is used as a delimiter to seperate triplets
  // And then ":" is used to deliminate the actual triplet values.
  // Example: "1:2:3;4:5:6"
  //  Becomes: "1:2:3", "4:5:6"
  //  Which then becomes 1,2,3,4,5,6
  static function void split_param_to_integer(string param, output int unsigned values[]);
    string str_values_triplet[$];
    string str_values[];

    // First split the param into strings using ";" as a delimiter
    uvm_split_string(param, ";", str_values_triplet);
    str_values = new [str_values_triplet.size()*3];
    values = new[str_values.size()];

    foreach(str_values_triplet[index])
    begin
      string str_values_tmp[$];
      uvm_split_string(str_values_triplet[index], ":", str_values_tmp);
      case(str_values_tmp.size())
        3: begin
             foreach(str_values_tmp[index_tmp])
               str_values[index*3+index_tmp] = str_values_tmp[index_tmp];
           end
        2: begin
               str_values[index*3+0] = str_values_tmp[0];
               str_values[index*3+1] = str_values_tmp[1];
               str_values[index*3+2] = "1";
           end
        1: begin
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

class uvm_cmdline_dynamic_range_constraint_parser extends uvm_dynamic_range_constraint_parser;

  function new(string name = "");
    super.new(name);
  endfunction: new

  //parse the range constraint with the provided name from command line
  //split the constraint into triplet
  virtual function void get_range_constraint(string param_name, output int unsigned values[]);
    uvm_cmdline_processor clp = uvm_cmdline_processor::get_inst();
    string params[$];
    string constraint_param;
    int arg_count = clp.get_arg_values({"+",param_name}, params);

    if (arg_count == 0)
       return;
    
    if (params[0].getc(0) != "=")
    begin
      `uvm_fatal("DYNAMICRANDOM", 
                          $sformatf("the format of the %s parameter is wrong", param_name));
      return;
    end
    else
       constraint_param = params[0].substr(1, params[0].len()-1);

    if (arg_count > 1)
    begin
      string max_constraint_param = params[0];
      for(int unsigned lindex = 1; lindex < params.size(); ++lindex)
        max_constraint_param = {max_constraint_param, ", ", params[lindex]};
      `uvm_warning("DYNAMICRANDOM", 
                         $sformatf("Multiple (%0d) %s arguments provided on the command line.  '%s' will be used.  Provided list: %s.", 
                                    arg_count, param_name, params[0], max_constraint_param))
    end
    
    uvm_dynamic_range_constraint_parser::split_param_to_integer(constraint_param, values);
  endfunction: get_range_constraint
endclass: uvm_cmdline_dynamic_range_constraint_parser


//class uvm_dynamic_range_constraint #(string NAME="") extends uvm_object;
class uvm_dynamic_range_constraint extends uvm_object;

//  typedef uvm_dynamic_range_constraint #(NAME) this_type;

  //Singleton
//  static local this_type m_inst;

  static local int unsigned m_values[string][];
  
  local string param_name;
  local int unsigned constraint_set = 0;
  local range_limits ranges[];
  local range_limits weights[];
  local int unsigned max_weight = 0;
  local int unsigned range_index = 0;
  rand int unsigned weight_value;
  rand int unsigned value;
  rand int unsigned index;

  `uvm_object_utils_begin(uvm_dynamic_range_constraint)
    `uvm_field_string(param_name, UVM_DEFAULT)
  `uvm_object_utils_end


//  static function this_type get_inst();
//    if (m_inst == null)
//       m_inst = new();
//    return m_inst;
//  endfunction: get_inst
//
//  static function int unsigned get_rand_value();
//    this_type inst = this_type::get_inst();
//    void'(inst.randomize());
//    return inst.value;
//  endfunction: get_rand_value

  function new(string name = "");

    super.new(name);
    
//    parser.get_range_constraint(NAME, values);
  endfunction: new

  function void pre_randomize();
    int unsigned values[];
    int unsigned index = 0;

    super.pre_randomize();

    if( constraint_set == 0)
    begin
      uvm_cmdline_dynamic_range_constraint_parser parser = new();
      constraint_set = 1; //set only once
      //check configuration first
      if (!uvm_config_db#(string)::get(null, get_full_name(), 
                                       "param_name", param_name)
        || param_name == "")
        param_name = get_name(); //using the object name by default

      if(param_name == "")
        `uvm_fatal("DYNAMICRANDOM", "The parameter cannot be empty");

      if(!m_values.exists(param_name))
        parser.get_range_constraint(param_name, m_values[param_name]);
  
      //after parse the parameter add the constraint
      ranges = new[m_values[param_name].size()/3];
      weights = new[m_values[param_name].size()/3];
      range_index = 0;
      while(index + 3 <= m_values[param_name].size())
      begin
        add(m_values[param_name][index], m_values[param_name][index+1], m_values[param_name][index+2]);
        index += 3;
      end
    end
  endfunction: pre_randomize

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

    range = new(min, max);
    ranges[range_index] = range;

    weight_range = new(max_weight, max_weight+weight*(max-min+1)-1);
    weights[range_index] = weight_range;
    range_index ++;
    max_weight += weight*(max-min+1);
  endfunction: add

endclass: uvm_dynamic_range_constraint

`endif //UVM_DYNAMIC_RANGE_CONSTRAINT_SV
