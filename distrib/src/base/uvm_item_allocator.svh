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

`ifndef UVM_ITEM_ALLOCATOR__SVH
`define UVM_ITEM_ALLOCATOR__SVH


//------------------------------------------------------------------------------
//
// CLASS: uvm_converter #(T,I)
//
//------------------------------------------------------------------------------
// A base class for conversion between object representation and integral representation.
// This class is virtual and its virtual functions are not implemented.
// They need to be implemented by derived classes.
//------------------------------------------------------------------------------
virtual class uvm_converter#(type T = int, type I = int);
  // Function: serialize
  //
  // Returns integral representation for the given object representation
  virtual  function I serialize(T object);
  endfunction: serialize

  // Function: deserialize
  //
  // Returns object representation for the given integral representation
  virtual function T deserialize(I item);
  endfunction: deserialize
endclass: uvm_converter

//------------------------------------------------------------------------------
//
// CLASS: uvm_simple_converter #(I)
//
//------------------------------------------------------------------------------
// A sample implementation of uvm_converter when object representation is equal to
// integral representation.
//------------------------------------------------------------------------------
class uvm_simple_converter#(type I = int) extends uvm_converter#(I,I);
  // Function: serialize
  //
  // Returns integral representation for the given object representation
  virtual function I serialize(I object);
    return object;
  endfunction: serialize

  // Function: deserialize
  //
  // Returns object representation for the given integral representation
  virtual function I deserialize(I item);
    return item;
  endfunction: deserialize
endclass: uvm_simple_converter


//------------------------------------------------------------------------------
//
// CLASS: uvm_item_alloc_policy #(T,I)
//
//------------------------------------------------------------------------------
// A base class for allocation policy.
// An instance of this class is randomized to obtain an allocated item.
// Constraint which does not allow to allocate taken items it provided
// in this class.
// This class can be extended to provide additional constraints
// on the allocated item, as validy constraint, since the range of valid items
// is unknown in the generic base class.
//------------------------------------------------------------------------------

