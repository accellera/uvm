import uvm_pkg::*;
`include "uvm_macros.svh"

bit pass;

class C;
  int x;

  function string convert2string();
    string s;
    $sformat(s, "x = %0d", x);
    return s;
  endfunction
endclass

//----------------------------------------------------------------------
// class: test
//----------------------------------------------------------------------
class test extends uvm_component;

  `uvm_component_utils(test)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  task run_phase(uvm_phase phase);

    phase.raise_objection(this);

    pass = 1;
    basic_int_test();
    obj_test();
    db_test();

    phase.drop_objection(this);
  endtask

  // basic int test

  // The test checks to see that subsequence writes to the same resource
  // will properly trigger the modified bit.  It should trigger only
  // when the value acutally changes.  If a write is done with the same
  // value as the current value no write will take place and the
  // modified bit will not be set.

  task basic_int_test();
    uvm_resource#(int) r = new();
    int unsigned count;

    $display("basic int test");

    fork
      begin
        forever begin
          r.wait_modified();
          $display("%0t: resource modified: %0d", $time, r.read());
          count++;
        end
      end

      begin
        #1 r.write(1, this);
        #2 r.write(3, this);
        #3 r.write(3, this);
        #4 r.write(4, this);
        #5 r.write(5, this);
        #4 r.write(5, this);
        #1;
      end
    join_any

    // The resource was effectively modified 4 times
    pass = (pass & (count == 4));

  endtask

  // obj test

  // Similar in structure and intent for the basic int test.  The
  // difference is that the resource contains a class object, not a
  // simple scalar.  The modified bit should only trigger when a new
  // object is set in the resource, not just a new value for a field in
  // the object.

  task obj_test();
    uvm_resource#(C) r = new();
    int unsigned count;

    $display("obj test");

    fork
      begin
        C c;
        forever begin
          r.wait_modified();
          c = r.read();
          $display("%0t: resource modified: %0s", $time, c.convert2string());
          count++;
        end
      end

      begin
        C c1;
        C c2;
        c1 = new();
        c1.x = 7;
        #1 r.write(c1, this);
        c1.x = 9;
        #2 r.write(c1, this);
        c2 = new();
        c2.x = 5;
        #3 r.write(c2, this);
        c2.x = 101;
        #4 r.write(c2, this);
        #1;
      end
    join_any
    
    // The resource was effectively modified 2 times
    pass = (pass & (count == 2));

  endtask

  // db test
  //
  // Make sure the modified bit is triggered correctly when doing writes
  // through the uvm_resource layer.

  task db_test();

    uvm_resource#(int) r;
    int unsigned count = 0;

    $display("db test");

    uvm_resource_db#(int)::set("*", "A", 92, this);
    r = uvm_resource_db#(int)::get_by_name(get_full_name(), "A", 1);

    fork
      begin
        forever begin
          r.wait_modified();
          $display("%0t: resource modified: %0d", $time, r.read());
          count++;
        end
      end

      begin
        #1 if(!uvm_resource_db#(int)::write_by_name(get_full_name(), "A", 88, this))
          `uvm_error("db_test", "write did not complete");
        #2 if(!uvm_resource_db#(int)::write_by_name(get_full_name(), "A", 88, this))
          `uvm_error("db_test", "write did not complete");
        #3 if(!uvm_resource_db#(int)::write_by_name(get_full_name(), "A", 111, this))
          `uvm_error("db_test", "write did not complete");
        #4 if(!uvm_resource_db#(int)::write_by_name(get_full_name(), "A", 111, this))
          `uvm_error("db_test", "write did not complete");
        #1;
      end
    join_any

    // The resource was effectively modified 3 times.        
    pass = (pass & (count == 3));

  endtask

  function void report_phase(uvm_phase phase);
    if(pass)
      $display("*** UVM TEST PASSED ***");
    else
      $display("*** UVM TEST FAILED ***");
  endfunction

endclass


module top;

  initial run_test();

endmodule