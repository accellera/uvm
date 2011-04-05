//----------------------------------------------------------------------
//   Copyright 2011 Cypress Semiconductor
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
// class: uvm_locker#(T)
//----------------------------------------------------------------------
class uvm_locker #(type T=int);

  local process pid;
  local T val;
  local semaphore sm;

  function new();
    sm = new(1);
    pid = null;
  endfunction

  //-------------------------
  // Group: Locking Interface
  //-------------------------
  //
  // The task <lock> and the functions <try_lock> and <unlock> form a
  // locking interface for resources.  These can be used for thread-safe
  // reads and writes.  The interface methods write_with_lock and
  // read_with_lock and their nonblocking counterparts in
  // <uvm_resource#(T)> (a family of resource subclasses) obey the lock
  // when reading and writing.  See documentation in <uvm_resource#(T)>
  // for more information on put/get.  The lock interface is a wrapper
  // around a local semaphore.

  // Task: lock
  //
  // Retrieves a lock for this resource.  The task blocks until the lock
  // is obtained.

  task lock();
    sm.get();
    set_process(process::self);
  endtask

  // Function: try_lock
  //
  // Retrives the lock for this resource.  The function is nonblocking,
  // so it will return immediately.  If it was successfull in retrieving
  // the lock then a one is returned, otherwise a zero is returned.

  function bit try_lock();
    if(sm.try_get()) begin
      set_process(process::self);
      return 1;
    end
    else
      return 0;
  endfunction

  // Function: unlock
  //
  // Releases the lock held by this semaphore.

  function void unlock();
    // is the lock already unlocked?  If so,
    // don't unlock it again.
    if(sm.try_get()) begin
      sm.put();
      $display("warning: lock is already unlocked.  Ignoring unlock request");
    end
    else begin
      sm.put();
      pid = null;
    end
  endfunction

  function void set_process(process p = null);
    pid = p;
  endfunction

  function process get_process();
    return pid;
  endfunction

  //-------------------------
  // Group: Read/Write Interface
  //-------------------------
  //
  // This interface is optional, you can choose to lock a resource or
  // not. These methods are wrappers around the read/write interface.
  // The difference between read/write interface and the locking
  // interface is the use of a semaphore to guarantee exclusive access.

  // Task: read
  //
  // Locking version of read().  Like read(), this returns the contents
  // of the resource container.  In addtion it obeys the lock.

  task read(output T t);
    if(pid != null && pid == process::self) begin
      t = val;
    end
    else begin
      lock();
      t = val;
      unlock();
    end
  endtask

  // Function: try_read
  //
  // Nonblocking form of read().  If the lock is availble it
  // grabs the lock and returns one.  If the lock is not available then
  // it returns a 0.  In either case the return is immediate with no
  // blocking.

  function bit try_read(output T t);
    if(pid != null && pid == process::self) begin
      t = val;
    end
    else begin
      if(!try_lock())
        return 0;
      t = val;
      unlock();
    end
    return 1;
  endfunction

  // Task: write
  //
  // Locking form of write().  Like write(), write() sets the
  // contents of the resource container.  In addition it locks the
  // resource before doing the write and unlocks it when the write is
  // complete.  If the lock is currently not available write()
  // will block until it is.

  task write (input T t);
    if(pid != null && pid == process::self) begin
      val = t;
    end
    else begin
      lock();
      val = t;
      unlock();
    end
  endtask

  // Function: try_write
  //
  // Nonblocking form of write(). If the lock is available then val is
  // updated immediately and a one is returned.  If the lock is not
  // available then val is not updated and a zero is returned.  In
  // either case try_write() returns immediately with no blocking.

  function bit try_write(input T t);
    if(pid != null && pid == process::self) begin
      val = t;
    end
    else begin
      if(!try_lock())
        return 0;
      val = t;
      unlock();
    end
    return 1;
  endfunction

endclass