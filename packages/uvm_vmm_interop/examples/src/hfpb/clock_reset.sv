//----------------------------------------------------------------------
//   Copyright 2007-2009 Mentor Graphics Corporation
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

//----------------------------------------------------------------------
// clock_reset
//
// generates a continuous stream of clock pulses with 50% duty cycle,
// that is the time in the low states is the same as the time in the
// high state.  The number of cycles, the period, and the time in reset
// can all be changed by passing parameters into run().
//----------------------------------------------------------------------
module clock_reset( interface i );
  
  parameter bit ACTIVE_RESET = 1;
   
  bit stop;
  
  initial begin
    stop = 0;
  end
  
  task run( int reset_hold = 2 ,
            int half_period = 10 ,
            int count = 0 );
  
    i.clk = 0;
    i.rst = ACTIVE_RESET;
  
    for( int i = 0; i < reset_hold; i++ ) begin
      tick( half_period );
      tick( half_period );
    end
  
    i.rst = !i.rst;
  
    for( int i = 0; (i < count || count == 0) && !stop; i++ ) begin
      tick( half_period );
    end
  endtask
  
  task tick( int half_period );
    # half_period;
    i.clk = !i.clk;
  endtask
  
endmodule