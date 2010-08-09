a//----------------------------------------------------------------------
//   Copyright 2010 Mentor Graphics Corporation
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
// tlm2_global_quantum
//
// A singleton that holds the global quantum
//----------------------------------------------------------------------
class tlm2_global_quantum;

  static tlm2_global_quantum m_instance;
  protected time m_global_quantum;

  local function new();
  endfunction

  static function tlm2_global_quantum inst();
    if(m_instance == null)
      m_instance = new();
    return m_instance;
  endfunction

  function void set(time t);
    m_global_quantum = t;
  endfunction

  function time compute_local_quantum();

    time tmp, remainder;

    if(m_global_quantum == 0)
      return 0;

    tmp = ($time/m_global_quantum + 1) * m_global_quantum;
    remainder = tmp - $time;

    return remainder;

  endfunction

endclass

//----------------------------------------------------------------------
// tlm2_quantumkeeper
//
// A class that holds the local quantum
//----------------------------------------------------------------------
class tlm2_quantumkeeper;

  protected time m_next_sync_point;
  protected time m_local_time;

  virtual function void inc(time t);
    m_local_time += t;
  endfunction

  virtual function void set(time t);
    m_local_time = t;
  endfunction

  virtual function bit need_sync();
    return ($time + m_local_time) >= m_next_sync_point;
  endfunction

  virtual task sync();
    wait(m_local_time);
    reset();
  endtask

  task set_and_sync(time t);
    set(t);
    if(need_sync())
      sync();
  endtask

  virtual function void reset();
    m_local_time = 0;
    m_next_sync_point = $time + compute_local_quantum();
  endfunction

  virtual function time get_current_time();
    return $time + m_local_time;
  endfunction

  virtual function time get_local_time();
    return m_local_time;
  endfunction

  protected virtual function time compute_local_quantum();
    tlm2_global_quantum qntm = tlm2_global_quantum::inst();
    return qntm.compute_local_quantum();
  endfunction

endclass
