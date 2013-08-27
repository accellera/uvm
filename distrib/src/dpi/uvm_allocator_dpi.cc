#include "sys/types.h"
#include <sstream>
#include <string>


extern "C" {
#include<svdpi.h>

  int getNumberOfTakenItems(const char* name)
  {
    return ListDb<>::inst()->getNumberOfItems(name);
  }
  void getTakenList(const char* name, int numOfItems, uint64_t* takenList)
  {
    ListDb<>::inst()->getList(name, numOfItems, takenList);
  }
  void setTakenList(const char* name, int numOfItems, const uint64_t* takenList)
  {
    ListDb<>::inst()->setList(name, numOfItems, takenList);
  }
}


extern "C" {

int svdpi_get_num_taken(const char* name);

void svdpi_get_taken_list(const char* name, int size,
                          svOpenArrayHandle /*uint64_t* */ db);

void svdpi_set_taken_list(const char* name, int size, const svOpenArrayHandle /*uint64_t* */ db);

}

void svdpi_get_taken_list(const char* name, int size, 
                          svOpenArrayHandle /*uint64_t* */ db)
{
  uint64_t* my_list = (uint64_t *) svGetArrayPtr(db);
  ListDb<>::inst()->getList(name,size, my_list);

}

void svdpi_set_taken_list(const char* name, int size, const svOpenArrayHandle /*uint64_t* */ db)
{
  uint64_t* my_list = (uint64_t *) svGetArrayPtr(db);
  ListDb<>::inst()->setList(name,size, my_list);
}

int svdpi_get_num_taken(const char* name)
{
  return ListDb<>::inst()->getNumberOfItems(name);
}
