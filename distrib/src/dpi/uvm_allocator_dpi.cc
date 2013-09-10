#include "sys/types.h"

extern "C" {
#include<svdpi.h>

int svdpi_get_num_taken(const char* name);

void svdpi_get_taken_list(const char* name, int size,
                          svOpenArrayHandle /*uint64_t* */ db);

void svdpi_set_taken_list(const char* name, int size, const svOpenArrayHandle /*uint64_t* */ db);


void svdpi_lock_taken_list(const char* name);
bool svdpi_try_lock_taken_list(const char* name);
void svdpi_unlock_taken_list(const char* name);
}

void svdpi_get_taken_list(const char* name, int size, 
                          svOpenArrayHandle /*uint64_t* */ db)
{
  uint64_t* my_list = (uint64_t *) svGetArrayPtr(db);
  ListDb<>::inst()->getList(name,size, my_list);

}

void svdpi_set_taken_list(const char* name, int size, const svOpenArrayHandle /*uint64_t* */ db)
{
  uint64_t* my_list = NULL;
  if (size != 0) 
    // can not call svGetArrayPtr when size==0 since it causes an error in IUS
    my_list = (uint64_t *) svGetArrayPtr(db);
  ListDb<>::inst()->setList(name, size, my_list);
}

int svdpi_get_num_taken(const char* name)
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
