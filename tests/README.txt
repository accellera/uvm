
UVM Tests Library


1.0 Where are the tests?

Each test is located in separate directories named
"NNgroupname/MMtestname" where "NN" and MM are two-digit numbers,
"groupname" refers to the name of a group of tests, and "testname" is
the name of a particular testcase.

Each testcase is located in the file
"NNgroupname/MMtestname/test.sv". It may include some other files
located in (or relative to) the same directory as necessary.

For more complex sets of features, there may be subgroups (and
sub-subgroups and sub-sub-subgroup etc) of tests, using the same
numeric ordering convention
(e.g. NNgroup/MMsubgroup/KKsubsubgroup/IItestname/test.sv).


1.1 What are these 2-digit numeric prefixes?

They are designed to automatically order the tests in a logical order
of execution based on the alphanumerical order of the directory
names. The higher the 2-digit numbers, the later the test will run.

The first test to be run is named "00basic/00hello/test.sv". The last
test to be run is "99final/99final/test.sv".

Simple tests within a group should be located in a directory with a
low 2-digit number. A group of testcases related to more basic
features should be located in a directory with a low 2-digit number.


1.2 What is the XXfail test group?

It is a group of test designed to test the failure detected mechanism
of the run_tests script. These tests are not run by default and can only
be run by explicitly specifying the test group to the run_tests script.

Note that these tests will not fail when using the "clean" or "echo"
pseudo tools.

Example:

   % run_test vcs XXfail



2.0 How do I run a test

First, you must be in the "tests" directory.

A single test can be run on a specific tool by using the "run_tests"
script, specifying the name of the tool to use and directory that
contains the "test.sv" file.

Example:

   % run_test echo 00basic/00hello


2.1 How do I run multiple tests

First, you must be in the "tests" directory.

A series of tests can be run on a specific tool by using the
"run_tests" script and specifying the name of the tool to use and the
test directories to run.

Example:

   % run_tests echo 00basic
   % run_tests echo 00basic 34somegroup/45sometest

If no test directories are specified, all of the tests are run.


2.2 What is the "echo" tool?

It is a dummy simulation that simply creates a "pass" condition in the
"echo.log" file.


2.3 What is the "clean" tool?

It is a dummy simulation that simply deletes all "*.log" files and
other temporary files often left behind by text editors, such as "*~"
files.

It does not delete temporary or output files created by
simulators. Use the the '-c' option with the specific tool name for
that.

Example:

   % run_tests -c echo


2.4 How do I debug a failing test?

Re-run the testcase using the '-d' and '-v' options. This will leave
behind all files created by the simulation tool and display the result
of the simulation to stdout, in addition to the usual log file.


2.5 How do I simulate only the previously-failing tests?

A list of tests that were identified as failing is automatically written
to a file named "tool.fails". To re-run only those tests (presumably after
fixing the cause of failure), specify that file using the -f option.

Rinse. Repeat.

Example:

   % run_tests vcs
   % <edit>
   % run_tests -f vcs.fails vcs
   % <edit>
   % run_tests -f vcs.fails vcs
   % run_tests vcs  # Make sure nothing else broke


3.0 How do I write a test?

The test must be written in a class named "test" extended from
"uvm_test".

The test must be ENTIRELY self-checking. If is is succesful, it MUST
produce the string "UVM TEST PASSED" somewhere in its output log file.
If the string "UVM TEST FAILED" is seen anywhere in the output log
file, the test is immediately declared a failure.

The test may be module-based or program-based.

The package containing the UVM library will have been previously
compiled. However, may need to be imported.

Make sure all testcase source files contain the Apache 2.0 copyright
statement header. If you modify a source file, add your copyright
claim to the copyright statement header.


3.1 How do I write a test that must fail with a compile-time error?

If the objective of the test is to make sure that a compile-time error
is detected, implement the test as per the above and add the following
line comment on the line(s) where the compile-time error is(are)
expected:

   // UVM TEST COMPILE-TIME FAILURE

See the test 00basic/01compfail for an example.


3.2 How do I write a test that must fail with a run-time error?

If the run-time error is reported using the UVM report mechanism,
use the Report Catcher mechanism to trap the error at run-time an
implement the test normally.

See the test ?? for an example.

If the objective of the test is to make sure that a run-time error is
detected by the simulator, implement the test as per the above and
add the following line comment on the line(s) where the run-time
error is(are) expected:

   // UVM TEST RUN-TIME FAILURE

See the test 00basic/02runfail for an example.


3.3 How do I write a test that produces external output?

If the output of the test cannot be caught at run-time and must be
checked after the test has completed (e.g. to check the content of an
output file), it is necessary to use a post-processing step to determine
the correctness of the testcase.

If the file "post_test.pl" is found in the testcase directory, it is
executed instead of the normal testcase checking process, immediately
after the presence of the run-time log file has been ascertained.

The correctness of the testcase is then determined by the value of the
last expression executed in that file. If it is "0", then the test is
assumed to have passed. Otherwise, the test is assumed to have failed.

The script may set the variable $post_test to a short description of
the cause of failure or success.

The script will find the name of the run-time log file in the $log
variable and the name of the testcase in the $testdir variable. The
script runs in the same context (i.e. variables & working directory) as
the run_tests script.


3.4 How do I write a test that runs a script?

The preferred implementation for a test is in pure SV code in a file
named "test.sv". Sometimes, that is not possible and a script must be
run instead.

If the file "test.pl" is found in the testcase directory INSTEAD of
the file "test.sv", it is executed instead of the normal testcase
execution process.

The testcase is executed by do'ing the script. The correctness of
the testcase is determined by the value of the last expression
executed in that file. If it is "0", then the test is assumed to have
passed. Otherwise, the test is assumed to have failed.

The script may set the variable $post_test to a short description of
the cause of failure or success.

The script will find the name of the tool to use in the $tool
variable, the name of the run-time log file in the $log variable and
the name of the testcase in the $testdir variable. The script runs in
the same context (i.e. variables & working directory) as the run_tests
script.


3.5 How do I pass additional command-line arguments?

If this is a transient need (e.g. for debugging, use the -C or -R
command-line option of the run_tests script to pass compile-time and
run-time command-line options to the underlying tool.

If these arguments are required by a specific tool, add compile-time
and run-time options in a file named "tool.comp.args" or
"tool.run.args" respectively in the test directory, where "tool" is
the name of the underlying tool used.

If these are compile-time "plus-defines" or run-time "plusargs"
required to be used by all tools, add them to the "test.defines" or
"test.plusargs" files respectively in the test directory.
