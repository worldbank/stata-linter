* Set the global to folder where test files are stored

	global project 	  	"C:\Users\wb501238\Documents\GitHub/stata-linter"
	global test_dir     "${project}/test"
	adopath ++ "${project}/src"
	
  // net install stata_linter, from("https://raw.githubusercontent.com/worldbank/stata-linter/develop") replace
  run "${project}/src/lint.ado"

  // Detect --------------------------------------------------------------------
  lint "${test_dir}/bad.do",
  lint "${test_dir}/bad.do", verbose  
  lint "${test_dir}/bad.do", verbose nosummary
  lint "${test_dir}/bad.do", nosummary
  
  // Lint with results in excel file
  lint "${test_dir}/bad.do", nosummary          ///
    excel("${test_dir}/detect_lint.xlsx")
  
  // Lint a folder
  lint "${test_dir}"
  lint "${test_dir}", verbose 

  // Lint a folder and create an excel file
  lint "${test_dir}",                           ///
    excel("${test_dir}/detect_output_all.xlsx")

  // Correct -------------------------------------------------------------------
  lint "${test_dir}/bad.do"                     ///
    using "${test_dir}/bad_corrected.do",       ///
    nosummary                               ///
    replace
	
  lint "${test_dir}/bad.do"                     ///
    using "${test_dir}/bad_corrected.do",       ///
    nosummary                               ///
    replace automatic

  
  // detecting + correcting + excel file results
  lint "${test_dir}/bad.do"                     ///
    using "${test_dir}/bad_corrected.do",       ///
    excel("${test_dir}/detect_lint.xlsx")       ///                               
    replace                                     ///
    automatic   

  // Check errors --------------------------------------------------------------
  
  // Invalid file paths
  
  cap lint "oi"
  assert _rc == 601
  
  cap lint oi
  assert _rc == 601
  
  cap lint "oi.do"
  assert _rc == 601
  
  cap lint oi.do
  assert _rc == 601
  
  cap lint "C:\Users\wb501238\Documents\GitHub\iefieldkit\run\output/iecorrect-template.xlsx"
  assert _rc == 198

  // This should return an error. Input file is not a do file
	cap lint "${test_dir}"                        ///
		using "${test_dir}/bad_corrected.do",       ///
		nosummary                                   ///
		replace automatic debug
	
	assert _rc == 198
	
// -----------------------------------------------------------------------------

	adopath - "${project}/src"