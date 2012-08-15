// Experimental extension of basic objection, tuned to be used for phasing
// (prevents others from doing request_to_raise, guards cycle
// counts to include the request_to_raise, etc.)
   
class uvm_phase_objection extends uvm_basic_objection;

   uvm_object m_controller;
   
   `uvm_object_utils(uvm_phase_objection)

   function new(string name="unnamed-uvm_phase_objection");
      super.new(name);
   endfunction : new

   // Lock down the request_to_raise
   virtual function void m_process(uvm_objection_message message, bit pre_notified);

      // Do some basic tidying up of the message
      if (message.get_obj() == null)
        message.set_obj(m_top);

      message.set_objection(this);

      if ((message.get_action_type() == UVM_OBJECTION_RAISE_REQUESTED) &&
          (message.get_obj() != m_controller)) begin
         uvm_object l_obj = message.get_obj();
         
        `uvm_warning("BAD_REQ_TO_RAISE", $sformatf("ignoring %s, only '%s' can send a request_to_raise on this objection", message.convert2string(), m_controller.get_full_name()))

      end
      else begin
         super.m_process(message, pre_notified);
      end
   endfunction : m_process

endclass : uvm_phase_objection


   
         
   
      
