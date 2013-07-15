//----------------------------------------------------------------------
//   Copyright 2013 Synopsys, Inc.
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

class upperA_seq extends uvm_sequence#(upperA_item);
  `uvm_object_utils(upperA_seq)

  function new(string name = "upperA_seq");
    super.new(name);
  endfunction

  task body();
    upperA_item tr;

    for(int i = 0; i < 3; i++) begin
      tr = upperA_item::type_id::create($sformatf("A[%0d]", i), , get_full_name());
      `uvm_send(tr)
    end
  endtask
endclass


class upperB_seq extends uvm_sequence#(upperB_item);
  `uvm_object_utils(upperB_seq)

  function new(string name = "upperB_seq");
    super.new(name);
  endfunction

  task body();
    upperB_item tr;

    for(int i = 0; i < 3; i++) begin
      tr = upperB_item::type_id::create($sformatf("B[%0d]", i), , get_full_name());
      `uvm_send(tr)
    end
  endtask
endclass


class tb_test extends base_test;

  `uvm_component_utils(tb_test)

  function new(string name = "tb_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  virtual task main_phase(uvm_phase phase);
    phase.raise_objection(this);

    fork
      begin
        upperA_seq seq = new("seqA");
        seq.start(env.upA.sqr);
      end

      begin
        upperB_seq seq = new("seqB");
        seq.start(env.upB.sqr);
      end
    join
    phase.drop_objection(this);
  endtask

endclass
