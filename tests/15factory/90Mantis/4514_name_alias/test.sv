//----------------------------------------------------------------------
//   Copyright 2011 Synopsys, Inc.
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


program top;

import uvm_pkg::*;
`include "uvm_macros.svh"

class special_tlm_gp extends uvm_tlm_gp;

   `uvm_object_utils(special_tlm_gp)

   function new(string name="unnamed-special_tlm_gp");
      super.new(name);
   endfunction : new

endclass : special_tlm_gp

class other_tlm_gp extends uvm_tlm_gp;

   `uvm_object_utils(other_tlm_gp)

   function new(string name="unnamed-other_tlm_gp");
      super.new(name);
   endfunction : new

endclass : other_tlm_gp

initial begin
   uvm_factory f = uvm_factory::get();
   uvm_tlm_generic_payload gp;
   special_tlm_gp sgp;
   other_tlm_gp ogp;

   f.set_type_override_by_name("uvm_tlm_gp", "uvm_tlm_generic_payload");

   gp = null;
   $cast(gp, f.create_object_by_name(.requested_type_name("uvm_tlm_gp"), .name("gp")));

   if (gp == null) begin
      f.debug_create_by_name(.requested_type_name("uvm_tlm_gp"),
                             .name("gp"));
     `uvm_fatal("TEST", "failed to create gp using 'uvm_tlm_gp'")
   end

   f.set_type_override_by_type(uvm_tlm_gp::get_type(), special_tlm_gp::get_type());

   sgp = null;
   $cast(sgp, f.create_object_by_name(.requested_type_name("uvm_tlm_gp"), .name("sgp")));

   if (sgp == null) begin
      f.debug_create_by_name(.requested_type_name("uvm_tlm_gp"),
                             .name("sgp"));
      `uvm_fatal("TEST", "failed to create sgp using 'uvm_tlm_gp'")
   end
   f.set_inst_override_by_name("uvm_pkg::uvm_tlm_gp", "uvm_tlm_generic_payload", "foo.bar*");

   gp = null;
   $cast(gp, f.create_object_by_name(.requested_type_name("uvm_pkg::uvm_tlm_gp"),
                                     .parent_inst_path("foo.bar"),
                                     .name("gp")));

   if (gp == null) begin
      f.debug_create_by_name(.requested_type_name("uvm_pkg::uvm_tlm_gp"),
                             .parent_inst_path("foo.bar"),
                             .name("gp"));
     `uvm_fatal("TEST", "failed to create gp using 'uvm_pkg::uvm_tlm_gp'")
   end

   f.set_inst_override_by_type(uvm_tlm_gp::get_type(), other_tlm_gp::get_type(), "foo.bar*");

   ogp = null;
   $cast(ogp, f.create_object_by_name(.requested_type_name("uvm_pkg::uvm_tlm_gp"),
                                      .parent_inst_path("foo.bar"),
                                      .name("ogp")));

   if (ogp == null) begin
      f.debug_create_by_name(.requested_type_name("uvm_pkg::uvm_tlm_gp"),
                             .parent_inst_path("foo.bar"),
                             .name("ogp"));
      `uvm_fatal("TEST", "failed to create sgp using 'uvm_pkg::uvm_tlm_gp'")
   end

   $display("** UVM TEST PASSED **\n");
end

endprogram
