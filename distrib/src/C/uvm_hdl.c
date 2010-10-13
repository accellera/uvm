//----------------------------------------------------------------------
//   Copyright 2007-2008 Cadence Design Systems, Inc.
//   Copyright 2009-2010 Mentor Graphics, Inc.
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

#include "vpi_user.h"
#include "veriuser.h"
#include "svdpi.h"
#include <malloc.h>


/* 
 * UVM HDL access C code.
 *
 * This code is not strictly associated with the
 * UVM register library. It is used by the UVM register
 * library to gain access to internal simulator variables.
 *
 */

/*
 * This C code checks to see if there is PLI handle
 * with a value set to define the maximum bit width.
 *
 * If no such variable is found, then the default 
 * width of 1024 is used.
 *
 * This function should only get called once or twice,
 * its return value is cached in the caller.
 *
 */
static int uvm_hdl_max_width()
{
  vpiHandle ms;
  s_vpi_value value_s = { vpiIntVal };
  ms = vpi_handle_by_name(
        "uvm_pkg::UVM_HDL_MAX_WIDTH", 0);
  if(ms == 0) 
    return 1024;  /* If nothing else is defined, 
                     this is the DEFAULT */
  vpi_get_value(ms, &value_s);
  return value_s.value.integer;
}

/*
 * Given a path, look the path name up using the PLI,
 * and set it to 'value'.
 */
static int uvm_hdl_set_vlog(char *path, p_vpi_vecval *value, PLI_INT32 flag)
{
  static int maxsize = -1;
  int i, size, chunks;
  vpiHandle r;
  s_vpi_value value_s;
  p_vpi_vecval value_p;
  s_vpi_time  time_s = { vpiSimTime, 0, 0 };

  r = vpi_handle_by_name(path, 0);
  if(r == 0)
  {
    vpi_printf("ERROR UVM : unable to locate hdl path (%s)\n",path);
    vpi_printf(" Either the name is incorrect, or you may not have PLI/ACC visibility to that name\n");
    return 0;
  }
  else
  {
    if(maxsize == -1) 
        maxsize = uvm_hdl_max_width();

// Code for Questa & VCS
// ---------------------
#ifndef NCSIM
    if (flag == vpiReleaseFlag) {
      //size = vpi_get(vpiSize, r);
      //value_p = (p_vpi_vecval)(malloc(((size-1)/32+1)*8*sizeof(s_vpi_vecval)));
      //value = &value_p;
    }
    value_s.format = vpiVectorVal;
    value_s.value.vector = *value;
    vpi_put_value(r, &value_s, &time_s, flag);  
    //if (value_p != NULL)
    //  free(value_p);
    if (value == NULL) {
      *value = value_s.value.vector;
    }
  }
#ifndef VCS
  vpi_release_handle(r);
#endif
  return 1;
}

// Code for NC
// ---------------------
#else
    size = vpi_get(vpiSize, r);
    if(size > maxsize)
    {
      vpi_printf("ERROR UVM : hdl path '%s' is %0d bits,\n", path, size);
      vpi_printf(" but the maximum size is %0d, redefine using a compile\n", maxsize);
      vpi_printf(" flag. i.e. %s\n", "vlog ... +define+UVM_HDL_MAX_WIDTH=<value>\n");
#ifndef VCS
      vpi_release_handle(r);
#endif
      return 0;
    }
    chunks = (size-1)/32 + 1;
    // Probably should be:
    //   value_p = (p_vpi_vecval)(calloc(1, chunks*8*sizeof(s_vpi_vecval)));
    value_p = (p_vpi_vecval)(malloc(chunks*8*sizeof(s_vpi_vecval)));
    value_s.format = vpiVectorVal;
    value_s.value.vector = value_p;
    /* Copy a/b, reversing on NC. */
    /*dpi and vpi are reversed*/
    for(i=0;i<chunks; ++i)
    {
      // Reverse a/b on NC.
      // FIXME 
#warning("FIXME VPI not functional");

      //      value_p[i].aval = value[i].bval;
      //      value_p[i].bval = value[i].aval;
    }
    vpi_put_value(r, &value_s, &time_s, flag);  
    free (value_p);
  }
