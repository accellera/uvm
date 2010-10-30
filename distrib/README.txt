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

Installation of UVM requires first unpacking the kit in a convenient
location.

    % mkdir path/to/convenient/location
    % cd path/to/convenient/location
    % gunzip -c path/to/UVM/distribution/tar.gz | tar xvf -

You should define the $UVM_HOME environment variable to that
convenient location using an absolute path name. The following
instructions assume that this variable is appropriately set.

   % setenv UVM_HOME /absolute/path/to/convenient/location

You must then obtain from your SystemVerilog tool vendor a tool-specific
distribution overlay. That overlay may be specific to the machine
architecture and/or operating system you are using. Make sure you provide
the output of the '$UVM_HOME/bin/uvm_os_name' script as well as the version
of the simulator you are using when requesting a UVM overlay from your vendor.

            % $UVM_HOME/bin/uvm_os_name
   IUS:     % irun -version
   Questa:  % vlog -version
   VCS:     % vcs -ID

Follow the installation instructions provided by your tool vendor for
installing the overlay in your UVM installation.

Note to EDA vendors: to support multiple tool-specific overlays in the
same UVM distribution, please locate any tool-specific files in a
tool-specific sub-directory.


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
