`ifndef RAL_S
`define RAL_S


class ral_sys_S extends uvm_ral_block;

  rand ral_block_B B[2];

  `uvm_object_utils(ral_sys_S)

  function new(string name = "S");
    super.new(name,uvm_ral::NO_COVERAGE);
  endfunction: new

   function void build();

    default_map = create_map("default_map", 'h0, 1, uvm_ral::LITTLE_ENDIAN);

    foreach (B[i]) begin
      B[i] = ral_block_B::type_id::create($psprintf("B[%0d]", i));
      B[i].build();
      B[i].configure(this);
      default_map.add_submap(this.B[i].default_map, 'h100 + i*'h100);
    end

    Xlock_modelX();
  endfunction : build

endclass : ral_sys_S


`endif
