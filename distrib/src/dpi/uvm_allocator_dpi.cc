//
//----------------------------------------------------------------------
//   Copyright 2013 Freescale Semiconductor, Inc.
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

#include "sys/types.h"

extern "C"
{
#include <svdpi.h>

unsigned int svdpi_get_num_taken(const char* name);

void svdpi_get_taken_list(const char* name, unsigned int size,
                          svOpenArrayHandle /* uint64_t* */ db);

void svdpi_set_taken_list(const char* name, unsigned int size,
                          const svOpenArrayHandle /* uint64_t* */ db);

void svdpi_lock_taken_list(const char* name);
bool svdpi_try_lock_taken_list(const char* name);
void svdpi_unlock_taken_list(const char* name);

}  // extern "C"

// Note, The db passed in from SystemVerilog is of type uint64_t*
void svdpi_get_taken_list(const char* name, unsigned int size, 
                          svOpenArrayHandle db)
{
  uint64_t* my_list = static_cast<uint64_t *> (svGetArrayPtr(db));
  ListDb<>::inst()->getList(name,size, my_list);

  return;
}  // svdpi_get_taken_list()

// Note: The db passed in from SystemVerilog is of type uint64_t*
void svdpi_set_taken_list(const char* name, unsigned int size,
                          const svOpenArrayHandle db)
{
  uint64_t* my_list = NULL;
  if (size != 0) // Cannot call svGetArrayPtr when size==0 since it causes
                 // an error in one of the vendor's DPI implementation
     my_list = static_cast<uint64_t *> (svGetArrayPtr(db));
  ListDb<>::inst()->setList(name, size, my_list);

  return;
}  // svdpi_set_taken_list()


unsigned int svdpi_get_num_taken(const char* name)
{
  return ListDb<>::inst()->getNumberOfItems(name);
}

void svdpi_lock_taken_list(const char* name)
{
  return ListDb<>::inst()->lockList(name);
}

bool svdpi_try_lock_taken_list(const char* name)
{
  return ListDb<>::inst()->tryLockList(name);
}

void svdpi_unlock_taken_list(const char* name)
{
  return ListDb<>::inst()->unlockList(name);
}

