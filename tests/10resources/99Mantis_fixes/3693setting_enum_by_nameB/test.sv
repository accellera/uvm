module testmod();

    import uvm_pkg::*;
    `include "uvm_macros.svh"

class child extends uvm_component;

    typedef enum {ALPHA, BETA, GAMMA, DELTA} e_t;

    e_t var1, var2, var3;

    e_t array[];

    e_t sarray[4];

    `uvm_component_utils_begin(child)
        `uvm_field_enum(e_t, var1, UVM_DEFAULT)
        `uvm_field_enum(e_t, var2, UVM_DEFAULT)
        `uvm_field_enum(e_t, var3, UVM_DEFAULT)
        `uvm_field_array_enum(e_t, array, UVM_DEFAULT)
        `uvm_field_sarray_enum(e_t, sarray, UVM_DEFAULT)
    `uvm_component_utils_end

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    virtual      function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        // Check for expected values

        // Set from 'test' via string
        if (var1 != BETA)
          `uvm_fatal("BADMATCH", $sformatf("Expected var1 value of 'BETA', but got '%s'", var1.name()))

        // Set from command line via string
        if (var2 != GAMMA)
          `uvm_fatal("BADMATCH", $sformatf("Expected var2 value of 'GAMMA', but got '%s'", var2.name()))

        // Set from command line w/ bad string,
        // Set from 'test' with w/ good string
        if (var3 != DELTA)
          `uvm_fatal("BADMATCH", $sformatf("Expected var3 value of 'DELTA', but got '%s'", var3.name()))


        // Set from test...
        if (array[0] != DELTA)
          `uvm_fatal("BADMATCH", $sformatf("Expected array[0] value of 'DELTA', but got '%s'", array[0].name()))

        if (array[1] != BETA)
          `uvm_fatal("BADMATCH", $sformatf("Expected array[1] value of 'BETA', but got '%s'", array[0].name()))

        if (array[2] != GAMMA)
          `uvm_fatal("BADMATCH", $sformatf("Expected array[2] value of 'GAMMA', but got '%s'", array[0].name()))

        // Set from test...
        if (sarray[0] != DELTA)
          `uvm_fatal("BADMATCH", $sformatf("Expected sarray[0] value of 'DELTA', but got '%s'", array[0].name()))

        if (sarray[1] != GAMMA)
          `uvm_fatal("BADMATCH", $sformatf("Expected sarray[1] value of 'GAMMA', but got '%s'", array[0].name()))

        if (sarray[2] != BETA)
          `uvm_fatal("BADMATCH", $sformatf("Expected sarray[2] value of 'BETA', but got '%s'", array[0].name()))

        if (sarray[3] != ALPHA)
          `uvm_fatal("BADMATCH", $sformatf("Expected sarray[3] value of 'ALPHA', but got '%s'", array[0].name()))

    endfunction : build_phase

endclass // child

class test extends uvm_component;

  child c;

  `uvm_component_utils(test)

  function new(string name, uvm_component parent);
      super.new(name, parent);

      print_config_matches = 1;
  endfunction : new

    virtual      function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        c = child::type_id::create("c", this);

        uvm_config_db#(int)::set(this, "c", "var1", child::ALPHA);
        uvm_config_db#(string)::set(this, "c", "var1", "BETA");
        uvm_config_db#(string)::set(this, "c", "var3", "DELTA");

        uvm_config_db#(int)::set(this, "c", "array", 3);
        uvm_config_db#(string)::set(this, "c", "array[0]", "DELTA");
        uvm_config_db#(string)::set(this, "c", "array[1]", "BETA");
        uvm_config_db#(string)::set(this, "c", "array[2]", "GAMMA");

        uvm_config_db#(string)::set(this, "c", "sarray[0]", "DELTA");
        uvm_config_db#(string)::set(this, "c", "sarray[1]", "GAMMA");
        uvm_config_db#(string)::set(this, "c", "sarray[2]", "BETA");
        uvm_config_db#(string)::set(this, "c", "sarray[3]", "ALPHA");
    endfunction : build_phase

    virtual      function void report_phase(uvm_phase phase);
        super.report_phase(phase);

        $display("*** UVM TEST PASSED ***");
    endfunction : report_phase

endclass // test

initial begin
    run_test();
end

endmodule // testmod
