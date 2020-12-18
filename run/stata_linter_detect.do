
  * --------------- *
  * Global settings *
  * --------------- *

  * Set the global to folder where .ado files are stored
  global src_dir "/Users/mizuhirosuzuki/Documents/GitHub/stata-linter/src"
  * Set the global to folder where test files are stored
  global test_dir "/Users/mizuhirosuzuki/Documents/GitHub/stata-linter/test"
  
  * To run the command, you need to change your current directory to src_dir
  cd "${src_dir}"

  * -------------------- *
  * Run example commands *
  * -------------------- *

  * For one .do file ---------------------------------

  * Command with no option, showing the lines 
  * where bad practices are detected on Stata console 
  stata_linter_detect, file("${test_dir}/bad.do") 
  
  * Command with indent option, which specifies how many whitespaces are
  * used for indentations (default = 4)
  stata_linter_detect, file("${test_dir}/bad.do") indent(2)

  * Command with nocheck option, where the output only show "style" problems 
  * but do not show "check" problems which are suggestions for checks
  stata_linter_detect, file("${test_dir}/bad.do") nocheck

  * Command with suppress option, where no output is shown on Stata console
  stata_linter_detect, file("${test_dir}/bad.do") suppress

  * Command with summary option, where the output includes the summary of
  * bad practices (number of lines a bad practice is detected)
  stata_linter_detect, file("${test_dir}/bad.do") summary
  
  * Command with excel option, which stores the output in an excel file
  stata_linter_detect, file("${test_dir}/bad.do") excel("${test_dir}/detect_output.xlsx")

  * Command with excel option, which specifies the maximum characters in a line
  * (default = 80)
  stata_linter_detect, file("${test_dir}/bad.do") linemax(100)

  * Command with tab_space option, which specifies how many whitespaces are
  * used for hard tabs (default = same as the one specified in "indent()" option)
  stata_linter_detect, file("${test_dir}/bad.do") tab_space(2)




  * For all .do files in a folder ---------------------------------

  * Command with no option, showing the lines 
  * where bad practices are detected on Stata console 
  stata_linter_detect, folder("${test_dir}") 
  
  * Command with indent option, which specifies how many whitespaces are
  * used for indentations (default = 4)
  stata_linter_detect, folder("${test_dir}") indent(2)

  * Command with nocheck option, where the output only show "style" problems 
  * but do not show "check" problems which are suggestions for checks
  stata_linter_detect, folder("${test_dir}") nocheck

  * Command with suppress option, where no output is shown on Stata console
  stata_linter_detect, folder("${test_dir}") suppress

  * Command with summary option, where the output includes the summary of
  * bad practices (number of lines a bad practice is detected)
  stata_linter_detect, folder("${test_dir}") summary
  
  * Command with excel option, which stores the output in an excel file
  stata_linter_detect, folder("${test_dir}") excel("${test_dir}/detect_output.xlsx")

  * Command with excel option, which specifies the maximum characters in a line
  * (default = 80)
  stata_linter_detect, folder("${test_dir}") linemax(100)

  * Command with tab_space option, which specifies how many whitespaces are
  * used for hard tabs (default = same as the one specified in "indent()" option)
  stata_linter_detect, folder("${test_dir}") tab_space(2)



