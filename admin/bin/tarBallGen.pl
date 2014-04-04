#!/usr/bin/perl -w
use strict;

#################################
# PLEASE READ
# The following is a quick hack to generate the tarball 
# Until it is made more "sophisticated", please uncomment the following lines
# to appropriate values, comment the die message below and go ahead.
#
#
# ./tarBallGen.pl <branch> <RC-label> <directory-prefix> <sf-user>
#
# ./tarBallGen.pl UVM_1_1_d RC7 uvm-1.1d

my $tag = undef;
my $rc = undef;
my $prefix = undef;
my $branch = undef;
my $user = undef;

$branch       =        $ARGV[0]; #"UVM_1_1_d";
$rc        =           $ARGV[1]; #"RC7";
$prefix    =           $ARGV[2]; # "uvm-1.1d";
$tag       =           "$branch\_RELEASE";
$user = $ARGV[3];

#my $debug  =           1; # Do everything except push if TRUE
my $debug  =           0; # Do everything except push if TRUE
#die "Please set params above\n";

##################################

my $tar = "${prefix}_$rc.tar.gz";

die "uvm already exists" if (-e "uvm");
die "$tar already exists" if -e $tar;

my $cmd = "git clone ssh://${user}\@git.code.sf.net/p/uvm/code uvm";
system ("echo $cmd"); system ("$cmd");

chdir "uvm" or die "Failed to cd uvm\n";

$cmd = "git checkout -b $branch origin/$branch";
system ("echo $cmd"); system ("$cmd");

my $rbranch = "$tag\_$rc\_WITHHTMLDOC";

# Tag the release
$cmd = "git tag -f -a -m \"Release candidate with tag $tag\" $tag;";
system ("echo $cmd"); system ("$cmd") unless $debug;

# Now generate the docs in a separate branch
$cmd = "git checkout -b $rbranch";
system ("echo $cmd"); system ("$cmd");

$ENV{ND} = "$ENV{'PWD'}/uvm/natural_docs";
chdir  "uvm_ref/nd" or die "Failed to cd to uvm_ref/nd";

$cmd = "./gen_nd";
system ("echo $cmd"); system ("$cmd");

chdir "$ENV{'PWD'}/uvm/distrib/docs" or die "Failed to cd to ../../distrib/docs";

$cmd = "git add html;  git commit -m \"commited docs for $tag\"";
system ("echo $cmd"); system ("$cmd");

chdir ".." or die "Failed to cd to .. (distrib)";

# remove because sf forbids non-forward pushs
system("git push origin :refs/heads/$rbranch");

$cmd = "git push --force origin refs/heads/$rbranch";
system ("echo $cmd"); system ("$cmd") unless $debug;

# Tag the release with doc
$cmd = "git tag -f -a -m \"Release candidate with tag $tag\" $rbranch;";
$cmd .= "git push  --tags --force origin;";
system ("echo \"$cmd\""); system ("$cmd") unless $debug;

# Generate the tarball
$cmd = "git archive --format tar.gz --prefix=$prefix/  refs/tags/$rbranch > ../../$tar";
system ("echo $cmd"); system ("$cmd");

print "Tarball ready: $tar\n";


