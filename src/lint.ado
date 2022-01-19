*! version 0.0.4  21may2021  DIME Analytics dimeanalytics@worldbank.org

capture program drop lint
		program 	 lint

  version 16

  syntax anything [using/],        	///
									/// Options
    [                   			///
      verbose           			///
      NOSUMmary         			///
      Indent(string)    			///
      Linemax(string)   			///
      Space(string) 				///
      Correct(string)   			///
      Excel(string)     			///
      AUTOmatic         			///
      replace           			///
      inprep            			///
	  debug							///
    ]

/*******************************************************************************
********************************************************************************

	PART 1: Prepare inputs

********************************************************************************
*******************************************************************************/

/*******************************************************************************
	Set defaults
*******************************************************************************/

  * set indent size = 4 if missing
  if missing("`indent'")		local indent "4"

  * set whitespaces for tab (space) = indent size if space is missing
  if missing("`space'")   		local space "`indent'"

  * set linemax = 80 if missing
  if missing("`linemax'")		local linemax "80"

  * if !missing("`excel'")   cap erase `excel'
  if !missing("`excel'")		cap rm `excel'

  * set excel = "" if excel is missing
  if missing("`excel'")      	local excel ""

  * set a constant for the suppress option being used
  local suppress_flag "1"
  if !missing("`verbose'")    	local suppress_flag "0"

  * set a constant for the summary option being used
  local summary_flag "1"
  if !missing("`nosummary'")  	local summary_flag "0"

  * In debug mode, print status
  if !missing("`debug'") 		di "Inputs prepared"


/*******************************************************************************
	Prepare file paths
*******************************************************************************/

