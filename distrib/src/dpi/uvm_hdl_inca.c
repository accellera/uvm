//----------------------------------------------------------------------
//   Copyright 2007-2013 Cadence Design Systems, Inc.
//   Copyright 2009-2010 Mentor Graphics Corporation
//   Copyright 2010-2011 Synopsys, Inc.
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

#include "vhpi_user.h"
#include "vpi_user.h"
#include "veriuser.h"
#include "svdpi.h"
#include <malloc.h>
#include <string.h>
#include <stdio.h>


/* 
 * UVM HDL access C code.
 *
 */
static int is_verilog(char* path)
{
  vhpiHandleT r = vhpi_handle_by_name(path, 0);

  vpi_printf("handle is %x\n",r);

  if(r == 0)
  {
    return 1;
  }

  if(vhpi_get(vhpiLanguageP, r) == vhpiVerilog) return 1;
  else return 0;
}


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
  s_vpi_value value_s = { vpiIntVal, { 0 } };
  ms = vpi_handle_by_name(
      (PLI_BYTE8*) "uvm_pkg::UVM_HDL_MAX_WIDTH", 0);
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
static int uvm_hdl_set_vlog(char *path, p_vpi_vecval value, PLI_INT32 flag)
{
  static int maxsize = -1;
  vpiHandle r;
  s_vpi_value value_s = { vpiIntVal, { 0 } };
  s_vpi_time  time_s = { vpiSimTime, 0, 0, 0.0 };

  r = vpi_handle_by_name(path, 0);

  if(r == 0)
  {
      const char * err_str = "set: unable to locate hdl path (%s)\n Either the name is incorrect, or you may not have PLI/ACC visibility to that name";
      char buffer[strlen(err_str) + strlen(path)];
      sprintf(buffer, err_str, path);
      m_uvm_report_dpi(M_UVM_ERROR,
                       (char*) "UVM/DPI/HDL_SET",
                       &buffer[0],
                       M_UVM_NONE,
                       (char*) __FILE__,
                       __LINE__);
    return 0;
  }
  else
  {
    if(maxsize == -1) 
        maxsize = uvm_hdl_max_width();

    if (flag == vpiReleaseFlag) {
      //size = vpi_get(vpiSize, r);
      //value_p = (p_vpi_vecval)(malloc(((size-1)/32+1)*8*sizeof(s_vpi_vecval)));
      //value = &value_p;
    }
    value_s.format = vpiVectorVal;
    value_s.value.vector = value;
    vpi_put_value(r, &value_s, &time_s, flag);  
    //if (value_p != NULL)
    //  free(value_p);
    if (value == NULL) {
      value = value_s.value.vector;
    }
  }

  vpi_release_handle(r);

  return 1;
}

