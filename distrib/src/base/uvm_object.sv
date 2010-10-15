//
//----------------------------------------------------------------------
//   Copyright 2007-2010 Mentor Graphics Corporation
//   Copyright 2007-2010 Cadence Design Systems, Inc.
//   Copyright 2010 Synopsys, Inc.
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

`include "base/uvm_object.svh"
typedef class uvm_component;


//----------------------------------------------------------------------------
//
// CLASS- uvm_object
//
//----------------------------------------------------------------------------


// new
// ---

function uvm_object::new (string name="");

  m_inst_id = m_inst_count++;
  m_leaf_name = name;
  m_field_automation (null, UVM_CHECK_FIELDS, "");
endfunction


// reseed
// ------

function void uvm_object::reseed ();
  if(use_uvm_seeding)
    this.srandom(uvm_create_random_seed(get_type_name(), get_full_name()));
endfunction


// get type
// --------

function uvm_object_wrapper uvm_object::get_type();
  uvm_report_error("NOTYPID", "get_type not implemented in derived class.", UVM_NONE);
  return null;
endfunction


// get inst_id
// -----------

function int uvm_object::get_inst_id();
  return m_inst_id;
endfunction


// get_object_type
// ---------------

function uvm_object_wrapper uvm_object::get_object_type();
  if(get_type_name() == "<unknown>") return null;
  return factory.find_by_name(get_type_name());
endfunction


// get inst_count
// --------------

function int uvm_object::get_inst_count();
  return m_inst_count;
endfunction


// get_name
// --------

function string uvm_object::get_name ();
  return m_leaf_name;
endfunction


// get_full_name
// -------------

function string uvm_object::get_full_name ();
  return get_name();
endfunction


// set_name
// --------

function void uvm_object::set_name (string name);
  m_leaf_name = name;
endfunction


// print 
// -----
 
function void uvm_object::print(uvm_printer printer=null);

  if(printer==null)
    printer = uvm_default_printer;

  if(printer.istop()) begin
    printer.print_object(get_name(), this);
  end
  else begin
    //do m_field_automation here so user doesn't need to call anything to get
    //automation.
    uvm_auto_options_object.printer = printer;
    m_field_automation(null, UVM_PRINT, "");
    //call user override
    do_print(printer);
  end
endfunction


// sprint
// ------

function string uvm_object::sprint(uvm_printer printer=null);
  bit p;

  if(printer==null)
    printer = uvm_default_printer;

  p = printer.knobs.sprint;
  printer.knobs.sprint = 1;

  print(printer);

  printer.knobs.sprint = p;  //revert back to regular printing
  return printer.m_string;
endfunction


// convert2string (virtual)
// --------------

function string uvm_object::convert2string();
  return "";
endfunction


// print_field_match (static)
// -----------------

function void uvm_object::print_field_match(string fnc, string match);
  string scratch;

  if(m_sc.save_last_field)
    m_sc.last_field = m_sc.get_full_scope_arg();

  if(print_matches) begin
    int style;
    scratch = {
      fnc, ": Matched string ", match, " to field ", m_sc.get_full_scope_arg()
    };
    uvm_report_info("STRMTC", scratch, UVM_LOW);
  end
endfunction

// set
// ---

function void  uvm_object::set_int_local (string      field_name,
                                          uvm_bitstream_t value,
                                          bit         recurse=1);
  if(m_sc.scope.in_hierarchy(this)) return;

  this.m_sc.status = 0;
  this.m_sc.bitstream = value;

  m_field_automation(null, UVM_SETINT, field_name);

  if(m_sc.warning && !this.m_sc.status) begin
    uvm_report_error("NOMTC", $psprintf("did not find a match for field %s", field_name),UVM_NONE);
  end

endfunction


// set_object_local
// ----------------

function void  uvm_object::set_object_local (string     field_name,
                                             uvm_object value,
                                             bit        clone=1,
                                             bit        recurse=1);
  uvm_object cc;
  if(m_sc.scope.in_hierarchy(this)) return;

  if(clone && (value!=null)) begin 
    cc = value.clone();
    if(cc != null) cc.set_name(field_name); 
    value = cc; 
  end 

  this.m_sc.status = 0;
  this.m_sc.object = value;
  uvm_auto_options_object.clone = clone;

  m_field_automation(null, UVM_SETOBJ, field_name);

  if(m_sc.warning && !this.m_sc.status) begin
    uvm_report_error("NOMTC", $psprintf("did not find a match for field %s", field_name), UVM_NONE);
  end

endfunction


// set_string_local
// ----------------
function void  uvm_object::set_string_local (string field_name,
                                             string value,
                                             bit    recurse=1);
  if(m_sc.scope.in_hierarchy(this)) return;
  this.m_sc.status = 0;
  this.m_sc.stringv = value;

  m_field_automation(null, UVM_SETSTR, field_name);

  if(m_sc.warning && !this.m_sc.status) begin
    uvm_report_error("NOMTC", $psprintf("did not find a match for field %s (@%0d)", field_name, this.get_inst_id()), UVM_NONE);
  end
endfunction


// m_do_set (static)
// ------------

// function m_do_set (match, arg, lhs, what, flag)
//   Precondition:
//     match     -- a match string to test against arg to do the set
//     arg       -- the name of the short name of the lhs object
//     lhs       -- the lhs to do on (left hand side)
//     what      -- integer, what to do
//     flag      -- object flags
//
//     uvm_object::m_sc.bitstream -- rhs object used for set/get
//     uvm_object::m_sc.status        -- return status for set/get calls
//


function int uvm_object::m_do_set (string match,
                                       string arg,
                                       inout uvm_bitstream_t lhs, 
                                       input int what,
                                       int flag);

  bit matched;

  if (what < UVM_START_FUNCS || what > UVM_END_FUNCS)
     return 0;

  matched = uvm_is_match(match, m_sc.scope.get_arg());

  case (what)
    UVM_SETINT:
      begin
        if(matched) begin
          if(flag &UVM_READONLY) begin
            uvm_report_warning("RDONLY", $psprintf("Readonly argument match %s is ignored", 
               m_sc.get_full_scope_arg()), UVM_NONE);
            return 0;
          end
          print_field_match("set_int()", match);
          lhs = uvm_object::m_sc.bitstream;
          uvm_object::m_sc.status = 1;
          return 1;
        end
      end
    default:
      begin
        if(matched) begin
          uvm_report_warning("MTCTYP", $psprintf("matched integral field %s, %s", 
          m_sc.get_full_scope_arg(),
          "but expected a non-integral type"), UVM_NONE);
        end
      end
  endcase
  return 0;
endfunction


// m_do_set_string (static)
// -------------------

// function m_do_set_string (match, arg, lhs, what, flag)
//   Precondition:
//     match     -- a match string to test against arg to do the set
//     arg       -- the name of the short name of the lhs object
//     lhs       -- the lhs to do get or set on (left hand side)
//     what      -- integer, what to do
//     flag      -- object flags
//
//     uvm_object::m_sc.stringv    -- rhs object used for set/get
//     uvm_object::m_sc.status        -- return status for set/get calls
//

function int uvm_object::m_do_set_string(string match,
                                             string arg,
                                             inout string lhs, 
                                             input int what,
                                             int flag);

  bit matched;
  string s;

  if (what < UVM_START_FUNCS || what > UVM_END_FUNCS)
     return 0;

  matched = uvm_is_match(match, m_sc.scope.get_arg());

  case (what)
    UVM_SETSTR:
      begin
        if(matched) begin
          if(flag &UVM_READONLY) begin
            uvm_report_warning("RDONLY", $psprintf("Readonly argument match %s is ignored", 
               m_sc.get_full_scope_arg()), UVM_NONE);
            return 0;
          end
          print_field_match("set_string()", match);
          lhs = uvm_object::m_sc.stringv;
          uvm_object::m_sc.status = 1;
          return 1;
        end
      end
    default:
      begin
        if(matched) begin
          uvm_report_warning("MTCTYP", $psprintf("matched string field %s, %s", 
          m_sc.get_full_scope_arg(),
          "but expected a non-string type"), UVM_NONE);
        end
      end
  endcase
  return 0;
endfunction


// m_do_set_object (static)
// -----------------

// function m_do_set_object (match, arg, lhsobj, what, flag)
//   Precondition:
//     match     -- a match string to test against arg to do the set
//     arg       -- the name of the short name of the lhs object
//     lhsobj    -- the object to do set_object on (left hand side)
//     what      -- integer, what to do
//     flag      -- object flags
//
//     uvm_object::m_sc.object -- rhs object used for set
//     uvm_object::m_sc.status     -- return status for set/get calls. set
//       always returns 0.
//
//   Postcondition:
//     Performs the set or get operation on an object. If the object doesn't
//     match then the object is recursed. The get* operations return true if
//     an index was returned. The set* always return 0.

function int uvm_object::m_do_set_object (string match,
                                            string arg,
                                            inout uvm_object lhsobj, 
                                            input int what,
                                                  int flag);

  bit matched;
  bit prev;
  int cnt;

  if (what < UVM_START_FUNCS || what > UVM_END_FUNCS)
     return 0;

  matched = uvm_is_match(match, m_sc.scope.get_arg());

  case (what)
    UVM_SETOBJ:
      begin
        if(matched) begin
          if(flag &UVM_READONLY) begin
            uvm_report_warning("RDONLY", $psprintf("Readonly argument match %s is ignored", 
               m_sc.get_full_scope_arg()), UVM_NONE);
            return 0;
          end
          print_field_match("set_object()", match);
          lhsobj = uvm_object::m_sc.object;
          uvm_object::m_sc.status = 1;
        end
        else if(lhsobj==null) return 0;
        if(flag &UVM_READONLY) 
          return 0; 
        //Only traverse if there is a possible match.
        for(cnt=0; cnt<match.len(); ++cnt) begin
          if(match[cnt] == "." || match[cnt] == "*") break;
        end
        if(cnt!=match.len())
          lhsobj.m_field_automation(null, UVM_SETOBJ, match);
        return uvm_object::m_sc.status;
      end
  endcase

  if(matched) begin
    uvm_report_warning("MTCTYP", $psprintf("matched object field %s, %s", 
          m_sc.get_full_scope_arg(),
          "but expected a non-object type"), UVM_NONE);
  end
  if(lhsobj==null) return 0;
  lhsobj.m_field_automation(null, what, match);

  return uvm_object::m_sc.status;

endfunction

// clone
// -----

function uvm_object uvm_object::clone();
  uvm_object tmp;
  tmp = this.create(get_name());
  if(tmp == null) begin
//    uvm_report_warning("CRFLD", $psprintf("The create method failed for %s,  object will be copied using shallow copy", get_name()));
//    tmp = new this;
    uvm_report_warning("CRFLD", $psprintf("The create method failed for %s,  object cannot be cloned", get_name()), UVM_NONE);
  end
  else begin
    tmp.copy(this);
  end

  return(tmp);
endfunction


// copy
// ----

uvm_copy_map uvm_global_copy_map = new;
function void uvm_object::copy (uvm_object rhs);
  //For cycle checking
  static int depth;
  if((rhs !=null)  && (uvm_global_copy_map.get(rhs) != null)) begin
    return;
  end

  if(rhs==null) begin
    uvm_report_warning("NULLCP", "A null object was supplied to copy; copy is ignored", UVM_NONE);
    return;
  end

  uvm_global_copy_map.set(rhs, this); 
  ++depth;

  do_copy(rhs);
  m_field_automation(rhs, UVM_COPY, "");

  --depth;
  if(depth==0) begin
    uvm_global_copy_map.clear();
  end
endfunction


// do_copy
// -------

function void uvm_object::do_copy (uvm_object rhs);
  return;
endfunction


// init_status
// -----------

function uvm_status_container uvm_object::init_status();
  if(m_sc==null) m_sc=new;
  return m_sc;
endfunction


// compare
// -------

function bit  uvm_object::compare (uvm_object rhs,
                                   uvm_comparer comparer=null);
  bit t, dc;
  static int style;
  bit done;
  done = 0;
  if(comparer != null) 
    uvm_auto_options_object.comparer = comparer;
  else 
    uvm_auto_options_object.comparer = uvm_default_comparer;
  comparer = uvm_auto_options_object.comparer;

  if(!m_sc.scope.depth()) begin
    comparer.compare_map.clear();
    comparer.result = 0;
    comparer.miscompares = "";
    comparer.scope = m_sc.scope;
    if(get_name() == "") begin
      m_sc.scope.down("<object>", this);
    end
    else
      m_sc.scope.down(this.get_name(), this);
  end
  if(!done && (rhs == null)) begin
    if(m_sc.scope.depth()) begin
      comparer.print_msg_object(this, rhs);
    end
    else begin
      comparer.print_msg_object(this, rhs);
      uvm_report_info("MISCMP",
           $psprintf("%0d Miscompare(s) for object %s@%0d vs. @%0d", 
           comparer.result, get_name(), this.get_inst_id(), rhs.get_inst_id()), uvm_auto_options_object.comparer.verbosity);
      done = 1;
    end
  end

  if(!done && (comparer.compare_map.get(rhs) != null)) begin
    if(comparer.compare_map.get(rhs) != this) begin
      comparer.print_msg_object(this, comparer.compare_map.get(rhs));
    end 
    done = 1;  //don't do any more work after this case, but do cleanup
  end

  if(!done && comparer.check_type && get_type_name() != rhs.get_type_name()) begin
    m_sc.stringv = { "lhs type = \"", get_type_name(), 
                     "\" : rhs type = \"", rhs.get_type_name(), "\""};
    comparer.print_msg(m_sc.stringv);
  end

  if(!done) begin
    comparer.compare_map.set(rhs, this);
    m_field_automation(rhs, UVM_COMPARE, "");
    dc = do_compare(rhs, comparer);
  end

  if(m_sc.scope.depth() == 1)  begin
    m_sc.scope.up(this);
  end

  comparer.print_rollup(this, rhs);
  return (comparer.result == 0 && dc == 1);
endfunction


// do_compare
// ----------

function bit  uvm_object::do_compare (uvm_object rhs,
                                      uvm_comparer comparer);
  return 1;
endfunction


// m_field_automation
// --------------

function void uvm_object::m_field_automation ( uvm_object tmp_data__,
                                             int        what__,
                                             string     str__ );
  return;
endfunction


// check_fields
// ------------

function void uvm_object::m_do_field_check(string field);
  if(m_field_array.exists(field) && (m_field_array[field] == 1)) begin
    uvm_report_error("MLTFLD", $psprintf("Field %s is defined multiple times in type %s",
       field, get_type_name()), UVM_NONE);
  end
  m_field_array[field]++; 
endfunction

function void uvm_object::m_delete_field_array();
  m_field_array.delete();
endfunction

// do_print (virtual override)
// ------------

function void uvm_object::do_print(uvm_printer printer);
  return;
endfunction


// m_pack
// ------

function void uvm_object::m_pack (inout uvm_packer packer);

  if(packer!=null) 
    uvm_auto_options_object.packer = packer;
  else  
    uvm_auto_options_object.packer = uvm_default_packer;
  packer = uvm_auto_options_object.packer;

  packer.reset();
  packer.scope.down(get_name(), this);

  m_field_automation(null, UVM_PACK, "");
  do_pack(packer);

  packer.set_packed_size();

  packer.scope.up(this); 

endfunction
  

// pack
// ---- 
  
function int uvm_object::pack (ref bit bitstream [],
                               input uvm_packer packer =null );
  m_pack(packer);
  packer.get_bits(bitstream);
  return packer.get_packed_size();
endfunction

// pack_bytes
// ----------

function int uvm_object::pack_bytes (ref byte unsigned bytestream [],
                                     input uvm_packer packer=null );
  m_pack(packer);
  packer.get_bytes(bytestream);
  return packer.get_packed_size();
endfunction


// pack_ints
// ---------

function int uvm_object::pack_ints (ref int unsigned intstream [],
                                    input uvm_packer packer=null );
  m_pack(packer);
  packer.get_ints(intstream);
  return packer.get_packed_size();
endfunction


// do_pack
// -------

function void uvm_object::do_pack (uvm_packer packer );
  return;
endfunction


// m_unpack_pre
// ------------
  
function void uvm_object::m_unpack_pre (inout uvm_packer packer);
  if(packer!=null)
    uvm_auto_options_object.packer = packer;
  else
    uvm_auto_options_object.packer = uvm_default_packer;
  packer = uvm_auto_options_object.packer;
  packer.reset();
endfunction
  

// m_unpack_post
// -------------

function void uvm_object::m_unpack_post (uvm_packer packer);

  int provided_size; 

  provided_size = packer.get_packed_size();

  //Put this object into the hierarchy
  packer.scope.down(get_name(), this);

  m_field_automation(null, UVM_UNPACK, "");

  do_unpack(packer);

  //Scope back up before leaving
  packer.scope.up(this);

  if(packer.get_packed_size() != provided_size) begin
    uvm_report_warning("BDUNPK", $psprintf("Unpack operation unsuccessful: unpacked %0d bits from a total of %0d bits", packer.get_packed_size(), provided_size), UVM_NONE);
  end

endfunction


// unpack
// ------

function int uvm_object::unpack (ref    bit        bitstream [],
                                 input  uvm_packer packer=null);
  m_unpack_pre(packer);
  packer.put_bits(bitstream);
  m_unpack_post(packer);
  packer.set_packed_size();
  return packer.get_packed_size();
endfunction


// unpack_bytes
// ------------

function int uvm_object::unpack_bytes (ref    byte unsigned bytestream [],
                                       input  uvm_packer packer=null);
  m_unpack_pre(packer);
  packer.put_bytes(bytestream);
  m_unpack_post(packer);
  packer.set_packed_size();
  return packer.get_packed_size();
endfunction


// unpack_ints
// -----------
  
function int uvm_object::unpack_ints (ref    int unsigned intstream [],
                                      input  uvm_packer packer=null);
  m_unpack_pre(packer);
  packer.put_ints(intstream);
  m_unpack_post(packer);
  packer.set_packed_size();
  return packer.get_packed_size();
endfunction


// do_unpack
// ---------

function void uvm_object::do_unpack (uvm_packer packer);
  return;
endfunction


// record
// ------

function void uvm_object::record (uvm_recorder recorder=null);
//mxg  if(!recorder) 
  if(recorder == null) 
    recorder = uvm_default_recorder;

  if(!recorder.tr_handle) return;

  uvm_auto_options_object.recorder = recorder;
  recorder.recording_depth++;
  m_field_automation(null, UVM_RECORD, "");
  do_record(recorder);

  recorder.recording_depth--;

  if(recorder.recording_depth==0) begin
    recorder.tr_handle = 0;
  end
endfunction


// do_record (virtual)
// ---------

function void uvm_object::do_record (uvm_recorder recorder);
  return;
endfunction


// m_get_function_type (static)
// -------------------

function string uvm_object::m_get_function_type (int what);
  case (what)
    UVM_COPY:              return "copy";
    UVM_COMPARE:           return "compare";
    UVM_PRINT:             return "print";
    UVM_RECORD:            return "record";
    UVM_PACK:              return "pack";
    UVM_UNPACK:            return "unpack";
    UVM_FLAGS:             return "get_flags";
    UVM_SETINT:            return "set";
    UVM_SETOBJ:            return "set_object";
    UVM_SETSTR:            return "set_string";
    default:           return "unknown";
  endcase
endfunction


// m_get_report_object
// -------------------

function uvm_report_object uvm_object::m_get_report_object();
  return null;
endfunction


// m_record_field_object (static)
// ---------------------

function void uvm_object::m_record_field_object (string arg,
                                               uvm_object value,
                                               uvm_recorder recorder =null,
                                               int flag = UVM_DEFAULT);
  begin
    if(recorder == null)
      recorder=uvm_auto_options_object.recorder;

    if((flag&UVM_NORECORD) != 0) return;

    recorder.record_object(arg, value);

  end
endfunction


// m_do_data (static)
// ---------

// function m_do_data (arg, lhs, rhs, what, flag)
//   Precondition:
//     arg       -- the name of the short name of the lhs object
//     lhs       -- the lhs to do work on (left hand side)
//     lhs       -- the rhs to do work from (right hand side)
//     what      -- integer, what to do
//     flag      -- object flags

function int uvm_object::m_do_data (string arg,
                                  inout uvm_bitstream_t lhs,
                                  input uvm_bitstream_t rhs,
                                        int what,
                                        int bits,
                                        int flag);


  if (what > UVM_END_DATA_EXTRA)
     return 0;
  if(bits > UVM_STREAMBITS) begin
    uvm_report_error("FLDTNC",$psprintf("%s is %0d bits; maximum field size is %0d, truncating",
                 arg, bits, UVM_STREAMBITS), UVM_NONE);
  end
  case (what)
    UVM_COPY:
      begin
        if(((flag)&UVM_NOCOPY) == 0) begin
          uvm_bitstream_t mask;
          mask = -1;
          mask >>= (UVM_STREAMBITS-bits);
          lhs = rhs & mask;
        end
        return 0;
      end
    UVM_COMPARE:
      begin
        if(((flag)&UVM_NOCOMPARE) == 0) begin
          bit r;
          if(bits <= 64)
            r = uvm_auto_options_object.comparer.compare_field_int(arg, lhs, rhs, bits, uvm_radix_enum'(flag&UVM_RADIX));
          else
            r = uvm_auto_options_object.comparer.compare_field(arg, lhs, rhs, bits, uvm_radix_enum'(flag&UVM_RADIX));
        end
        return 0;
      end
    UVM_PACK:
      begin
        if(((flag)&UVM_NOPACK) == 0) begin
          if(((flag&UVM_ABSTRACT) && uvm_auto_options_object.packer.abstract) ||
             (!(flag&UVM_ABSTRACT) && uvm_auto_options_object.packer.physical)) begin
            if(bits<=64)
              uvm_auto_options_object.packer.pack_field_int(lhs, bits);
            else
              uvm_auto_options_object.packer.pack_field(lhs, bits);
          end
        end
        return 0;
      end
    UVM_UNPACK:
      begin
        if(((flag)&UVM_NOPACK) == 0) begin
          if(((flag&UVM_ABSTRACT) && uvm_auto_options_object.packer.abstract) ||
             (!(flag&UVM_ABSTRACT) && uvm_auto_options_object.packer.physical)) begin
            if(bits<=64)
              lhs=uvm_auto_options_object.packer.unpack_field_int(bits);
            else
              lhs=uvm_auto_options_object.packer.unpack_field(bits);
          end
        end
        return 0;
      end
    UVM_PRINT:
      begin
        if(((flag)&UVM_NOPRINT) == 0) 
        begin  
          uvm_printer printer; 
          uvm_radix_enum radix;
          radix = uvm_radix_enum'(flag&UVM_RADIX);
          printer = uvm_auto_options_object.printer; 
          printer.print_field(arg, lhs, bits, radix);
        end
      end
    UVM_RECORD:
      begin
        if(((flag)&UVM_NORECORD) == 0) 
        begin 
          integer h;
          uvm_radix_enum radix;

          radix = uvm_radix_enum'(flag&UVM_RADIX);
          uvm_auto_options_object.recorder.record_field(arg, lhs, bits, radix);
        end 
      end
  endcase
  return 0;
endfunction


// m_do_data_real (static)
// --------------

// function m_do_data_real (arg, lhs, rhs, what, flag)
//   Precondition:
//     arg       -- the name of the short name of the lhs object
//     lhs       -- the lhs to do work on (left hand side)
//     lhs       -- the rhs to do work from (right hand side)
//     what      -- integer, what to do
//     flag      -- object flags

function int uvm_object::m_do_data_real (string arg,
                                  inout real lhs,
                                  input real rhs,
                                        int what,
                                        int flag);


  if (what > UVM_END_DATA_EXTRA)
     return 0;
  case (what)
    UVM_COPY:
      begin
        if(((flag)&UVM_NOCOPY) == 0) begin
          lhs = rhs;
        end
        return 0;
      end
    UVM_COMPARE:
      begin
        if(((flag)&UVM_NOCOMPARE) == 0) begin
          bit r;
          r = uvm_auto_options_object.comparer.compare_field_real(arg, lhs, rhs);
        end
        return 0;
      end
    UVM_PACK:
      begin
        if(((flag)&UVM_NOPACK) == 0) begin
          if(((flag&UVM_ABSTRACT) && uvm_auto_options_object.packer.abstract) ||
             (!(flag&UVM_ABSTRACT) && uvm_auto_options_object.packer.physical)) begin
            uvm_auto_options_object.packer.pack_field_int($realtobits(lhs), 64);
          end
        end
        return 0;
      end
    UVM_UNPACK:
      begin
        if(((flag)&UVM_NOPACK) == 0) begin
          if(((flag&UVM_ABSTRACT) && uvm_auto_options_object.packer.abstract) ||
             (!(flag&UVM_ABSTRACT) && uvm_auto_options_object.packer.physical)) begin
            lhs=$bitstoreal(uvm_auto_options_object.packer.unpack_field_int(64));
          end
        end
        return 0;
      end
    UVM_PRINT:
      begin
        if(((flag)&UVM_NOPRINT) == 0) 
        begin  
          uvm_printer printer; 
          printer = uvm_auto_options_object.printer; 
          printer.print_field_real(arg, lhs);
        end
      end
    UVM_RECORD:
      begin
        if(((flag)&UVM_NORECORD) == 0) 
        begin 
          uvm_auto_options_object.recorder.record_field_real(arg, lhs);
        end 
      end
  endcase
  return 0;
endfunction


// m_do_data_object (static)
// ----------------

// function m_do_data_object (arg, lhs, rhs, what, flag)
//   Precondition:
//     arg       -- the name of the short name of the lhs object
//     lhs       -- the lhs to do work on (left hand side)
//     lhs       -- the rhs to do work from (right hand side)
//     what      -- integer, what to do
//     flag      -- object flags

function int uvm_object::m_do_data_object (string arg,
                                       inout uvm_object lhs,
                                       input uvm_object rhs,
                                             int what,
                                             int flag);

  uvm_object lhs_obj;

  if (what > UVM_END_DATA_EXTRA)
     return 0;

  case (what)
    UVM_COPY:
      begin
        int rval;
        if(((flag)&UVM_NOCOPY) != 0) begin
          return 0;
        end
        if(rhs == null) begin
          lhs = null;
          return UVM_REFERENCE;
        end

        if(flag & UVM_SHALLOW) begin
          rval = UVM_SHALLOW;
        end
        else if(flag & UVM_REFERENCE) begin
          lhs = rhs;
          rval = UVM_REFERENCE;
        end
        else  //deepcopy
        begin
          uvm_object v;
          v = uvm_global_copy_map.get(rhs);
          if(v != null) begin
            lhs = v;
            rval = UVM_REFERENCE;
          end
          else if(lhs==null) begin
            lhs = rhs.clone();
            lhs.set_name(arg);
            rval = UVM_REFERENCE;
          end
          else if(rhs == null) begin
            rval = UVM_REFERENCE;
          end
          else begin
            //lhs doesn't change for this case, so don't need to copy back
            lhs.copy(rhs);
             rval = 0;
          end
        end
        return rval;
      end
    UVM_COMPARE:
      begin
        bit refcmp;

        if(((flag)&UVM_NOCOMPARE) != 0) begin
          return 0;
        end

        //if the object are the same then don't need to do a deep compare
        if(rhs == lhs) return 0;

        refcmp = (flag & UVM_SHALLOW) && !(uvm_auto_options_object.comparer.policy == UVM_DEEP);

        //do a deep compare here 
        if(!refcmp && !(uvm_auto_options_object.comparer.policy == UVM_REFERENCE))
        begin
          if(((rhs == null) && (lhs != null)) || ((lhs==null) && (rhs!=null))) begin
            uvm_auto_options_object.comparer.print_msg_object(lhs, rhs);
            return 1;  //miscompare
          end
          if((rhs == null) && (lhs==null))
            return 0;
          else begin
            bit r;
            r = lhs.compare(rhs, uvm_auto_options_object.comparer);
            if(r == 0) begin
              return 1;
            end
            else begin
              return 0;
            end
          end
        end
        else begin //reference compare
          if(lhs != rhs) begin
            uvm_auto_options_object.comparer.print_msg_object(lhs, rhs);
            return 1;
          end
        end
      end
    UVM_PACK:
      begin
        if(((flag&UVM_NOPACK) == 0) && ((flag&UVM_REFERENCE)==0)) begin
          if(((flag&UVM_ABSTRACT) && uvm_auto_options_object.packer.abstract) ||
             (!(flag&UVM_ABSTRACT) && uvm_auto_options_object.packer.physical)) begin
            uvm_auto_options_object.packer.pack_object(lhs);
          end
        end
        return 0;
      end
    UVM_UNPACK:
      begin
        if(((flag&UVM_NOPACK) == 0) && ((flag&UVM_REFERENCE)==0)) begin
          if(((flag&UVM_ABSTRACT) && uvm_auto_options_object.packer.abstract) ||
             (!(flag&UVM_ABSTRACT) && uvm_auto_options_object.packer.physical)) begin
          uvm_auto_options_object.packer.unpack_object_ext(lhs);
          end
        end
        return 0;
      end
    UVM_PRINT:
      begin
        if(((flag)&UVM_NOPRINT) == 0) 
        begin  
          if(((flag)&UVM_REFERENCE) || (lhs == null)) begin
            int d;
            d = uvm_auto_options_object.printer.knobs.depth;
            uvm_auto_options_object.printer.knobs.depth = 0;
            uvm_auto_options_object.printer.print_object(arg, lhs);
            uvm_auto_options_object.printer.knobs.depth = d;
          end
          else begin
            uvm_component obj;
            if(lhs != null) begin
              if($cast(obj,lhs)) begin 
                if(uvm_auto_options_object.printer.m_scope.current() == obj.get_parent() )
                  uvm_auto_options_object.printer.print_object(arg, lhs);
                else
                  uvm_auto_options_object.printer.print_object_header(arg, lhs);
              end
              else begin
                uvm_auto_options_object.printer.print_object(arg, lhs);
              end
            end
          end
        end
      end
    UVM_RECORD:
      begin
        if(((flag)&UVM_NORECORD) == 0) 
        begin 
          m_sc.scope.up(lhs); //need to scope up since gets scoped down before
          if(lhs != null && lhs.get_name()!="") arg = lhs.get_name(); 
          //If refernce is on then don't want to do cycle check since only
          //recording the reference.
          if( ((flag) & int'(UVM_REFERENCE)) != 0) 
            m_record_field_object(arg, lhs, uvm_auto_options_object.recorder,flag);
          else begin
            if(!m_sc.scope.in_hierarchy(lhs)) 
              m_record_field_object(arg, lhs, uvm_auto_options_object.recorder,flag);
          end
          m_sc.scope.down(arg,lhs); //need to scope back dwon
        end 
      end
  endcase
  return 0;
endfunction


// m_do_data_string (static)
// ----------------

// function m_do_data_string (arg, lhs, rhs, what, flag)
//   Precondition:
//     arg       -- the name of the short name of the lhs object
//     lhs       -- the lhs to do work on (left hand side)
//     lhs       -- the rhs to do work from (right hand side)
//     what      -- integer, what to do
//     flag      -- object flags
//

function int uvm_object::m_do_data_string(string arg,
                                      inout string lhs,
                                      input string rhs,
                                            int what,
                                            int flag);

  if (what > UVM_END_DATA_EXTRA)
     return 0;

  case (what)
    UVM_COPY:
      begin
        if(((flag)&UVM_NOCOPY) == 0) begin
          lhs = rhs;
        end
        return 0;
      end
    UVM_COMPARE:
      begin
        if(((flag)&UVM_NOCOMPARE) == 0) begin
          if(lhs != rhs) begin
            m_sc.stringv = { "lhs = \"", lhs, "\" : rhs = \"", rhs, "\""};
            uvm_auto_options_object.comparer.print_msg(m_sc.stringv);
            return 1;
          end
        end
        return 0;
      end
    UVM_PACK:
      begin 
        if(((flag)&UVM_NOPACK) == 0) begin
          if(((flag&UVM_ABSTRACT) && uvm_auto_options_object.packer.abstract) ||
             (!(flag&UVM_ABSTRACT) && uvm_auto_options_object.packer.physical)) begin
          uvm_auto_options_object.packer.pack_string(lhs);
          end
        end
        return 0;
      end
    UVM_UNPACK:
      begin
        if(((flag)&UVM_NOPACK) == 0) begin
          if(((flag&UVM_ABSTRACT) && uvm_auto_options_object.packer.abstract) ||
             (!(flag&UVM_ABSTRACT) && uvm_auto_options_object.packer.physical)) begin
          lhs = uvm_auto_options_object.packer.unpack_string();
          end
        end
        return 0;
      end
    UVM_PRINT:
      begin
        if(((flag)&UVM_NOPRINT) == 0) 
        begin  
          uvm_auto_options_object.printer.print_string(arg, lhs);
        end
      end
    UVM_RECORD:
      begin
        if(((flag)&UVM_NORECORD) == 0) 
        begin 
          m_sc.scope.up(null); //need to scope up since gets scoped down before
          uvm_auto_options_object.recorder.record_string(arg, lhs);
          m_sc.scope.down(arg,null); //need to scope back dwon
        end 
      end
  endcase
  return 0;

endfunction


//-----------------------------------------------------------------------------
//
// uvm_status_container
//
//-----------------------------------------------------------------------------

function string uvm_status_container::get_full_scope_arg ();
  get_full_scope_arg = scope.get_arg();
endfunction

function uvm_scope_stack uvm_status_container::init_scope();
  if(scope==null) scope=new;
  return scope;
endfunction

//-----------------------------------------------------------------------------
//
// uvm_options_container
//
//-----------------------------------------------------------------------------

uvm_options_container uvm_auto_options_object = uvm_options_container::init();

function uvm_options_container::new();
  comparer = uvm_default_comparer;
  packer   = uvm_default_packer;
  recorder = uvm_default_recorder;
  printer  = uvm_default_printer;
endfunction

function uvm_options_container uvm_options_container::init();
  if(uvm_auto_options_object==null) uvm_auto_options_object=new;
  return uvm_auto_options_object;
endfunction

