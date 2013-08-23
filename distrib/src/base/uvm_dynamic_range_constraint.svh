`ifndef UVM_DYNAMIC_RANGE_CONSTRAINT_SV
`define UVM_DYNAMIC_RANGE_CONSTRAINT_SV

class range_limits;
  int unsigned low;
  int unsigned high;

  function new(int unsigned l, int unsigned h);
    low = l;
    high = h;
  endfunction: new
endclass: range_limits

class uvm_dynamic_range_constraint_parser;
  //split the string parm to integers with delimiter ":"
  static function void split_param_to_integer(string param, output int unsigned values[$]);
    string str_values[$];
    //fisrt split the param into strings
    split_param_to_string(param, str_values);
    //then convert the string into integers
    foreach(str_values[i])
      str_2_uint(str_values[i], values[i]);
  endfunction: split_param_to_integer
  
  //split the string parm to sub strings with delimiter ":"
  static function void split_param_to_string(string param, output string single_values[$]);
    byte c;
    string value = "";
    for(int i = 0; i < param.len(); i ++ )
    begin
      c = param.getc(i);
      if(c != ":")
        value = {value, string'(c)};
      else
      begin
        single_values.push_back(value);
        value = "";
      end
    end
    single_values.push_back(value);
  endfunction : split_param_to_string

  //change the str into integer
  static function void str_2_uint(string str, output int unsigned data);
    string str_format;
    str = str.tolower();
    if(str.getc(0) == "0")
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
       //   default to interpreting the entire string as decimal.
       str_format = "%d";
    endcase
    else
      // There was no leading zero character, so default to interpreting the
      //   entire string as decimal.
      str_format = "%d";
    if(!$sscanf(str, str_format, data))
       uvm_report_warning("DYNAMICRANDOM",{str, " could not be interped into integer"}); 
  endfunction: str_2_uint
  
endclass: uvm_dynamic_range_constraint_parser

class uvm_dynamic_range_constraint #(string NAME="") extends uvm_object;
  typedef uvm_dynamic_range_constraint #(NAME) this_type;

  //Singleton
  static local this_type m_inst;

  static function this_type get_inst();
    if(m_inst == null)
      m_inst = new();
    return m_inst;
  endfunction

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
    int index = 0;
    int unsigned low;
    int arg_count = clp.get_arg_values({"+",NAME}, params);
    if(arg_count == 0)
      return;
    
    if(!$sscanf(params[0], "=%s", constraint_param))
    begin
      uvm_report_warning("DYNAMICRANDOM", 
                          $sformatf("the format of the %s parameter is wrong", NAME));
      return;
    end
    if(arg_count > 1)
    begin
      string max_constraint_param = params[0];
      for(int i = 1; i < params.size(); i ++)
        max_constraint_param = {max_constraint_param, ", ", params[i]};
      uvm_report_warning("DYNAMICRANDOM", 
                         $sformatf("Multiple (%0d) %s arguments provided on the command line.  '%s' will be used.  Provided list: %s.", 
                                    arg_count, NAME, params[0], max_constraint_param), UVM_NONE);
    end
    else
      uvm_report_info("DYNAMICRANDOM",
                      $sformatf("'%s=%s' provided on the command line is being applied.", NAME, params[0]), UVM_NONE);
    
    uvm_dynamic_range_constraint_parser::split_param_to_integer(constraint_param, values);
    if(values.size()!= 1 && values.size() != 2 && (values.size() % 3) != 0)
       uvm_report_warning("DYNAMICRANDOM", 
                          $sformatf("the size of the %s parameter is %0d", NAME, values.size()));
   
    //after parse the parameter add the constraint
    while(index + 3 <= values.size())
    begin
      add(values[index], values[index+1], values[index+2]);
      index += 3;
    end
    if(index + 2 == values.size())
      add(values[index], values[index+1], 1);
    else if(index + 1 == values.size())
      add(values[index], values[index], 1);
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
