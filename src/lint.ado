*! version 0.0.3  21may2021  DIME Analytics dimeanalytics@worldbank.org

cap prog drop lint
program lint

  version 16

  // Syntax
  syntax using/,        ///
    /// Options
    [                   ///
      FOlder(string)    ///
      Indent(string)    ///
      VERBose           ///
      NOSUMmary         ///
      Nocheck           ///
      Excel(string)     ///
      Linemax(string)   ///
      Tab_space(string) ///
      Correct(string)   ///
      Automatic         ///
      Replace           ///
      INPRep            ///
    ]

  // File to be detected
  local file = subinstr("`using'","\","/",.)
  
  // ---------------------------------------------------------------------------
  // PYTHON INFORMATION
  // ---------------------------------------------------------------------------
  // Check if python is installed
  cap python search
  if _rc {
      noi di as error `"{phang} For this command, Python installation is required. Refer to {browse "https://blog.stata.com/2020/08/18/stata-python-integration-part-1-setting-up-stata-to-use-python/":this page} for how to integrate Python to Stata. {p_end}"'
      exit
  }

  // Check if pandas package is installed
  cap python which pandas
  if _rc {
      noi di as error `"{phang} For this command to run, a package "pandas" needs to be installed. Refer to {browse "https://blog.stata.com/2020/09/01/stata-python-integration-part-3-how-to-install-python-packages/":this page} for how to install python packages. {p_end}"'
      exit
  }

  // ---------------------------------------------------------------------------
  // OPTIONS -- Defaults
  // ---------------------------------------------------------------------------
  // set indent size = 4 if missing
  if missing("`indent'")      local indent "4"

  // set whitespaces for tab (tab_space) = indent size if tab_space is missing
  if missing("`tab_space'")   local tab_space "`indent'"

  // set linemax = 80 if missing
  if missing("`linemax'")     local linemax "80"

  // if !missing("`excel'") cap erase `excel'
  if !missing("`excel'")      cap rm `excel'

  // set excel = "" if excel is missing
  if missing("`excel'")       local excel ""

  // set a constant for the nocheck option being used
  local nocheck_flag "0"
  if !missing("`nocheck'")    local nocheck_flag "1"

  // set a constant for the suppress option being used
  local suppress_flag "1"
  if !missing("`verbose'")    local suppress_flag "0"

  // set a constant for the summary option being used
  local summary_flag "1"
  if !missing("`nosummary'")  local summary_flag "0"

  // ---------------------------------------------------------------------------
  // CHECK WHETHER THE PYTHON FUNCTIONS EXIST
  // ---------------------------------------------------------------------------
    
  // Stata Detect
  qui: findfile stata_linter_detect.py
  if c(os) == "Windows" {
      local ado_path = subinstr(r(fn), "\", "/", .) 
  }
  else {
      local ado_path = r(fn)
  }

  // Stata Correct
  qui: findfile stata_linter_correct.py
  if c(os) == "Windows" {
    local ado_path = subinstr(r(fn), "\", "/", .) 
  }
  else {
    local ado_path = r(fn)
  }
  
  // ---------------------------------------------------------------------------
  // EXECTING THE FUNCTIONS
  // ---------------------------------------------------------------------------
  
  // Only Stata Detect ---------------------------------------------------------
  if "`correct'" == "" {
    python: import sys, os
    python: sys.path.append(os.path.dirname(r"`ado_path'"))
    python: from stata_linter_detect import *

    // Only one of "file" and "folder" can be non-missing
    if !missing("`file'") & !missing("`folder'") {
        noi di as error `"{phang} You cannot use both {bf:file()} option and {bf:folder()} option at the same time. {p_end}"'
        exit
    }

    // At least either "file" or "folder" needs to be used
    else if missing("`file'") & missing("`folder'") {
        noi di as error `"{phang} You need to either use {bf:file()} option to detect bad practices in the specified .do file or use {bf:folder()} option to detect bad practices in all .do files in the specified folder. {p_end}"'
        exit
    }
    
    // The case where one .do file is checked
    else if !missing("`file'") {
        python: stata_linter_detect_py("`file'", "`indent'", "`nocheck_flag'", "`suppress_flag'", "`summary_flag'", "`excel'", "`linemax'", "`tab_space'")
    }

    // The case where all .do files in a folder are checked
    else if !missing("`folder'") {
        preserve
        local files: dir "`folder'" files "*.do"
        foreach l of local files {
            di ""
            di "`l' **************************************"
            di ""

            python: stata_linter_detect_py("`folder'/`l'", "`indent'", "`nocheck_flag'", "`suppress_flag'", "`summary_flag'", "`excel'", "`linemax'", "`tab_space'")
        }
        restore
    }
  } 

  // Stata Correct + Stata Detect ----------------------------------------------
  if "`correct'" != "" {
    // Output file
    local output  = subinstr("`correct'","\","/",.)
    
    // Input file
    local input   = subinstr("`using'","\","/",.)
    
    // Stata Detect  -----------------------------------------------------------
    python: import sys, os
    python: sys.path.append(os.path.dirname(r"`ado_path'"))
    python: from stata_linter_detect import *

    // Only one of "file" and "folder" can be non-missing
    if !missing("`file'") & !missing("`folder'") {
        noi di as error `"{phang} You cannot use both {bf:file()} option and {bf:folder()} option at the same time. {p_end}"'
        exit
    }

    // At least either "file" or "folder" needs to be used
    else if missing("`file'") & missing("`folder'") {
        noi di as error `"{phang} You need to either use {bf:file()} option to detect bad practices in the specified .do file or use {bf:folder()} option to detect bad practices in all .do files in the specified folder. {p_end}"'
        exit
    }

    // The case where one .do file is checked
    else if !missing("`file'") {
        python: stata_linter_detect_py("`file'", "`indent'", "`nocheck_flag'", "`suppress_flag'", "`summary_flag'", "`excel'", "`linemax'", "`tab_space'")
    }
  
    // The case where all .do files in a folder are checked
    else if !missing("`folder'") {
        preserve
        local files: dir "`folder'" files "*.do"
        foreach l of local files {
            di ""
            di "`l' **************************************"
            di ""

            python: stata_linter_detect_py("`folder'/`l'", "`indent'", "`nocheck_flag'", "`suppress_flag'", "`summary_flag'", "`excel'", "`linemax'", "`tab_space'")
        }
        restore
    }

    // Stata correct -----------------------------------------------------------
    
    // unless inprep is used, return error if input file and output file have the same name
    if missing("`inprep'") & ("`input'" == "`output'") {
      noi di as error `"{phang} It is recommended that input file and output file have different names since the output of this command is not guaranteed to function properly and you may want to keep a backup. If you want to replace the input file with the output of this command, use the option inprep .{p_end}"'
      exit
    }

    // copy the input file to the output file, which will be edited by the commands below
    if (!missing("`replace'") | !missing("`inprep'")) copy "`input'" "`output'", replace
    else copy "`input'" "`output'"


    // display a message if the correct option is added, so the output can be separated
    display as text " "
    display as text " "
    display as text " "
    display as result _dup(60) "-"
    display as result "Correcting {bf:do-file}"
    display as result _dup(60) "-"
    
    python: import sys, os
    python: sys.path.append(os.path.dirname(r"`ado_path'"))
    python: from stata_linter_correct import *

    * correct the output file, looping for each python command
    foreach fun in                                                                  /// 
      "delimit_to_three_forward_slashes" "tab_to_space" "indent_in_bracket"         ///
      "too_long_line" "space_before_curly" "remove_blank_lines_before_curly_close"  ///
      "remove_duplicated_blank_lines"                                               ///
      {

      if missing("`automatic'") {
          noi di ""
          global confirmation "" //Reset global

          while (upper("${confirmation}") != "Y" & upper("${confirmation}") != "N" & "${confirmation}" != "BREAK") {
              if ("`fun'" == "delimit_to_three_forward_slashes") {
                  noi di as txt "{pstd} Avoid to use delimit, use three forward slashes (///) instead. {p_end}"
              } 
              else if ("`fun'" == "tab_to_space") {
                  noi di as txt "{pstd} Avoid to use hard tabs, use soft tabs (white spaces) instead. {p_end}"
              }
              else if ("`fun'" == "indent_in_bracket") {
                  noi di as txt "{pstd} Commands in curly brackets should be indented. {p_end}"
              }
              else if ("`fun'" == "too_long_line") {
                  noi di as txt "{pstd} Each line should not be too long. {p_end}"
              }
              else if ("`fun'" == "space_before_curly") {
                  noi di as txt "{pstd} White space is recommended to be added before open curly brackets. {p_end}"
              }
              else if ("`fun'" == "remove_blank_lines_before_curly_close") {
                  noi di as txt "{pstd} Redundant blank lines before closing brackets are better to be removed. {p_end}"
              }
              else if ("`fun'" == "remove_duplicated_blank_lines") {
                  noi di as txt "{pstd} Duplicated blank lines are redundant, better to be compressed. {p_end}"
              }
              noi di as txt "{pstd} Do you want to correct this? To confirm type {bf:Y} and hit enter, to abort type {bf:N} and hit enter. Type {bf:BREAK} and hit enter to stop the code. See option {help iegitaddmd:automatic} to not be prompted before creating files. {p_end}", _request(confirmation)
          }

          // Copy user input to local
          local createfile = upper("${confirmation}")

          // If user wrote "BREAK" then exit the code
          if ("`createfile'" == "BREAK") error 1
      }
      
      // if automatic is used, always create the file
      else local createfile "Y"

      // If manual was used and input was N, file is not corrected for this issue
      if ("`createfile'" == "N") noi di as result ""

      // If "manual" were used and input was Y or if manual was not used, create the file
      else if ("`createfile'" == "Y") {
          * call the python function
          python: `fun'("`output'", "`output'", "`indent'", "`tab_space'")

      }
    }

    // Corrected output file
    cap confirm file "`output'"
    if !_rc {
      display "Created `output'."
    }

    else {
      display as error "Could not create `output'."
      error 1
    }
  } 
  
end

// Have a lovely day!
