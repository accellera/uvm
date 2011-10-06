//
//------------------------------------------------------------------------------
//   Copyright 2011 (Authors)
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
//------------------------------------------------------------------------------

module top;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  class my_catcher extends uvm_report_catcher;
     static int item_seen = 0;
     static int seq_seen = 0;
     static int global_seen = 0;
     uvm_sequencer_base seqr;
     function new(uvm_sequencer_base seqr);
       this.seqr = seqr;
     endfunction

     virtual function action_e catch();
        if(get_id() == "ITEM" && get_client() == seqr) begin
          item_seen++;
        end
        else if(get_id() == "ITEM" && get_client() == uvm_top) begin
          global_seen++;
        end
        else if(get_id() == "SEQ" && get_client() == seqr) begin
          seq_seen++;
        end
        else if(get_id() == "SEQ" && get_client() == uvm_top) begin
          global_seen++;
        end
        return THROW;
     endfunction
  endclass

  class myitem extends uvm_sequence_item;
    `uvm_object_utils(myitem)
    function void doit();
      `uvm_info("ITEM", "This is a message from an item", UVM_NONE)
    endfunction

  function new(string name="myitem");
     super.new(name);
  endfunction

  endclass

  class myseq extends uvm_sequence#(myitem);
    `uvm_object_utils(myseq)
    task body;
      myitem global_item = new;

      `uvm_info("SEQ", $sformatf("This is a message from an sequence starting parent sequencer is: %s",m_sequencer.get_full_name()), UVM_NONE)
      `uvm_create(req)
      req.doit();
      global_item.doit(); //not attached to this sequencer, so should use root
    endtask

  function new(string name="myseq");
     super.new(name);
  endfunction

  endclass

  class mysequencer extends uvm_sequencer#(myitem);
    `uvm_new_func
    `uvm_component_utils(mysequencer)
    my_catcher catcher;
    task run_phase(uvm_phase phase);
      myseq seq = myseq::type_id::create("myseq",this);
      catcher = new(this);
      uvm_report_cb::add(null,catcher);
      phase.raise_objection(this);
      seq.start(this);
      phase.drop_objection(this);
    endtask
    function void report();
      int failed = 0;
      if(catcher.item_seen != 1) begin
        $display("*** UVM TEST FAILED, item seen count = %0d, expected 1", catcher.item_seen);
        failed = 1;
      end
      if(catcher.seq_seen != 1) begin
        $display("*** UVM TEST FAILED, seq seen count = %0d, expected 1", catcher.seq_seen);
        failed = 1;
      end
      if(catcher.global_seen != 1) begin
        $display("*** UVM TEST FAILED, global seen count = %0d, expected 1", catcher.global_seen);
        failed = 1;
      end
      if(failed == 0) $display("*** UVM TEST PASSED ***");
    endfunction
  endclass

  class test extends uvm_component;
    mysequencer seqr;
    `uvm_component_utils(test)

    function new(string name, uvm_component parent);
      super.new(name,parent);
      seqr = new("seqr", this);
    endfunction
  endclass 

  initial run_test();
endmodule
