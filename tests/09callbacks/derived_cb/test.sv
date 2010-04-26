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

  virtual class modified_cb extends cb_base;
    //has doit and has domore
    pure virtual function void domore(ref int arg);
  endclass

  class ip_ext extends ip_base;
    `uvm_component_utils(ip_ext)
    `uvm_register_derived_cb(ip_ext,modified_cb,ip_base,cb_base)
    function new(string name,uvm_component parent);
      super.new(name,parent);
    endfunction
    task run;
      int i;

      //This time, doit() should get called from base run
      //and domore from ext run.
      $display("executing callbacks from derived class");
      `uvm_do_callbacks(modified_cb,ip_ext,domore(i))
      super.run();
    endtask
  endclass

  class mycb extends modified_cb;
    `uvm_object_utils(mycb)
    virtual function void  doit(ref int arg);
      $display("... executing doit cb with ref arg: %0d, incrementing", arg);
      arg++;
    endfunction
    virtual function void  domore(ref int arg);
      $display("... executing domore cb with ref arg: %0d, incrementing", arg);
      arg+=2;
    endfunction
  endclass

  mycb cb = new;
  ip_ext comp=new("comp",null);

  initial begin
    uvm_callbacks#(ip_ext,cb_base)::add_cb(comp,cb);
    uvm_callbacks#(ip_ext,modified_cb)::add_cb(comp,cb);
    uvm_callbacks#(ip_base,cb_base)::add_cb(comp,cb);

    //This one is illegal because the base type doesn't know
    //about the derived callback.
    uvm_callbacks#(ip_base,modified_cb)::add_cb(comp,cb);

    $display("-- Show callbacks for ip_base-cb_base");
    uvm_callbacks#(ip_base,cb_base)::display_cbs();
    $display("-- Show callbacks for ip_ext-modified");
    uvm_callbacks#(ip_base,cb_base)::display_cbs();
    run_test();
  end
  
endmodule
