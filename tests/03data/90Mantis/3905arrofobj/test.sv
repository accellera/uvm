`include "uvm_macros.svh"

module test();

  import uvm_pkg::*;


class C extends uvm_object;
  int i;
  `uvm_object_utils_begin(C);
    `uvm_field_int(i,UVM_PRINT)
  `uvm_object_utils_end

   function new(string name= "C");
      super.new(name);
   endfunction
      
endclass

class my_catcher extends uvm_report_catcher;
   static int seen = 0;
   virtual function action_e catch();
      if(get_id() == "STRMTC") begin
        seen++;
      end
      return THROW;
   endfunction
endclass



class my_object extends uvm_object;
  int field;
  string msg;
  C c;
  
  
  `uvm_object_utils_begin(my_object);
    `uvm_field_int(field,UVM_PRINT)
    `uvm_field_string(msg,UVM_PRINT)
    `uvm_field_object( c,UVM_ALL_ON)
  `uvm_object_utils_end
   
   function new(string name= "my_object");
      super.new(name);
   endfunction
endclass
  
class my_component extends uvm_component;
  my_object object,object2;
  my_object array[]=new[5];
  my_object array1[]=new[2];
  my_object array2[]=new[2];
  my_object array3[]=new[3];
  my_object array4[]=new[3];
  my_object array5[]=new[3];
  
  
  `uvm_component_utils_begin(my_component)
    `uvm_field_object(object,UVM_ALL_ON)
    `uvm_field_object(object2,UVM_ALL_ON)
	  `uvm_field_array_object(array,UVM_ALL_ON)
	  `uvm_field_array_object(array1,UVM_ALL_ON)
    `uvm_field_array_object(array2,UVM_ALL_ON)
    `uvm_field_array_object(array3,UVM_ALL_ON)
    `uvm_field_array_object(array4,UVM_ALL_ON)
    `uvm_field_array_object(array5,UVM_ALL_ON)
  `uvm_component_utils_end

  function new(string name, uvm_component parent);
    super.new(name,parent);

    object = my_object::type_id::create("object");
    object2 = my_object::type_id::create("object");
    array[0] = my_object::type_id::create("array[0]");
    array[1] = my_object::type_id::create("array[1]");
    array[2] = my_object::type_id::create("array[2]");
    array[3] = my_object::type_id::create("array[3]");
    array1 = new[2];
    array2 = new[2];
    
    array1[0] = new;
    array1[1] = new;
    array1[0].field=-1;
    array1[1].msg="old!";
    
    array2[0] = new;
    array2[1] = new;
    array2[0].field=-1;
    array2[1].msg="old!";
  endfunction

  function void build();
    super.build();
  endfunction

endclass


  
class test extends uvm_test;
  `uvm_component_utils(test)

  my_component component;
  int object_field, array_field;
  string object_msg, array_msg;
  
  function new(string name, uvm_component parent);
    super.new(name,parent);
  endfunction

  function void build();
    super.build();
    component = my_component::type_id::create("component",this);
    
    // Works
    object_field = 'hbe;
    set_config_int("component","object.field",object_field);

    // Works
    object_msg = "goodbye";
    set_config_string("component","object.msg",object_msg);

    // Works
    array_field = 'h7a;
    set_config_int("component","array[0].field",array_field);

    // Works
    array_msg = "hello";
    set_config_string("component","array[1].msg",array_msg);

    // do not work
    begin 
      C c =new;
      c.i=123;
      set_config_object("component","array[2].c",c);
    end

    // Works
    set_config_int("component","array1",4);

    // Works
    set_config_int("component","array2",1);
    
    begin
    my_object mytmp;
    mytmp = new;
    mytmp.msg = "test ok";
    set_config_object("component","array[3]",mytmp);
    set_config_object("component","array[4]",mytmp);
    set_config_object("component","array3[3]",mytmp);
    set_config_object("component","array4[5]",mytmp);
    set_config_object("component","array5[*]",mytmp);
    end
    
    set_config_int("component","array5[1]",-1);
    set_config_string("component","array5[1]","fail");
    set_config_string("component","array5","fail");
  endfunction

  function void end_of_elaboration();
    bit failed = 0;
    if( component.object.field != object_field ) begin
      failed = 1;
      `uvm_error(get_type_name(),
                 $sformatf("expected component.object.field == %0h, but saw %0h",
                           object_field, component.object.field) )
    end


    if( component.object.msg != object_msg ) begin
      failed = 1;
      `uvm_error(get_type_name(),
                 $sformatf("expected component.object.msg == %s, but saw %s",
                           object_msg, component.object.msg) )
    end


    if( component.array[0].field != array_field ) begin
      failed = 1;
      `uvm_error(get_type_name(),
                 $sformatf("expected component.array[0].field == %0h, but saw %0h",
                           array_field, component.array[0].field) )
    end

    if( component.array[1].msg != array_msg ) begin
      failed = 1;
      `uvm_error(get_type_name(),
                 $sformatf("expected component.array[1].msg == %s, but saw %s",
                           array_msg, component.array[1].msg) )
    end
    
    if( component.array[3].msg != "test ok" ) begin
      failed = 1;
      `uvm_error(get_type_name(),
                 $sformatf("expected component.array[3].msg == %s, but saw %s",
                           array_msg, component.array[3].msg) )
    end
    
    if( component.array[4].msg != "test ok" ) begin
      failed = 1;
      `uvm_error(get_type_name(),
                 $sformatf("expected component.array[4].msg == %s, but saw %s",
                           array_msg, component.array[4].msg) )
    end
    
    begin
      my_object tmp;
      tmp = component.array[2];
      if( tmp.c.i != 123 ) begin
        
        failed = 1;
        
        `uvm_error(get_type_name(),
                   $sformatf("expected component.array[2].c.i == %s, but saw %s",
                             123, tmp.c.i) )
      end
    end

    if( component.array1.size != 4 ) begin
      failed = 1;
      `uvm_error(get_type_name(),
                 $sformatf("expected component.array1.size == 4, but saw %d",
                           component.array1.size) )
    end
    
    if( component.array2.size != 1 ) begin
      failed = 1;
      `uvm_error(get_type_name(),
                 $sformatf("expected component.array2.size == 1, but saw %d",
                           component.array2.size) )
    end
    
    if( component.array3.size != 4 && component.array3[3].msg=="test ok" ) begin
      failed = 1;
      `uvm_error(get_type_name(),
                 $sformatf("expected component.array3.size == 4, but saw %d",
                           component.array3.size) )
    end
    
    if( component.array4.size != 6  && component.array4[5].msg=="test ok" ) begin
      failed = 1;
      `uvm_error(get_type_name(),
                 $sformatf("expected component.array4.size == 6, but saw %d",
                           component.array4.size) )
    end
    
    if( component.array5[0].msg!="test ok" || component.array5[1].msg!="test ok" || component.array5[2].msg!="test ok") begin
      failed = 1;
      `uvm_error(get_type_name(),
                 $sformatf("expected component.array5 not setted via wild card" ));
    end

    if (!failed && my_catcher::seen == 3) begin
      $display("*** UVM TEST PASSED ***");
    end
    else begin
      $display("*** UVM TEST FAILED ***");
    end

    uvm_top.print_topology();
  endfunction

endclass

  initial begin
    my_catcher cather;
    cather = new;
    uvm_report_cb::add(null,cather);
    run_test("test");
  end
  
endmodule
