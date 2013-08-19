//
//------------------------------------------------------------------------------
//   Copyright 2013 NVIDIA Corporation
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

  class test extends uvm_test;
    function new(string name, uvm_component parent);
      uvm_objection o;
      bit failed;
      super.new(name,parent);

      o = new("o");
      o.raise_objection(this, "initial raise", 1);
      o.drop_objection(this, "zero drop", 0);
      if (o.get_objection_count(this) != 1) begin
          failed = 1;
          `uvm_fatal("FAIL1", $sformatf("objection count is '%0d', we expected '1'", o.get_objection_count(this)))
      end
      o.raise_objection(this, "zero raise", 0);
      if (o.get_objection_count(this) != 1) begin
          failed = 1;
          `uvm_fatal("FAIL2", $sformatf("objection count is '%0d', we expected '1'", o.get_objection_count(this)))
      end
      o.drop_objection(this, "drop", 1);
      if (o.get_objection_count(this) != 0) begin
          failed = 1;
          `uvm_fatal("FAIL3", $sformatf("objection count is '%0d', we expected '0'", o.get_objection_count(this)))
      end
      o.drop_objection(this, "drop of all", o.get_objection_count(this));
      if (!failed)
        $display("** UVM TEST PASSED **");
    endfunction
    `uvm_component_utils(test)
  endclass

  initial run_test;

endmodule
