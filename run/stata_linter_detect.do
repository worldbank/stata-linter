*** ----------------------------------------------------------------------------
*** Global settings 
*** ----------------------------------------------------------------------------

*** Set the global to folder where test files are stored
    global project 	    "D:/Documents/RA Jobs/DIME/analytics/linter/stata-linter"
    global test_dir     "${project}/test"

*** ----------------------------------------------------------------------------
*** Run example commands
*** ----------------------------------------------------------------------------

*** 1. For one .do file --------------------------------------------------------

    // 1.1 Command with no option, showing lines with bad practices
    stata_linter_detect, file("${test_dir}/bad.do") 

    // 1.2 indent option
    stata_linter_detect, file("${test_dir}/bad.do") indent(2)

    // 1.3 nocheck option, output only shows "style" problems 
    stata_linter_detect, file("${test_dir}/bad.do") nocheck

    // 1.4 suppress option, where no output is shown on the console
    stata_linter_detect, file("${test_dir}/bad.do") suppress

    // 1.5 summary option, where the output includes the summary of
    // bad practices (number of lines a bad practice is detected)
    stata_linter_detect, file("${test_dir}/bad.do") summary

    // 1.6 excel option, which stores the output in an excel file
    stata_linter_detect, file("${test_dir}/bad.do") 		///
        excel("${test_dir}/detect_output.xlsx")

    // 1.7. linemax option which specifies the max characters in a line
    stata_linter_detect, file("${test_dir}/bad.do") linemax(100)

*** 2. For all .do files in a folder -------------------------------------------

    // 2.1 Command with no option, showing lines with bad practices
    stata_linter_detect, folder("${test_dir}") 

    // 2.2 indent option
    stata_linter_detect, folder("${test_dir}") indent(2)

    // 2.3 nocheck option, output only shows "style" problems 
    stata_linter_detect, folder("${test_dir}") nocheck

    // 2.4 suppress option, where no output is shown on Stata console
    stata_linter_detect, folder("${test_dir}") suppress

    // 2.5. summary option, where the output includes the summary of
    // bad practices (number of lines a bad practice is detected)
    stata_linter_detect, folder("${test_dir}") summary

    // 2.6 excel option, which stores the output in an excel file
    stata_linter_detect, folder("${test_dir}")          ///
        excel("${test_dir}/detect_output_all.xlsx")

    // 2.7 linemax option, which specifies the max characters in a line
    stata_linter_detect, folder("${test_dir}") linemax(100)
