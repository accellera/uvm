`ifndef __MEM_DRIVER_SV__
`define __MEM_DRIVER_SV__


class mem_driver extends uvm_driver #(mem_transfer);

   `uvm_component_utils(mem_driver)

   extern function new(string name, uvm_component parent);
   extern virtual task run_phase(uvm_phase phase);
endclass // mem_driver


function mem_driver::new(string name, uvm_component parent);
   super.new(name, parent);
endfunction // new


task mem_driver::run_phase(uvm_phase phase);
   forever begin
      seq_item_port.get_next_item(req);
      $cast(rsp, req.clone());
      rsp.set_id_info(req);

      // Populate memory
      foreach (rsp.data[i]) begin
         `uvm_info(get_type_name(),
                   $sformatf("Loaded memory: <ADDR> = 'x%0h\t <DATA> 'x%0h",rsp.address+i,rsp.data[i]),
                   UVM_LOW)
         if (rsp.address[7:0]+i != rsp.data[i])
           `uvm_fatal("MEM_LD", $sformatf("data %d loading is not incrementing with address %d", rsp.data[i], rsp.address[7:0]+i))
      end

      seq_item_port.item_done();
   end
endtask // run_phase


`endif //__MEM_DRIVER_SV__  
