#!/bin/sh
##
##   Copyright 2007-2010 Mentor Graphics Corporation
##   Copyright 2007-2011 Cadence Design Systems, Inc. 
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

rm -fr some_ve *.patch *.tar.gz *.diff
cp -fr ovm_sources  some_ve
chmod -R +rw some_ve


$UVM_HOME/bin/ovm2uvm.pl --top_dir ./some_ve --marker "XX-REVIEW-XX" --write --backup --all_text_files

diff some_ve uvm_sources.golden > /dev/null