class uvm_item_alloc_policy #(type T=longint unsigned, type I=longint unsigned);
  // Parameter: T
  //
  // Specifies the type for object representation of allocated item.
  //

  // Parameter: I
  //
  // Specifies the integral type used for randomization
  //

  uvm_converter#(T,I) converter;

  function new();  
  endfunction: new

  // Variable: item
  //
  // item is the random member of this class
  // random allocation is done by providing a value to this member.
  // 
  rand I item;

  
  // Variable: object
  //
  // Object representation of allocated item
  // Set in post_randomize();
  //
  T object;
  
  // Variable: in_use
  //
  // Stores  all items previously allocated and not released (integral representation)
  //
  I in_use[$];

  // Constraint: not_taken
  //
  // makes sure previously allocated items can not be selected in new allocation
  constraint not_taken
  {
    foreach (in_use[i])
    item != in_use[i];
  }

  // A validity constraint (if needed) should be added in the derived
  // classes as we do not know the list/range of valid items

  // Function: post_randomize
  //
  // Sets the object representation of the allocated object
  function void post_randomize();
    if (converter == null) begin
      `uvm_error("ITEM_ALLOCATOR", "coverter is not set. can not randomize the object")
      return;
    end
    
    object = converter.deserialize(item);
  endfunction: post_randomize
     
endclass: uvm_item_alloc_policy


//------------------------------------------------------------------------------
// Class: uvm_item_allocator
//------------------------------------------------------------------------------
// main allocator for specific item type
//
//------------------------------------------------------------------------------
class uvm_item_allocator #(type T=longint unsigned, type I=longint unsigned);

  uvm_item_alloc_policy#(T, I) alloc_policy;

  string  key;  // used to access global (C) DB; 
  // if key is empty, global DB is not used and allocator works in local mode

  // what should be the default ??
  bit     is_local;

  function new(string name, string key = "" );
    this.key = key;
    this.is_local = (key == "");
  endfunction: new
  
  protected I in_use[$];


  //task API
  task lock();
    svdpi_lock_taken_list(key);
  endtask // lock
 
  function void unlock();
    svdpi_unlock_taken_list(key);
  endfunction // unlock
  
  //can_reserve(T item_to_reserve, bit external_lock = 0);
  task reserve_item_t(T item_to_reserve, output bit result);
    lock();
    result = reserve_item(item_to_reserve, 1);
    unlock();
  endtask

  // function bit can_request(input uvm_item_alloc_policy#(T, I) alloc = null, 
  //                         bit external_lock = 0);
  task request_item_t(uvm_item_alloc_policy#(T, I) alloc, 
                    output T item, output bit result);
    lock();
    result = request_item(alloc,item,1);
    unlock();

  endtask
 
  task release_item_t(T object);
    lock();
    release_item(object,1);
    unlock();
  endtask // release_item_t
  
  task release_all_items_t();
    lock();
    release_all_items(1);
    unlock();
  endtask // release_all_items

  // function API
  protected function void import_in_use(bit external_lock = 0);
    // check that size of I is <= 64 bits
    if (!is_local) begin
      int size;
      longint db[];
      if (!external_lock) begin
        if (svdpi_try_lock_taken_list(key) != 0) // unsuccessful lock
          `uvm_fatal("ITEM_ALLOCATOR", "lock is not available and function version is called")
      end
      size = svdpi_get_num_taken(key);
      if (size > 0) begin
        db = new[size];
        svdpi_get_taken_list(key,size,db);
        in_use = {};
        for (int i = 0; i < size; i++) begin
          I value;
          value = db[i];
          in_use.push_back(value);
        end
      end
      else
        in_use = {};
    end
  endfunction: import_in_use

  protected function void export_in_use(bit external_lock = 0); 
    // check that size of I is <= 64 bits
    if (!is_local) begin
      longint db[];
      if (in_use.size() > 0) begin
        db = new[in_use.size()];
        for (int i = 0; i < in_use.size(); i++)
          db[i] = in_use[i];
      end
      svdpi_set_taken_list(key,in_use.size(),db);
      if (!external_lock)
        svdpi_unlock_taken_list(key);
    end
  endfunction : export_in_use
  

  protected function void done_in_use(bit external_lock = 0);
    if (!is_local && !external_lock) begin
      svdpi_unlock_taken_list(key);
    end
  endfunction: done_in_use
  
  protected function void start_in_use(bit external_lock = 0);
    if (!is_local && !external_lock) begin
        if (svdpi_try_lock_taken_list(key) != 0) // unsuccessful lock
          `uvm_fatal("ITEM_ALLOCATOR", "lock is not available and function version is called")
      end
  endfunction: start_in_use
    
  
  function bit can_reserve(T item_to_reserve, bit external_lock = 0);
    I int_item;
    bit result;
    alloc_policy.in_use = this.in_use;
    if (alloc_policy.converter == null) begin
      `uvm_error("ITEM_ALLOCATOR", "alloc_policy.converter is null. can not be used.")
        return 0;
    end
    import_in_use(external_lock);
    int_item = alloc_policy.converter.serialize(item_to_reserve);
    result = alloc_policy.randomize(null) with {item == int_item;};
    done_in_use(external_lock);
    return result;
  endfunction: can_reserve
  
  function bit reserve_item(T item_to_reserve, bit external_lock = 0);
    I int_item;
    bit result;

    result = 0;
    alloc_policy.in_use = this.in_use;
    if (alloc_policy.converter == null) begin
      `uvm_error("ITEM_ALLOCATOR", "alloc_policy.converter is null. can not be used.")
      return 0;
    end
    import_in_use(external_lock);
    int_item = alloc_policy.converter.serialize(item_to_reserve);
    if (alloc_policy.randomize() with {item==int_item;})
      begin
        result = 1;

        this.in_use.push_back(alloc_policy.item);
        export_in_use(external_lock);
      end
    else begin
      done_in_use(external_lock);
      `uvm_error("ITEM-ALLOCATOR", $sformatf("Can not reserve item %d",item_to_reserve) )
    end
    return result;
  endfunction: reserve_item
  
  function bit can_request(input uvm_item_alloc_policy#(T, I) alloc = null, 
                           bit external_lock = 0);
    bit result;
    result = 0;
    
    if (alloc == null)
      alloc = alloc_policy;

    import_in_use(external_lock);
    alloc.in_use = this.in_use;
    result = alloc_policy.randomize(null);
    done_in_use(external_lock);
    return result;
  endfunction: can_request
  
  function bit request_item(uvm_item_alloc_policy#(T, I) alloc, 
                            output T item, input bit external_lock=0);
    bit result;
    result = 0;

    if (alloc == null)
      alloc = alloc_policy;

    import_in_use(external_lock);
    alloc.in_use = this.in_use;
    result = alloc.randomize();

    if (result) begin
      item = alloc.object;
      this.in_use.push_back(alloc.item);
      export_in_use(external_lock);
    end
    else begin
      done_in_use(external_lock);
      `uvm_error("ITEM-ALLOCATOR", "Can not request item" )
    end
    return result;
  endfunction: request_item
  
  function void release_item(T object, bit external_lock = 0);
    I item;
    if (alloc_policy.converter == null) begin
      `uvm_error("ITEM_ALLOCATOR", "coverter is not set. can not be used")
      return;
    end
    item = alloc_policy.converter.serialize(object);
    import_in_use(external_lock);
    foreach (this.in_use[i]) begin
      if (this.in_use[i] == item) begin
        this.in_use.delete(i);
        export_in_use(external_lock);
        return;
      end
    end
    done_in_use(external_lock);
   `uvm_error("ITEM-ALLOCATOR", $sformatf("can not release item %0d. it is not currently allocated", item))
  endfunction: release_item
  
  function void release_all_items(bit external_lock = 0);
    start_in_use(external_lock);
    in_use.delete();
    export_in_use(external_lock);
  endfunction: release_all_items
  
  
  function string convert2string();
    string result;
    import_in_use(1); // do we need a task version of this function, which actually waits for lock?
    result = "Allocated items: \n";
    foreach (this.in_use[i]) begin
      $sformat(result, "%s   %0d", result,
               this.in_use[i]);
    end
    result = {result, "\n"};
    done_in_use(1);
    return result;
  endfunction: convert2string

endclass: uvm_item_allocator

`endif // ifndef UVM_ITEM_ALLOCATOR__SVH