#ifndef VCS
  vpi_release_handle(r);
#endif
  return 1;
}
#endif


/*
 * Given a path, look the path name up using the PLI
 * and return its 'value'.
 */
static int uvm_hdl_get_vlog(char *path, p_vpi_vecval value, PLI_INT32 flag)
{
  static int maxsize = -1;
  int i, size, chunks;
  vpiHandle r;
  s_vpi_value value_s;

  r = vpi_handle_by_name(path, 0);
  if(r == 0)
  {
    vpi_printf("ERROR UVM : unable to locate hdl path %s\n", path);
    vpi_printf(" Either the name is incorrect, or you may not have PLI/ACC visibility to that name\n");
    // Exiting is too harsh. Just return instead.
    // tf_dofinish();
    return 0;
  }
  else
  {
    if(maxsize == -1) 
        maxsize = uvm_hdl_max_width();

    size = vpi_get(vpiSize, r);
    if(size > maxsize)
    {
      vpi_printf("ERROR UVM_register : hdl path '%s' is %0d bits,\n",path,size);
      vpi_printf(" but the maximum size is %0d, redefine using a compile\n",maxsize);
      vpi_printf(" flag. i.e. %s\n", "vlog ... +define+UVM_HDL_MAX_WIDTH=<value>\n");
      //tf_dofinish();
#ifndef VCS
      vpi_release_handle(r);
#endif
      return 0;
    }
    chunks = (size-1)/32 + 1;

    value_s.format = vpiVectorVal;
    vpi_get_value(r, &value_s);
    /*dpi and vpi are reversed*/
    for(i=0;i<chunks; ++i)
    {
#ifdef NCSIM
      // Code for NC.
      // Reverse a/b on NC.
      value[i].aval = value_s.value.vector[i].bval;
      value[i].bval = value_s.value.vector[i].aval;
#else
      // Code for Questa & VCS
      value[i].aval = value_s.value.vector[i].aval;
      value[i].bval = value_s.value.vector[i].bval;
#endif
    }
  }
#ifndef VCS
  vpi_release_handle(r);
#endif
  return 1;
}


/*
 * Given a path, look the path name up using the PLI,
 * but don't set or get. Just check.
 *
 * Return 0 if NOT found.
 * Return 1 if found.
 */
int uvm_hdl_check_path(char *path)
{
  vpiHandle r = vpi_handle_by_name(path, 0);
  if(r == 0)
      return 0;
  else 
    return 1;
#ifndef VCS
  vpi_release_handle(r);
#endif
}


/*
 * Given a path, look the path name up using the PLI
 * or the FLI, and return its 'value'.
 */
int uvm_hdl_read(char *path, p_vpi_vecval value)
{
    return uvm_hdl_get_vlog(path, value, vpiNoDelay);
}

/*
 * Given a path, look the path name up using the PLI
 * or the FLI, and set it to 'value'.
 */
int uvm_hdl_deposit(char *path, p_vpi_vecval value)
{
    return uvm_hdl_set_vlog(path, &value, vpiNoDelay);
}


/*
 * Given a path, look the path name up using the PLI
 * or the FLI, and set it to 'value'.
 */
int uvm_hdl_force(char *path, p_vpi_vecval value)
{
    return uvm_hdl_set_vlog(path, &value, vpiForceFlag);
}


/*
 * Given a path, look the path name up using the PLI
 * or the FLI, and release it.
 */
int uvm_hdl_release_and_read(char *path, p_vpi_vecval value)
{
    return uvm_hdl_set_vlog(path, &value, vpiReleaseFlag);
}

/*
 * Given a path, look the path name up using the PLI
 * or the FLI, and release it.
 */
int uvm_hdl_release(char *path)
{
  s_vpi_vecval value;
  p_vpi_vecval valuep = &value;
  return uvm_hdl_set_vlog(path, &valuep, vpiReleaseFlag);
}