// Check format of do-file to be linted ----------------------------------------

	* File or Folder to be detected
	gettoken anything : anything

	* Check if main input is a file or a folder
	local input =  `"`anything'"'

	_testpath "`input'", ext(`"".do", ".ado""') argument(lint's main argument) exists `debug'
	local folder =  "`r(folder)'"
    local file 	 =  "`r(file)'"

// Check do-file with corrections ----------------------------------------------

	if !missing("`using'") {

		* Can only be used when linting a do-file
		if missing("`file'") {
			di as error "{phang}Option [using] cannot be used when linting a directory. To use this option, specify a do-file as lint's main argument.{p_end}"
			error 198
		}

		_testpath "`using'", ext(`"".do", ".ado""') argument(lint's [using] argument) `debug'
		local output = "`r(file)'"

		* Unless inprep is used, the output file should have a different name than the input
		if missing("`inprep'") & ("`input'" == "`output'") {
			di as error "{phang}It is recommended to use different file names for lint's main argument and its [using] argument. This is because it is possible that the corrected do-file created by the command will contain bugs, and you may want to keep a backup. If you want to replace the current do-file with the do-file corrected by lint, use the option [inprep]. {p_end}"
			error 198
		}
    }

// Check Excel with corrections ------------------------------------------------

	if !missing("`excel'") {

		_testpath "`excel'", ext(`"".xls", ".xlsx""') argument(lint's [excel] argument) `debug'
		local excel = "`r(file)'"
	}

// In debug mode, print file paths ---------------------------------------------

  if !missing("`debug'") {
  	di "Folder: `folder'"
	di "File: `file'"
	di "Excel: `excel'"
	di "Input: `input'"
	di "Output: `output'"
  }

// Check if python is installed ------------------------------------------------

	_checkpyinstall

	* Check that the Python function is defined
	qui: findfile stata_linter_detect.py
	if c(os) == "Windows" {
		local ado_path = subinstr(r(fn), "\", "/", .)
	}
	else {
		local ado_path = r(fn)
	}

/*******************************************************************************
********************************************************************************

	PART 2: Execute linter

********************************************************************************
*******************************************************************************/

/*******************************************************************************
	Detect issues
*******************************************************************************/

    * Check a single do-file
    if !missing("`file'") {

		if   missing("`using'") {
			local header header
		}

		if (!missing("`verbose'") |	(`summary_flag' == 1) | !missing("`excel'") | !missing("`using'")) {
				local footer footer
		}

		_detect, ///
			file("`file'") excel("`excel'") ado_path("`ado_path'") ///
			indent("`indent'") linemax("`linemax'") space("`space'") ///
			suppress_flag("`suppress_flag'") summary_flag("`summary_flag'") ///
			`header' `footer'
    }

    * Check all do-files in a folder
    else if !missing("`folder'") {

        local files: dir "`folder'" files "*.do"

        foreach file of local files {

			_detect, ///
				file("`folder'/`file'") excel("`excel'") ado_path("`ado_path'") ///
				indent("`indent'") linemax("`linemax'") space("`space'") ///
				suppress_flag("`suppress_flag'") summary_flag("`summary_flag'") ///
				header footer
		}
	}

	* In debug mode, print status
	if !missing("`debug'") noi di "Exiting detect function"

/*******************************************************************************
	Correct issues
*******************************************************************************/

	if !missing("`using'") {
		_correct, ///
			input("`input'") output("`output'") ///
			indent("`indent'") space("`space'") linemax("`linemax'") ///
			`replace' `inprep' `automatic' `debug'
	}

end

/*******************************************************************************
********************************************************************************

	PART 3: Auxiliary functions

********************************************************************************
*******************************************************************************/

// Correct ---------------------------------------------------------------------

capture program drop 	_correct
		program			_correct

	syntax, ///
		input(string) output(string) ///
		indent(string) space(string) linemax(string) ///
		[replace inprep automatic debug]

	* Check that the Python function is defined
    qui: findfile stata_linter_correct.py
    if c(os) == "Windows" {
      local ado_path = subinstr(r(fn), "\", "/", .)
    }
    else {
      local ado_path = r(fn)
    }

    * Copy the input file to the output file, which will be edited by the commands below
    if (!missing("`replace'") | !missing("`inprep'"))  {
		copy "`input'" "`output'", replace
	}
    else {
		copy "`input'" "`output'"
	}

    * Display a message if the correct option is added, so the output can be separated
    display as text 	" "
    display as result 	_dup(60) "-"
    display as result 	"Correcting {bf:do-file}"
    display as result	_dup(60) "-"
    display as text 	" "

	* Import relevant python libraries
    python: import sys, os
		python: from sfi import Macro
    python: sys.path.append(os.path.dirname(r"`ado_path'"))
    python: from stata_linter_correct import *

    * correct the output file, looping for each python command
     foreach fun in 	delimit_to_three_forward_slashes tab_to_space ///
						indent_in_bracket too_long_line space_before_curly ///
						remove_blank_lines_before_curly_close ///
						remove_duplicated_blank_lines {

      if missing("`automatic'") {
          noi di ""
          global confirmation "" //Reset global

          while (upper("${confirmation}") != "Y" & upper("${confirmation}") != "N" & "${confirmation}" != "BREAK") {
              if ("`fun'" == "delimit_to_three_forward_slashes") {
                  di as result "{pstd} Avoid using [delimit], use three forward slashes (///) instead. {p_end}"
              }
              else if ("`fun'" == "tab_to_space") {
                  di as result "{pstd} Avoid using hard tabs, use soft tabs (white spaces) instead. {p_end}"
              }
              else if ("`fun'" == "indent_in_bracket") {
                  di as result "{pstd} Indent commands inside curly brackets. {p_end}"
              }
              else if ("`fun'" == "too_long_line") {
                  di as result "{pstd} Limit line length to `linemax' characters. {p_end}"
              }
              else if ("`fun'" == "space_before_curly") {
                  di as result "{pstd} Use white space before opening curly brackets. {p_end}"
              }
              else if ("`fun'" == "remove_blank_lines_before_curly_close") {
                  di as result "{pstd} Remove redundant blank lines before closing brackets. {p_end}"
              }
              else if ("`fun'" == "remove_duplicated_blank_lines") {
                  di as result "{pstd} Remove duplicated blank lines. {p_end}"
              }
              noi di as txt "{pstd} Do you want to correct this? To confirm type {bf:Y} and hit enter, to abort type {bf:N} and hit enter. Type {bf:BREAK} and hit enter to stop the code. See option {help lint:automatic} to not be prompted before creating files. {p_end}", _request(confirmation)
          }

          // Copy user input to local
          local createfile = upper("${confirmation}")

          // If user wrote "BREAK" then exit the code
          if ("`createfile'" == "BREAK") error 1
      }

      // if automatic is used, always create the file
      else {
	  	local createfile "Y"
	  }

		* If option [manual] was used and input was [N], file is not corrected for this issue
		if ("`createfile'" == "N") {
			noi di as result ""
		}
		* If option [manual] was used and input was [Y], or if option [manual] was not used, create the file
		else if ("`createfile'" == "Y") {
			python: `fun'("`output'", "`output'", "`indent'", "`space'")
		}
    }

	* Print link to corrected output file
    cap confirm file "`output'"
    if !_rc {
      display as result `"{phang}Corrected do-file saved to {browse "`output'":`output'}.{p_end}"'
    }
    else {
      display as error "{phang}Could not create `output'.{p_end}"
      error 1
    }


end

// Detect ----------------------------------------------------------------------

capture program drop	_detect
		program			_detect

		syntax , ///
				file(string) ado_path(string) ///
				indent(string) linemax(string) space(string) ///
				suppress_flag(string) summary_flag(string) ///
				[excel(string) header footer]

		* Import relevant python functions
		python: import sys, os
		python: sys.path.append(os.path.dirname(r"`ado_path'"))
		python: from stata_linter_detect import *

		* Stata result header
		if !missing("`header'") {
			di as result ""
			di as result "Linting file: `file'"
			di as result ""
		}

		* Actually run the Python code
        python: r = stata_linter_detect_py("`file'", "`indent'", "`suppress_flag'", "`summary_flag'", "`excel'", "`linemax'", "`space'")

		* Stata result footer
		if !missing("`footer'") {

				display as result 	_dup(85) "-"

			if "`excel'" != "" {
				display as result 	`"{phang}File {browse "`excel'":`excel'} created.{p_end}"'
			}

				display as result 	`"{phang}For more information about coding guidelines visit the {browse "https://en.wikibooks.org/wiki/LaTeX/Labels_and_Cross-referencing":Stata linter wiki.}{p_end}"'
		}



end

// File Paths ------------------------------------------------------------------

cap program drop _testpath
	program		 _testpath, rclass

	syntax anything, argument(string) ext(string) [details(string) debug exists]

	if !missing("`debug'") di "Entering subcommand _filepath"

	* Standardize file path
	local path = subinstr(`"`anything'"', "\", "/", .)

	* If a folder, test that folder exists
	if !regex(`"`path'"', "\.") {
	    _testdirectory 	`path'	, argument(`argument') details(`details') 	   `debug'
		local folder 	`path'
	}

	* If a file, parse information
	else {
	    _testfile  `path'		, argument(`argument') ext(`"`ext'"') `exists' `debug'
		local file `path'
	}

	return local folder "`folder'"
	if !missing("`debug'") di `"Folder: `folder'"'

	return local file 	"`file'"
	if !missing("`debug'") di `"File: `file'"'

	if !missing("`debug'") di "Exiting subcommand _filepath"

end

// Test file format ------------------------------------------------------------

cap program drop _testfile
	program		 _testfile, rclass

	syntax anything, ext(string) argument(string) [debug exists]

	if !missing("`debug'") di "Entering subcommand _testfile"


	if !missing("`exists'") {
	    confirm file `anything'
	}

	* Get index of separation between file name and file format
	local r_lastdot = strlen(`anything') - strpos(strreverse(`anything'), ".")

	* File format starts at the last period and ends at the end of the string
	local suffix     = substr(`anything', `r_lastdot' + 1, .)

	if !inlist("`suffix'", `ext') {
	    di as error `"{phang}File `anything' is not a valid input for `argument'. Only the following file extensions are accepted: `ext'.{p_end}"'
		error 198
	}

end

// Check if folder exists ------------------------------------------------------

cap program drop _testdirectory
    program      _testdirectory

	syntax anything, argument(string) [details(string) debug]

	if !missing("`debug'") di "Entering subcommand _testdirectory"

	* Test that the folder for the report file exists
	 mata : st_numscalar("r(dirExist)", direxists(`anything'))
	 if `r(dirExist)' == 0  {
	 	noi di as error `"{phang}Directory `anything', used `argument', does not exist. `details'{p_end}"'
		error 601
	 }

end


// Error checks ----------------------------------------------------------------

capture program drop  	_checkpyinstall
		program 		_checkpyinstall

	* Check if python is installed
	cap python search
	if _rc {
		noi di as error `"{phang} For this command, Python installation is required. Refer to {browse "https://blog.stata.com/2020/08/18/stata-python-integration-part-1-setting-up-stata-to-use-python/":this page} for how to integrate Python to Stata. {p_end}"'
		exit
	}

	* Check if pandas package is installed
	cap python which pandas
	if _rc {
		noi di as error `"{phang} For this command to run, a package "pandas" needs to be installed. Refer to {browse "https://blog.stata.com/2020/09/01/stata-python-integration-part-3-how-to-install-python-packages/":this page} for how to install python packages. {p_end}"'
		exit
	}

	* Check if sfi package is installed
	* This is needed to pass Python results into Stata
	cap python which sfi
	if _rc {
		noi di as error `"{phang} For this command to run, a package "sfi" needs to be installed. Refer to {browse "https://blog.stata.com/2020/09/01/stata-python-integration-part-3-how-to-install-python-packages/":this page} for how to install python packages. {p_end}"'
	}

end

************************************************************* Have a lovely day!
