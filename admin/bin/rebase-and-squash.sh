#!/bin/sh
# uwes@cadence.com
# get the branch (MY branch id like to have merged into BUGFIX)

branch=$1
upstream=$2

# rebase it on the bugfix branch especially it came from some other point
git rebase $upstream $branch

# now squash all commits into ONE commit
# to do that edit in the editor which opens as follows: topmost line keep as is, other non-comment lines change "pick" to "s" 
git rebase -i $upstream $branch

# now submit this patch for review and inclusion
#git push tr:uvm HEAD:refs/for/UVM_1_1_BUGFIX

