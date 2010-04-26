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
      uvm_report_info("EXCB","executing callbacks",UVM_NONE);
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
  class twcb extends cb_base;
    `uvm_object_utils(twcb)
    virtual function void  doit(ref int arg);
      $display("... executing typewide cb with ref arg: %0d, incrementing", arg);
      arg+=2;
    endfunction
  endclass

  mycb cb = new;
  twcb tcb = new;
  ip_comp comp,comp2;

  initial begin
    comp=new("comp",null);
    uvm_callbacks#(ip_comp,cb_base)::add_cb(comp,cb);
    uvm_callbacks#(ip_comp,cb_base)::add_cb(null,tcb);
    uvm_callbacks#(ip_comp,cb_base)::add_cb(comp,cb);
    comp2=new("comp2",null);
    uvm_callbacks#(ip_comp,cb_base)::add_cb(comp2,cb);

    uvm_callbacks#(ip_comp,cb_base)::display_cbs();
    run_test();
  end
  
endmodule
