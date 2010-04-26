module test;
  import uvm_pkg::*;

  virtual class cb_base extends uvm_callback;
    pure virtual function void doit(ref int arg);
  endclass

  class ip_base extends uvm_component;
    `uvm_component_utils(ip_base)
    `uvm_register_cb(ip_base,cb_base)
    function new(string name,uvm_component parent);
      super.new(name,parent);
    endfunction
    task run;
      int i;
      $display("executing callbacks from ip_base");
      `uvm_do_callbacks(cb_base,ip_base,doit(i))
    endtask
  endclass

  class ip_ext extends ip_base;
    `uvm_component_utils(ip_ext)
    `uvm_register_derived_cb(ip_ext,cb_base,ip_base,cb_base)
    function new(string name,uvm_component parent);
      super.new(name,parent);
    endfunction
    task run;
      int i;
//Since we are executing the same callbacks, they should happen
//in both places.
      $display("executing callbacks from derived class");
      `uvm_do_callbacks(cb_base,ip_ext,doit(i))
      super.run();
    endtask
  endclass

  class mycb extends cb_base;
    `uvm_object_utils(mycb)
    virtual function void  doit(ref int arg);
      $display("... executing cb with ref arg: %0d, incrementing", arg);
      arg++;
    endfunction
  endclass

  mycb cb = new;
  ip_ext comp=new("comp",null);

  initial begin
    uvm_callbacks#(ip_ext,cb_base)::add_cb(comp,cb);
    uvm_callbacks#(ip_ext,cb_base)::add_cb(comp,cb);
    uvm_callbacks#(ip_base,cb_base)::add_cb(comp,cb);
    uvm_callbacks#(ip_base,cb_base)::display_cbs();
    run_test();
  end
  
endmodule
