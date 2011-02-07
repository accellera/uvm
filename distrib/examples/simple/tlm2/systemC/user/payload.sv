/*********************************************************************
 * SYNOPSYS CONFIDENTIAL                                             *
 *                                                                   *
 * This is an unpublished, proprietary work of Synopsys, Inc., and   *
 * is fully protected under copyright and trade secret laws. You may *
 * not view, use, disclose, copy, or distribute this file or any     *
 * information contained herein except pursuant to a valid written   *
 * license from Synopsys.                                            *
 *********************************************************************/


`ifndef _PAYLOAD_SV
`define _PAYLOAD_SV

class payload extends uvm_sequence_item;
   bit[31:0] addr;
   bit[31:0] data;
   bit response;  
   function string convert2string();
    return super.convert2string();
  endfunction

   `uvm_object_utils_begin(payload)
      `uvm_field_int(addr, UVM_ALL_ON)
      `uvm_field_int(data, UVM_ALL_ON)
      `uvm_field_int(response, UVM_ALL_ON)
   `uvm_object_utils_end   

   function byte_pack(ref logic [7:0] BA[]);   
      BA = new[9];
      BA[0] = addr[7:0];
      BA[1] = addr[15:8];
      BA[2] = addr[23:16];
      BA[3] = addr[31:24];
      BA[4] = data[7:0];
      BA[5] = data[15:8];
      BA[6] = data[23:16];
      BA[7] = data[31:24];
      BA[8] = response; 

   endfunction

   function byte_unpack(const ref logic [7:0] BA[]);
      addr[7:0]   = BA[0];
      addr[15:8]  = BA[1];
      addr[23:16] = BA[2];
      addr[31:24] = BA[3];
      data[7:0]   = BA[4];
      data[15:8]  = BA[5];
      data[23:16] = BA[6];
      data[31:24] = BA[7];
      response    = BA[8];
   endfunction
endclass


`endif
