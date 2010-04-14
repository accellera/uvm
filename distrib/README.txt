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

Installation of UVM requires only unpacking the kit in a convenient
location.  No additional installation procedures or scripts are
necessary.

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

------------------------------------------------------------------------
