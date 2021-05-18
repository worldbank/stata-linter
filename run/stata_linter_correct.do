
  * --------------- *
  * Global settings *
  * --------------- *

  * Set the global to folder where test files are stored
  global project 	"D:/Documents/RA Jobs/DIME/analytics/linter/fork/stata-linter"
  global test_dir 	"${project}/test"
  
  * -------------------- *
  * Run example commands *
  * -------------------- *

  * Command only with optional option "replace", which replaces the existing output file
  stata_linter_correct, input("${test_dir}/bad.do") output("${test_dir}/bad_correct.do") replace

  * Command only with optional option "automatic", which does all corrections without asking
  stata_linter_correct, input("${test_dir}/bad.do") output("${test_dir}/bad_correct.do") replace automatic

  * Command only with optional option "inprep", which allows the output file name to be the same
  * as the input file name (so input file is literally replaced with a corrected file)
  stata_linter_correct, input("${test_dir}/bad_correct.do") output("${test_dir}/bad_correct.do") automatic inprep

  * Command only with optional option "indent", which specifies how many whitespaces are used for
  * indentations (default = 4)
  stata_linter_correct, input("${test_dir}/bad.do") output("${test_dir}/bad_correct.do") automatic replace indent(2)

  * Command only with optional option "tab_space", which specifies how many whitespaces are used for
  * hard tabs (default = same as "indent")
  stata_linter_correct, input("${test_dir}/bad.do") output("${test_dir}/bad_correct.do") automatic replace tab_space(2)