static int uvm_hdl_set_vhdl(char* path, p_vpi_vecval value, PLI_INT32 flag)
{
  static int maxsize = -1;
  int size, chunks, bit, i, j, aval, bval;
  vhpiValueT value_s;
  vhpiHandleT r = vhpi_handle_by_name(path, 0);

  if(maxsize == -1) maxsize = uvm_hdl_max_width();
  if(maxsize == -1) maxsize = 1024;

  size = vhpi_get(vhpiSizeP, r);
  if(size > maxsize)
  {
    //vpi_printf("*F,regmem : hdl path %s is %0d bits, but the maximum size is %0d, redefine using -define RGM_DWIDTH=<value>  \n", vhpi_get_str(vhpiFullNameP,r), size,maxsize);
    vpi_printf((PLI_BYTE8*) "UVM_ERROR: uvm_reg : hdl path '%s' is %0d bits,\n",path,size);
    vpi_printf((PLI_BYTE8*) " but the maximum size is %0d. You can increase the maximum\n",maxsize);
    vpi_printf((PLI_BYTE8*) " via a compile-time flag: +define+UVM_HDL_MAX_WIDTH=<value>\n");

    // FIXME report via uvm 

    tf_dofinish();
  }
  chunks = (size-1)/32 + 1;

  value_s.format = vhpiObjTypeVal;
  value_s.bufSize = 0;
  value_s.value.str = NULL;

  vhpi_get_value(r, &value_s);

  switch(value_s.format)
  {
    case vhpiEnumVal:
    {
      if(value[0].bval == 0)
      {
        if(value[0].aval == 0)
        {
          value_s.value.enumv = vhpi0;
        }
        else
        {
          value_s.value.enumv = vhpi1;
        }
      }
      else
      {
        if(value[0].aval == 0)
        {
          value_s.value.enumv = vhpiZ;
        }
        else
        {
          value_s.value.enumv = vhpiX;
        }
      }
      break;
    }
    case vhpiEnumVecVal:
    {
      value_s.bufSize = size*sizeof(int); 
      value_s.value.enumvs = (vhpiEnumT *)malloc(size*sizeof(int));

      vhpi_get_value(r, &value_s);
      chunks = (size-1)/32 + 1;

      bit = 0;
      for(i=0;i<chunks && bit<size; ++i)
      {
        aval = value[i].aval;
        bval = value[i].bval;

        for(j=0;j<32 && bit<size; ++j)
        {
          if( (aval&1) == 0 && (bval&1) == 0 )
          {
            value_s.value.enumvs[size-bit-1] = vhpi0;
          }
          else if( (aval&1) == 1 && (bval&1) == 0 )
          {
            value_s.value.enumvs[size-bit-1] = vhpi1;
          }
          else if( (aval&1) == 0 && (bval&1) == 1 )
          {
            value_s.value.enumvs[size-bit-1] = vhpiX;
          }
          else
          {
            value_s.value.enumvs[size-bit-1] = vhpiZ;
          }
          aval>>=1; bval>>=1;
          bit++;
        }
      }
      break;
    }
    default:
    {
      // FIXME report via UVM
      vpi_printf((PLI_BYTE8*) "UVM_ERROR: uvm_reg : Failed to set value to hdl path %s (unexpected type: %0d)\n", vhpi_get_str(vhpiFullNameP,r), value_s.format);
       tf_dofinish();
       return 0;
    }
  }

  if(flag)
    vhpi_put_value(r, &value_s, vhpiForcePropagate);  
  else
    vhpi_put_value(r, &value_s, vhpiDepositPropagate);  
  if(value_s.format == vhpiEnumVecVal)
  {
    free(value_s.value.enumvs);
  }
  return 1;
}

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
      const char * err_str = "get: unable to locate hdl path (%s)\n Either the name is incorrect, or you may not have PLI/ACC visibility to that name";
      char buffer[strlen(err_str) + strlen(path)];
      sprintf(buffer, err_str, path);
      m_uvm_report_dpi(M_UVM_ERROR,
                       (char*) "UVM/DPI/HDL_GET",
                       &buffer[0],
                       M_UVM_NONE,
                       (char*) __FILE__,
                       __LINE__);
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
      const char * err_str = "uvm_reg : hdl path '%s' is %0d bits, but the maximum size is %0d.  You can increase the maximum via a compile-time flag: +define+UVM_HDL_MAX_WIDTH=<value>";
      char buffer[strlen(err_str) + strlen(path) + (2*int_str_max(10))];
      sprintf(buffer, err_str, path, size, maxsize);
      m_uvm_report_dpi(M_UVM_ERROR,
                       (char*) "UVM/DPI/HDL_SET",
                       &buffer[0],
                       M_UVM_NONE,
                       (char*) __FILE__,
                       __LINE__);
      //tf_dofinish();

      vpi_release_handle(r);

      return 0;
    }
    chunks = (size-1)/32 + 1;

    value_s.format = vpiVectorVal;
    vpi_get_value(r, &value_s);
    /*dpi and vpi are reversed*/
    for(i=0;i<chunks; ++i)
    {
      value[i].aval = value_s.value.vector[i].aval;
      value[i].bval = value_s.value.vector[i].bval;
    }
  }
  //vpi_printf("uvm_hdl_get_vlog(%s,%0x)\n",path,value[0].aval);

  vpi_release_handle(r);

  return 1;
}

