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
// class- uvm_mutex_locker#(T)
//
// The uvm_mutex_locker#(T) class provides a policy for locking objects.
// Uvm_mutex_locker #(T), or the locker, as we'll refer to it, is a data
// container.  It holds a data object of type T.  Access to that data
// object is contolled via a muxtex (i.e. binary semaphore) locking
// mechanism.
//
// The typical use model is to use the locker as a resource.  The
// resource contains the locker, which in turn holds the data.  The
// locker provides an API for mutually exclusive access to the data.
//
// |  uvm_resource#(uvm_mutex_locker#(T))
//
// The locker provides a locking access policy for resources.  Other
// locking policies can be implemented by creating a different locker
// that supports a different policy, and possibly with a different API.
//
// The locker itself is access through normal resource operations.  The
// data is then accessed through the locker. E.g
//
// | uvm_resource#(uvm_mutex_locker#(T)) r;
// | uvm_mutex_locker#(T) lckr;
// | T t;
// |
// | lckr = r.read();
// | lckr.read(t);
// |
// | lckr = r.read();
// | lckr.write(t);
//
// The main locking API contains three methods
//
// |  task lock();
// |  function bit try_lock();
// |  function void unlock();
//
// ~Lock()~ is a task and may block.  It will block if some other
// process holds the lock to this locker.  ~Try_lock()~ and ~unlock()~
// are functions and will return immediately.  ~Try_lock()~ will attempt
// to obtain the lock.  It will return a value indicating its success or
// failure.  ~Unlock()~ releases the lock.
//
// Data access is done with four methods:
//
// |  task read(output T t);
// |  function bit try_read(output T t);
// |  task write (input T t);
// |  function bit try_write(input T t);
//
// The ~read()~ and ~write()~ methods are blocking -- they each call
// ~lock()~ and ~unlock()~.  The ~try_*()~ methods are nonblocking.
// They will return a value indicating whether or not they succeeded.
//
// An important aspect to the locker is ownership.  Each lock is owned
// by the process that acquired it.  Only the owning process can release
// the lock.  If a process is killed before it has been unlocked, the
// locker can be recovered by explicitly calling set_process to identify
// a different owner, or the next time lock() is called the situation
// will be detected and the locker will change ownership to the process
// requesting the lock.
//----------------------------------------------------------------------
class uvm_mutex_locker #(type T=int);

  local process pid;
  local T val;
  local semaphore sm;

  function new();
    sm = new(1);
    pid = null;
  endfunction

  //-------------------------
  // Group- Locking Interface
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

  // Task- lock
  //
  // Retrieves a lock for this resource.  The task blocks until the lock
  // is obtained.

  task lock();
    check_pid();
    sm.get();
    set_process(process::self);
  endtask

  // Function- try_lock
  //
  // Retrives the lock for this resource.  The function is nonblocking,
  // so it will return immediately.  If it was successfull in retrieving
  // the lock then a one is returned, otherwise a zero is returned.

  function bit try_lock();
    check_pid();
    if(sm.try_get()) begin
      set_process(process::self);
      return 1;
    end
    else
      return 0;
  endfunction

  // Function- unlock
  //
  // Releases the lock held by this semaphore.

  function void unlock();
    if(pid == null)
      uvm_report_error("uvm_mutex_locker::unlock", "Uh oh, attempt to release a lock with no process owner.  The lock is likely not currently held.  In any case the state is inconsistent and so the request to release the lock has been ignored.");
    else
    if(pid != process::self())
      uvm_report_error("uvm_mutex_locker::unlock", "Oh no, an attempt has been made to release the lock by a process other than the owner.  Lock state not changed.");
      else begin
        sm.put();
        pid = null;
      end
  endfunction

  // function- set_process
  //
  // Set the process owner of this locker to the process passed in as an
  // argument.  Pass in null to clear the locker of any ownership.

  function void set_process(process p = null);
    pid = p;
  endfunction

  // function- get_process
  //
  // Return the process id of the process that currently the owner of
  // this locker.  The return value may be null if no one owns it.

  function process get_process();
    return pid;
  endfunction

  // function- check_pid
  //
  // Is the lock owned by a dead process? If so then we'll rescue it
  // from the abyss by changing ownership to the current process.  We do
  // this by releasing the lock and letting the current process lock it.
  // This is called internally and should NOT be called directly by
  // users.

  local function void check_pid();
    if(pid != null &&(pid.status() == process::FINISHED ||
                      pid.status() == process::KILLED)) begin
      uvm_report_error("uvm_mutex_locker::lock", "lock is held by dead process! resetting ownership to current process");
      sm.put();
    end
  endfunction


  //-------------------------
  // Group- Read/Write Interface
  //-------------------------
  //
  // This interface is optional, you can choose to lock a resource or
  // not. These methods are wrappers around the read/write interface.
  // The difference between read/write interface and the locking
  // interface is the use of a semaphore to guarantee exclusive access.

  // Task- read
  //
  // Locking read(). Returns the contents of the locker.  This task will
  // block until the lock is obtained.  If the request comes from the
  // process that currently owns the lock then access is immediately
  // granted.

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

  // Function- try_read
  //
  // Nonblocking form of read().  If the lock is availble it grabs the
  // lock and returns 1.  If the lock is not available then it returns a
  // 0.  In either case the return is immediate with no blocking.  If
  // this is called by the process that currently holds the lock then
  // access is granted immediatly; no checking or manipulation of the
  // lock is done.

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

  // Task- write
  //
  // Modifies the data in the locker.  May block if the lock is held by
  // another process.  If the process that owns the lock calls this
  // function then access is granted immediatlely without checking or
  // maniuplating the lock.

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

  // Function- try_write
  //
  // Nonblocking form of write(). If the lock is available then val is
  // updated immediately and a 1 is returned.  If the lock is not
  // available then val is not updated and a 0 is returned.  In either
  // case try_write() returns immediately with no blocking.  If the
  // process that currently holds the lock calls this function then
  // access is granted immediatly without any checking or manipulation
  // of the lock.

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