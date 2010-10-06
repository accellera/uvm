Accellera Universal Verification Methodology
version 1.0-EA

(C) Copyright 2007-2009 Mentor Graphics Corporation
(C) Copyright 2007-2009 Cadence Design Systems, Incorporated
(C) Copyright 2010 Synopsys Inc.
All Rights Reserved Worldwide

The UVM kit is licensed under the Apache-2.0 license.  The full text of
the licese is provided in this kit in the file LICENSE.txt

Installing the kit
------------------

Installation of UVM requires unpacking the kit in a convenient
location and building the DPI object library for each combination of
simulator and platform you are using.

For each platform/OS:

  - Log in to a machine of the suitable platform/OS
  - Change your working directory to the 'distrib' directory where
    you unpacked the kit

       % cd .../distrib

  - Invoke 'make' for every simulator you use

       % make TOOL=mti
       % make TOOL=nc
       % make TOOL=vcs

The shared library, named 'libuvm_<tool>.so' where "<tool>" is the name of
the simulator specified using the TOOL makefile variable, is found in
the ".../distrib/lib/<os>" directory, where "<os>" is the name of the
platform as returned by the ".../distrib/bin/uvm_os_name" script.

For convenience, a link to the last tool-specific shared library that
was compiled is located in the ".../distrib/lib" directory.


Using the UVM
-------------

You can make the UVM library accessible by your SystemVerilog program by
using either the package technique or the include technique.  To use
packages import uvm_pkg. If you are using the field automation macros
you will also need to include the macro defintions. E.g.

import uvm_pkg::*;
`include "uvm_macros.svh"

To use the include technique you include a single file:

`include "uvm.svh"

You will need to put the location of the UVM source as a include
directory in your compilation command line.

You will need to specify the location of the UVM DPI shared library
to your simulator. This is a simulator-specific specification.
Please refer to your simulator documentation.

------------------------------------------------------------------------
