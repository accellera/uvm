// Where  should this code be placed ?
// Given that this is Multi Language solution
// placing this under UVM is not necessarily the correct solution.
// On the other hand, it should be placed somewhere.
#include <iostream>
#include <inttypes.h>

#include <map>
#include <vector>
#include <string>
#include <assert.h>

/*
class AllocationList
{
get_number_of_items();
set_list()
get_list();

std::vector .,,,;

}
*/
template <typename T = uint64_t> class ListDb;

template <typename T = uint64_t>
class ListHolder
{
public:
  int getNumberOfItems() const;
  void getList(unsigned int numOfItems, T* theList) const;
  void setList(unsigned int numOfItems, const T* theList);

protected:
  std::vector<T> m_content;
  std::string m_name; // it is not neccesary to have it here

  friend class ListDb<T>;
  ListHolder(std::string name) : m_name(name) {}
  ~ListHolder();
};

template <typename T>
class ListDb
{
public:

  int getNumberOfItems(const char* name);
  void getList(const char* name, unsigned int numOfItems, T* theList);
  void setList(const char* name, unsigned int numOfItems, const T* theList);

  static ListDb* inst() { 
    static ListDb* instance = new ListDb;
    return instance; 
  }
  
private:
  // should create be part of user interface or should creation be implicit ???
  ListHolder<T>* getHolder(const char* name);
  std::map<std::string,ListHolder<T>*> m_holders;
  ListDb() {}

};



template <typename T>
int ListHolder<T>::getNumberOfItems() const
{
  return m_content.size();
}

template <typename T>
void ListHolder<T>::getList(unsigned int numOfItems, T* theList) const
{
  assert (numOfItems == m_content.size());
  for (unsigned int i = 0; i < numOfItems; ++i)
    // takenList is allocated by the caller possibly in other domain (for example, Verilog)
    theList[i] = m_content[i];
}

template <typename T>
void ListHolder<T>::setList(unsigned int numOfItems, const T* theList)
{
  m_content.clear();
  for (unsigned int i = 0; i < numOfItems; ++i)
    m_content.push_back(theList[i]);

}

// how should we notify about error ???
template <typename T>
int ListDb<T>::getNumberOfItems(const char* name)
{
  return getHolder(name)->getNumberOfItems();
}

template <typename T>
void ListDb<T>::getList(const char* name, unsigned int numOfItems, T* theList)
{
  getHolder(name)->getList(numOfItems, theList);
}

template <typename T>
void ListDb<T>::setList(const char* name, unsigned int numOfItems, const T* theList)
{
  getHolder(name)->setList(numOfItems, theList);
}


template <typename T>
ListHolder<T>* ListDb<T>::getHolder(const char* name)
{
  ListHolder<T>* holder;
  typename std::map<std::string,ListHolder<T>* >::const_iterator iter = m_holders.find(name);
  if (iter != m_holders.end())
    holder = iter->second;
  else {
    holder = new ListHolder<T>(name);
    m_holders[name] = holder;
  }
  return holder;
}


