//---------------------------------------------------------------------- 
//   Copyright 2010-2011 Mentor Graphics Corporation
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

import uvm_pkg::*;
 
module top;

  int errors =0;
  
  
  typedef int aa_i_s[string];
  typedef int q_i[$];
  typedef int a_i[];
  typedef struct { int a; int b; } s; 
  typedef string a_s[];

  uvm_built_in_pair #(int,int)         a1,b1,c1;
  uvm_built_in_pair #(string,string)   a2,b2,c2;
  uvm_built_in_pair #(chandle,chandle) a3,b3,c3;
  uvm_built_in_pair #(a_i,a_i)         a4,b4,c4;
  uvm_built_in_pair #(aa_i_s,aa_i_s)   a5,b5,c5;
  uvm_built_in_pair #(s,s)             a6,b6,c6;
  uvm_built_in_pair #(q_i,q_i)         a7,b7,c7;
  uvm_built_in_pair #(a_s,a_s)         a8,b8,c8;

//final check
 function void check();
if (errors ==0)
      $write("** UVM TEST PASSED **\n");
else
      $write("** UVM TEST FAILED **\n");
 endfunction

  q_i q0,q1,q2;
  aa_i_s aa0,aa1,aa2;
  s s0,s1,s2;
  a_i ar1,ar2;

initial 
begin
  aa0["0"]=0;      aa0["1"]=1;
  aa1["foo"]=-30;  aa1["bar"]=-40;
  aa2["foo2"]=50;  aa2["bar2"]=60;
  ar1 = new[2]; ar1[0] = -10; ar1[1] = -20;
  ar2 = new[2]; ar2[0] =  30; ar2[1] = 40;
  s0 = '{    0,    0 };
  s1 = '{ -100, -200 };
  s2 = '{  300,  400 };
  q0[0]=  0; q0[1] =   0;
  q1[0]=-10; q1[1] = -20;
  q2[0]= 30; q2[1] =  40;
  
 
 $display("\nint");      
 a1=new("a1");
 a1.first = 0;
 a1.second = 0;
 c1=new("c1");
 c1.first = -1;
 c1.second = 1;     
 $cast(b1,c1.clone()); a1.copy(b1); 
 $display("a1=%0s",a1.convert2string()); 
 assert (c1.compare(a1)==1)
 else 
 begin
 $display ("ERROR in %0s line %0d Comparison results should be 1", `__FILE__,  `__LINE__);
  errors ++;
  end

 
   
 $display("\nstring");   
 a2=new("a2");
 a2.first = "a";
 a2.second = "b"; 
 c2=new("c2");
 c2.first = "y";
 c2.second = "z"; 
 $cast(b2,c2.clone()); a2.copy(b2); 
 $display("a2=%0s",a2.convert2string()); 
 assert (c2.compare(a2)==1)
 else 
 begin
 $display ("ERROR in %0s line %0d Comparison results should be 1", `__FILE__,  `__LINE__);
  errors ++;
  end
    
 
 /*
 $display("\nchandle");  
 a3=new("a3");
 a3.first = 0;
 a3.second = 0; 
 c3=new("c3");
 c3.first = 2;
 c3.second = 3;
 $cast(b3,c3.clone()); a3.copy(b3); 
 $display("a3=%0s",a3.convert2string()); 
 assert (c3.compare(a3)==1)
 else 
 begin
 $display ("ERROR in %0s line %0d Comparison results should be 1", `__FILE__,  `__LINE__);
  errors ++;
  end
  */
   
   
   
 
 $display("\narray");    
 a4=new("a4");
 a4.first = new[4];
 a4.second = new [4]; 
 c4=new("c4");
 c4.first = ar1;
 c4.second = ar2; 
 $cast(b4,c4.clone()); a4.copy(b4); 
 $display("a4=%0s",a4.convert2string()); 
 assert (c4.compare(a4)==1)
 else 
 begin
 $display ("ERROR in %0s line %0d Comparison results should be 1", `__FILE__,  `__LINE__);
  errors ++;
  end
 
 
     
 
 $display("\nassarray"); 
 a5=new("a5");
 a5.first = aa0;
 a5.second = aa0; 
 c5=new("c5");
 c5.first = aa1;
 c5.second = aa2; 
 $cast(b5,c5.clone()); a5.copy(b5); 
 $display("a5=%0s",a5.convert2string()); 
 /*
 assert (c5.compare(a5)==1)
 else 
 begin
 $display ("ERROR in %0s line %0d Comparison results should be 1", `__FILE__,  `__LINE__);
  errors ++;
  end
  */
 
     
 
 $display("\nstruct");   
 a6=new("a6");
 a6.first = s0;
 a6.second = s0; 
 c6=new("c6");
 c6.first = s1;
 c6.second = s2; 
 $cast(b6,c6.clone()); a6.copy(b6); 
 $display("a6=%0s",a6.convert2string());
 assert (c6.compare(a6)==1)
 else 
 begin
 $display ("ERROR in %0s line %0d Comparison results should be 1", `__FILE__,  `__LINE__);
  errors ++;
  end
 
 
     
 
 $display("\nqueue");    
 a7=new("a7");
 a7.first = q0;
 a7.second = q0; 
 c7=new("c7");
 c7.first = q1;
 c7.second = q2; 
 $cast(b7,c7.clone()); a7.copy(b7); 
 $display("a7=%0s",a7.convert2string()); 
 assert (c7.compare(a7)==1)
  else 
  begin
  $display ("ERROR in %0s line %0d Comparison results should be 1", `__FILE__,  `__LINE__);
   errors ++;
   end
 
 check();
 
 uvm_top.report_summarize();
 
 end

 endmodule
 
