##----------------------------------------------------------------------
##   Copyright 2010 Synopsys, Inc.
##   All Rights Reserved Worldwide
##
##   Licensed under the Apache License, Version 2.0 (the
##   "License"); you may not use this file except in
##   compliance with the License.  You may obtain a copy of
##   the License at
##
##       http://www.apache.org/licenses/LICENSE-2.0
##
##   Unless required by applicable law or agreed to in
##   writing, software distributed under the License is
##   distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
##   CONDITIONS OF ANY KIND, either express or implied.  See
##   the License for the specific language governing
##   permissions and limitations under the License.
##----------------------------------------------------------------------

TOOL	?= error

UVM_HOME = .

OS	= $(shell $(UVM_HOME)/bin/uvm_os_name)

SRCDIR	= $(UVM_HOME)/src/C
LIBDIR	= $(UVM_HOME)/lib/$(OS)
SONAME	= libuvm_$(TOOL).so

CC	= gcc
CFLAGS	+= -shared -fPIC


SRCS	= $(SRCDIR)/uvm_hdl.c


ifeq ($(TOOL),error)
all install:
	@echo "\$$(TOOL) variable not set."
	@echo "Use one of:"
	@echo "   make TOOL=questa"
	@echo "   make TOOL=ius"
	@echo "   make TOOL=vcs"
else
all install: $(LIBDIR)/$(SONAME)
endif


ifeq ($(TOOL),questa)
CFLAGS += -DQUESTA -I$(MTI_HOME)/include -m32
CC = $(MTI_HOME)/gcc-4.1.2-linux/bin/gcc
endif

ifeq ($(TOOL),ius)
CFLAGS += -DNCSIM -I`ncroot`/tools/include
endif

ifeq ($(TOOL),vcs)
CFLAGS += -DVCS -I $(VCS_HOME)/include -m32
endif


#
# this has to $UVMHOME/lib/$arch$/libuvm_$tool.so
# (otherwise we could not have multiple $arch$ supported in a single UVM install
#
# the lib/*.so should be removed
#
$(LIBDIR)/$(SONAME): $(LIBDIR) $(SRCS)
	mkdir -p $(LIBDIR)
	$(CC) $(CFLAGS) -o $(LIBDIR)/$(SONAME) $(SRCS)
	@rm -f $(UVM_HOME)/lib/$(SONAME)
	(cd lib && ln -sf $(OS)/$(SONAME))

$(LIBDIR):
	mkdir -p $(LIBDIR)


clean:
	rm -rf $(LIBDIR)/libuvm_*.so

distclean realclean allclean squeakyclean: clean
	rm -rf $(LIBDIR)
