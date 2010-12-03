##---------------------------------------------------------------------- 
##   Copyright 2010 Synopsys, Inc. 
##   Copyright 2010 Verilab, Inc. 
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

#
# VCSi-Specific test running script
#

#
# Make sure the version of VCSi can run these tests
#
$vcs_bin = "vcsi";

# Redefine $tool so it points to VCS so as not to break things like
# file names for compile arguments (vcs.comp.args) used in the main
# body of run_tests.
$tool = "vcs";

$libdir =~ s|/tools/vcsi/|/tools/vcs/|;
if (! -e $libdir) {
   print STDERR "Tool-specific library \"$libdir\" does not exists.\n";
   exit(1);
}
unshift(@INC, $libdir);

require "run_test.pl";

1;
