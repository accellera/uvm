
UVM Tests Library


1.0 Where are the tests?

Each test is located in separate directories named
"NNgroupname/MMtestname" where "NN" and MM are two-digit numbers,
"groupname" refers to the name of a group of tests, and "testname" is
the name of a particular testcase.

Each testcase is located in the file
"NNgroupname/MMtestname/test.sv". It may include some other files
located in (or relative to) the same directory as necessary.


1.1 What are these 2-digit numeric prefixes?

They are designed to automatically order the tests in a logical order
of execution based on the alphanumerical order of the directory
names. The higher the 2-digit numbers, the later the test will run.

The first test to be run is named "00basic/00hello/test.sv". The last
test to be run is "99final/99final/test.sv".

Simple tests within a group should be located in a directory with a
low 2-digit number. A group of testcases related to more basic
features should be located in a directory with a low 2-digit number.


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



3.0 How do I write a test?

The test must be written in a class named "test" extended from
"uvm_test".

The test must be ENTIRELY self-checking. If is is succesful, it MUST
produce the string "TEST PASS" somewhere in its output log file.

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


3.1 How do I write a test that must fail with a run-time error?

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

