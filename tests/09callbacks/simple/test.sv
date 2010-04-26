module test;
  import uvm_pkg::*;

  virtual class cb_base extends uvm_callback;
    pure virtual function void doit(ref int arg);
  endclass

  class ip_comp extends uvm_component;
    `uvm_component_utils(ip_comp)
    `uvm_register_cb(ip_comp,cb_base)
    function new(string name,uvm_component parent);
      super.new(name,parent);
    endfunction
    task run;
      int i;
      $display("executing callbacks");
      `uvm_do_callbacks(cb_base,ip_comp,doit(i))
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
  ip_comp comp=new("comp",null);

  initial begin
    uvm_callbacks#(ip_comp,cb_base)::add_cb(comp,cb);
    uvm_callbacks#(ip_comp,cb_base)::add_cb(comp,cb);
    uvm_callbacks#(ip_comp,cb_base)::add_cb(comp,cb);
    uvm_callbacks#(ip_comp,cb_base)::display_cbs();
    run_test();
  end
  
endmodule
