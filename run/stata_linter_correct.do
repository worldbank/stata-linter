*** ----------------------------------------------------------------------------
*** Global settings 
*** ----------------------------------------------------------------------------

*** Set the global to folder where test files are stored
    global project 	    "D:/Documents/RA Jobs/DIME/analytics/linter/stata-linter"
    global test_dir     "${project}/test"
  
*** ----------------------------------------------------------------------------
*** Run example commands
*** ----------------------------------------------------------------------------

    // 1. Command only with optional option "replace"
    stata_linter_correct, input("${test_dir}/bad.do")           /// 
                          output("${test_dir}/bad_correct.do") replace

    // 2. option "automatic" which does all corrections without asking
    stata_linter_correct, input("${test_dir}/bad.do")           ///
                          output("${test_dir}/bad_correct.do") replace automatic

    // 3. option "inprep", which allows the output file name to be the same
    // as the input file name (so input file is literally replaced 
    // with a corrected file).
    stata_linter_correct, input("${test_dir}/bad_correct.do")   ///
                          output("${test_dir}/bad_correct.do") automatic inprep

    // 4. indent option which specifies how many whitespaces are used for
    // indentations (default = 4)
    stata_linter_correct, input("${test_dir}/bad.do")           ///
                          output("${test_dir}/bad_correct.do")  ///
                          automatic replace indent(2)

    // 5. Command only with optional option "tab_space", which specifies how 
    // many whitespaces are used for hard tabs (default = same as "indent")
    stata_linter_correct, input("${test_dir}/bad.do")           ///
                          output("${test_dir}/bad_correct.do")  ///
                          automatic replace tab_space(2)