static int uvm_hdl_get_vhdl(char* path, p_vpi_vecval value, PLI_INT32 flag)
{
  static int maxsize = -1;
  int i, j, size, chunks, bit, aval, bval, rtn;
  vhpiValueT value_s;
  vhpiHandleT r = vhpi_handle_by_name(path, 0);

  if(maxsize == -1) maxsize = uvm_hdl_max_width();
  if(maxsize == -1) maxsize = 1024;

  size = vhpi_get(vhpiSizeP, r);
  if(size > maxsize)
  {
    // FIXME reroute to UVM
    //vpi_printf("*F,regmem : hdl path %s is %0d bits, but the maximum size is %0d, redefine using -define RGM_DWIDTH=<value>  \n", vhpi_get_str(vhpiFullNameP,r), size,maxsize);
    vpi_printf((PLI_BYTE8*) "UVM_ERROR: uvm_reg : hdl path '%s' is %0d bits,\n",path,size);
    vpi_printf((PLI_BYTE8*) " but the maximum size is %0d. You can increase the maximum\n",maxsize);
    vpi_printf((PLI_BYTE8*) " via a compile-time flag: +define+UVM_HDL_MAX_WIDTH=<value>\n");
    tf_dofinish();
  }
  chunks = (size-1)/32 + 1;
  value_s.format = vhpiObjTypeVal;
  value_s.bufSize = 0;
  value_s.value.str = NULL;

  rtn = vhpi_get_value(r, &value_s);

  if(vhpi_check_error(0) != 0) 
  {
    // FIXME reroute to uvm
    //vpi_printf("*F,regmem : Failed to get value from hdl path %s\n", vhpi_get_str(vhpiFullNameP,r));
    vpi_printf((PLI_BYTE8*) "UVM_ERROR: uvm_reg : Failed to get value from hdl path %s\n",path);
    tf_dofinish();
    return 0;
  }

  switch (value_s.format)
  {
     case vhpiIntVal:
     {
       value[0].aval = value_s.value.intg;
       value[0].bval = 0;
       break;
     }
     case vhpiEnumVal:
     {
       switch(value_s.value.enumv)
       {
         case vhpiU: 
         case vhpiW: 
         case vhpiX: 
         {
           value[0].aval = 1; value[0].bval = 1; break;
         }
         case vhpiZ: 
         {
           value[0].aval = 0; value[0].bval = 1; break;
         }
         case vhpi0: 
         case vhpiL: 
         case vhpiDontCare: 
         {
           value[0].aval = 0; value[0].bval = 0; break;
         }
         case vhpi1: 
         case vhpiH: 
         {
           value[0].aval = 1; value[0].bval = 0; break;
         }
       }
       break;
     }
     case vhpiEnumVecVal:
     {
       value_s.bufSize = size;
       value_s.value.str = (char*)malloc(size);
       rtn = vhpi_get_value(r, &value_s);
       if (rtn > 0) {
         value_s.value.str = (char*)realloc(value_s.value.str, rtn);
         value_s.bufSize = rtn;
         vhpi_get_value(r, &value_s);
       }
       for(i=0; i<((maxsize-1)/32+1); ++i)
       {
         value[i].aval = 0;
         value[i].bval = 0;
       }
       bit = 0;
       for(i=0;i<chunks && bit<size; ++i)
       {
         aval = 0;
         bval = 0;
         for(j=0;(j<32) && (bit<size); ++j)
         {
           aval<<=1; bval<<=1;
           switch(value_s.value.enumvs[bit])
           {
             case vhpiU: 
             case vhpiW: 
             case vhpiX: 
             {
               aval |= 1;
               bval |= 1;
               break;
             }
             case vhpiZ: 
             {
               bval |= 1;
               break;
             }
             case vhpi0: 
             case vhpiL: 
             case vhpiDontCare: 
             {
               break;
             }
             case vhpi1: 
             case vhpiH: 
             {
               aval |= 1;
               break;
             }
           }
           bit++;
         }
         value[i].aval = aval;
         value[i].bval = bval;
         free (value_s.value.str);
       }
       break;
     }
     default:
     {
       // FIXME reroute to uvm
       //vpi_printf("*F,regmem : Failed to get value from hdl path %s (unexpected type: %0d)\n", vhpi_get_str(vhpiFullNameP,r), value_s.format);
       vpi_printf((PLI_BYTE8*) "UVM_ERROR: uvm_reg : Failed to get value from hdl path %s (unexpected type: %0d)\n", path, value_s.format);
       tf_dofinish();
       return 0;
     }
  }
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
  vpiHandle r;
  r = vpi_handle_by_name(path, 0);

  if(r == 0)
      return 0;
  else 
    return 1;
}


/*
 * Given a path, look the path name up using the PLI
 * or the FLI, and return its 'value'.
 */
int uvm_hdl_read(char *path, p_vpi_vecval value)
{
  if(is_verilog(path)) return uvm_hdl_get_vlog(path, value, vpiNoDelay);
  else return uvm_hdl_get_vhdl(path, value, vpiNoDelay);
}

/*
 * Given a path, look the path name up using the PLI
 * or the FLI, and set it to 'value'.
 */
int uvm_hdl_deposit(char *path, p_vpi_vecval value)
{
  if(is_verilog(path)) return uvm_hdl_set_vlog(path, value, vpiNoDelay);
  else return uvm_hdl_set_vhdl(path, value, 0);
}


/*
 * Given a path, look the path name up using the PLI
 * or the FLI, and set it to 'value'.
 */
int uvm_hdl_force(char *path, p_vpi_vecval value)
{
  if(is_verilog(path)) return uvm_hdl_set_vlog(path, value, vpiForceFlag);
  else return uvm_hdl_set_vhdl(path, value, vpiForceFlag);
}


/*
 * Given a path, look the path name up using the PLI
 * or the FLI, and release it.
 */
int uvm_hdl_release_and_read(char *path, p_vpi_vecval value)
{
  // FIXME missing
    return uvm_hdl_set_vlog(path, value, vpiReleaseFlag);
}

/*
 * Given a path, look the path name up using the PLI
 * or the FLI, and release it.
 */
int uvm_hdl_release(char *path)
{
  // FIXME missing
  s_vpi_vecval value;
  p_vpi_vecval valuep = &value;
  return uvm_hdl_set_vlog(path, valuep, vpiReleaseFlag);
}

