eval 'exec perl -S $0 ${1+"$@"}' 
if 0;

use strict;
use warnings;
use Getopt::Long;
use File::Basename;

sub Usage {
    print "\n\nScript usage is as follows:\n";
    print "\n\t".basename($0 )." [--help] <list_of_commit_ids> \n\n";
    print "\tThis will generate teh following:\n";
    print "\t\tlist of DIFF-<commit_id> files\n";
    print "\t\tDIFF.<branchname> file that lists all the diffs since this branch was created\n";
    print "\n\n";
}

my $help = 0;

if (!GetOptions ('help+' => \$help) ) {
    print "\nIncorrect usage of script. \n";  
    Usage; 
    die; 
}


if ($help != 0)
{
    Usage();
    exit;
}

foreach my $commitId (@ARGV) {
    print "===========================================\n";
    print "DIFF for commit id: $commitId is as follows\n";

    my $cmd = "git diff $commitId^..$commitId";
    $cmd .= " > DIFF-$commitId";
    print $cmd,"\n";

    system($cmd);
    print "===========================================\n";
    
}


my $branchName = `git rev-parse --abbrev-ref HEAD`;

my $cmd = "echo FOLLOWING COMMITS ARE IN THIS BRANCH: > DIFF.$branchName";
system($cmd);
my $pre = `git merge-base HEAD master`;
chomp($pre);
$cmd = "git log --oneline $pre..HEAD";
$cmd .= " >> DIFF.$branchName";
system($cmd);
system("echo ==================================== >> DIFF.$branchName");
$cmd = "git diff $pre..HEAD";
$cmd .= " >> DIFF.$branchName";

system($cmd);

