*! version 0.0.2  21may2021  DIME Analytics dimeanalytics@worldbank.org

cap prog drop stata_linter_detect
program stata_linter_detect

    version 16

    syntax, [FIle(string) FOlder(string) Indent(string) Nocheck SUPpress SUMmary Excel(string) Linemax(string) Tab_space(string)]

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

    *if !missing("`excel'") cap erase `excel'
    if !missing("`excel'") cap rm `excel'
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
    qui: findfile stata_linter_detect.py
    if c(os) == "Windows" {
        local ado_path = subinstr(r(fn), "\", "/", .) 
    }
    else {
        local ado_path = r(fn)
    }
    python: import sys, os
    python: sys.path.append(os.path.dirname(r"`ado_path'"))
    python: from stata_linter_detect import *

    * Only one of "file" and "folder" can be non-missing
    if !missing("`file'") & !missing("`folder'") {
        noi di as error `"{phang} You cannot use both {bf:file()} option and {bf:folder()} option at the same time. {p_end}"'
        exit
    }
    * At least either "file" or "folder" needs to be used
    else if missing("`file'") & missing("`folder'") {
        noi di as error `"{phang} You need to either use {bf:file()} option to detect bad practices in the specified .do file or use {bf:folder()} option to detect bad practices in all .do files in the specified folder. {p_end}"'
        exit
    }
    * The case where one .do file is checked
    else if !missing("`file'") {
        python: stata_linter_detect_py("`file'", "`indent'", "`nocheck_flag'", "`suppress_flag'", "`summary_flag'", "`excel'", "`linemax'", "`tab_space'")
    }
    * The case where all .do files in a folder are checked
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


end

/* *********** END program stata_linter_detect ***************************************** */




