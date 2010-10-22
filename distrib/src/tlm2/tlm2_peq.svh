//----------------------------------------------------------------------
//   Copyright 2010 Mentor Graphics Corporation
//   Copyright 2010 Synopsys, Inc.
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
// Title: payload event queue
//
// A data structure containing time/transaction pairs.  The data
// structure is organized as an associative array of queues of
// transactions.  Each queue representes the list of transactions
// scheduled at a particular time.  The key for the associative array is
// time.
//
//  > time   queue
//  >+-----+-----+
//  >|     |     |
//  >+-----+-----+   +---+---+---+---+
//  >|  17 |   --+-->|   |   |   |   |
//  >+-----+-----+   +---+---+---+---+
//  >|     |     |
//  >+-----+-----+   +---+---+
//  >|  22 |   --+-->|   |   |
//  >+-----+-----+   +---+---+
//  >|     |     |
//  >+-----+-----+
//  >|     |     |
//  >+-----+-----+
//  >|     |     |
//  >+-----+-----+
//  >|     |     |
//  >+-----+-----+
//  
//
//  This illustration shows a priority event queue (peq) with some
//  transactions at time 17 and some at time 22.
//
//----------------------------------------------------------------------

//----------------------------------------------------------------------
// Class:  tlm_peq_base
//
//----------------------------------------------------------------------
virtual class tlm_peq_base extends uvm_object;

  function new(string name);
    super.new(name);
  endfunction

endclass

//----------------------------------------------------------------------
// Class:  tlm_peq_with_get
//
//----------------------------------------------------------------------
class tlm_peq_with_get #(type T=int) extends tlm_peq_base;

  typedef T queue [$];
  local queue m_scheduled_events[time];
  local event m_event;
  local process m_proc;

  function new(string name = "");
    super.new(name);
  endfunction

  //--------------------------------------------------------------------
  // Function:  notify
  //
  // Put a new transaction into the queue and notify the time for which
  // the transaction is scheduled.
  //
  //--------------------------------------------------------------------
  function void notify(T trans, time t = 0);

    queue q;
    time tidx = t + $time;

    if(m_scheduled_events.exists(tidx)) begin
      q = m_scheduled_events[tidx];
      q.push_back(trans);
    end
    else begin
      q.push_back(trans);
      m_scheduled_events[tidx] = q;
    end

    fork
      begin
        m_proc = process::self;
        # t;
        -> m_event;
      end
    join_none

    m_proc = null;

  endfunction

  //--------------------------------------------------------------------
  // Function: get_next_event
  //--------------------------------------------------------------------
  function T get_next_event();

    time t;
    queue q;
    T trans;

    if(m_scheduled_events.size() == 0)
      return null;

    if(!m_scheduled_events.first(t))
      return null; // no transactions in the queue, nothing to do.

    if(t <= $time) begin
      // Get the first transaction in the queue at this time
      q = m_scheduled_events[t];
      trans = q.pop_front();

      // if there are no more elements in the queue for this time slot
      // then get rid of the queue and the entry in the
      // m_scheduled_events array.
      if(q.size() == 0)
        m_scheduled_events.delete(t);
      return trans;
    end

    // notify the event at the time of the first transaction in the
    // queue
    fork
      begin
        m_proc = process::self;
        #(t-$time);
        -> m_event;
      end
    join_none

    m_proc = null;
    return null;

  endfunction

  //--------------------------------------------------------------------
  // Function: get_event
  //--------------------------------------------------------------------
  function event get_event();
    return m_event;
  endfunction
  
  //--------------------------------------------------------------------
  // Function: cancel_all
  //--------------------------------------------------------------------
  function void cancel_all();

    // If m_proc is not null then there is an outstanding notification.
    // Let's kill it.
    if(m_proc != null)
      m_proc.kill();
    m_proc = null;

    // remove all entries from the associative array
    m_scheduled_events.delete();
  endfunction

endclass
