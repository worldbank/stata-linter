/*****************************************************************************/
/* program stata_linter_detect : Linter do file: detect bad coding practices */
/*****************************************************************************/

cap ssc install filelist

cap prog drop stata_linter_detect
program stata_linter_detect 
    version 16

    syntax, Input(string) [INdent(string) Nocheck SUPpress SUMmary Excel(string) Linemax(string) Tab_space(string)]

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

    * set indent size = 4 if missing
    if missing("`indent'") local indent "4"

    * set whitespaces for tab (tab_space) = indent size if tab_space is missing
    if missing("`tab_space'") local tab_space "`indent'"
  
    * set linemax = 80 if missing
    if missing("`linemax'") local linemax "80"

    * set excel = "" if excel is missing
    if missing("`excel'") local excel ""

		* set a constant for the nocheck option being used
		local nocheck_flag "0"
		if !missing("`nocheck'") local nocheck_flag "1"

		* set a constant for the suppress option being used
		local suppress_flag "0"
		if !missing("`suppress'") local suppress_flag "1"

		* set a constant for the summary option being used
		local summary_flag "0"
		if !missing("`summary'") local summary_flag "1"

    * call the python function
    findfile stata_linter_detect.ado
    local ado_path = r(fn)
    python: import sys, os
    python: sys.path.append(os.path.dirname("`ado_path'"))
    python: from stata_linter_detect import stata_linter_detect_py
    python: stata_linter_detect_py("`input'", "`indent'", "`nocheck_flag'", "`suppress_flag'", "`summary_flag'", "`excel'", "`linemax'", "`tab_space'")

end


/* *********** END program stata_linter_detect ***************************************** */




