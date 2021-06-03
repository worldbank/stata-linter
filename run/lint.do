* Set the global to folder where test files are stored
  global project 	    "D:/Documents/RA Jobs/DIME/analytics/linter/stata-linter"
  global test_dir     "${project}/test"

  net install stata_linter, from("https://raw.githubusercontent.com/worldbank/stata-linter/develop") replace
  // run "${project}/src/lint.ado"

  // Detect --------------------------------------------------------------------
  lint "${test_dir}/bad.do"
  lint "${test_dir}/bad.do", verbose  
  lint "${test_dir}/bad.do", verbose nosummary
  lint "${test_dir}/bad.do", nosummary
  
  // Lint with results in excel file
  lint "${test_dir}/bad.do", nosummary          ///
    excel("${test_dir}/detect_lint.xlsx")      
  
  // Lint a folder
  lint "${test_dir}/"

  // Lint a folder and create an excel file
  lint "${test_dir}/"                            ///
      excel("${test_dir}/detect_lint_all.xlsx")

  // Correct -------------------------------------------------------------------
  lint "${test_dir}/bad.do"                     ///
    using "${test_dir}/bad_corrected.do",       ///
    nosummary                                   ///
    replace automatic

  
  // detecting + correcting + excel file results
  lint "${test_dir}/bad.do"                     ///
    using "${test_dir}/bad_corrected.do",       ///
    excel("${test_dir}/detect_lint.xlsx")       ///                               
    replace                                     ///
    automatic   

  // Check errors --------------------------------------------------------------
  // This should return an error. Input file is not a do file
  lint "${test_dir}/bad"                        ///
    using "${test_dir}/bad_corrected.do",       ///
    nosummary                                   ///
    replace automatic
