`ifndef REG_S
`define REG_S


class reg_sys_S extends uvm_reg_block;

  rand reg_block_B B[2];

  `uvm_object_utils(reg_sys_S)

  function new(string name = "S");
    super.new(name,UVM_NO_COVERAGE);
  endfunction: new

   function void build();

    default_map = create_map("default_map", 'h0, 1, UVM_LITTLE_ENDIAN);

    foreach (B[i]) begin
      B[i] = reg_block_B::type_id::create($psprintf("B[%0d]", i));
      B[i].build();
      B[i].configure(this);
      default_map.add_submap(this.B[i].default_map, 'h100 + i*'h100);
    end
  endfunction : build

endclass : reg_sys_S


`endif
