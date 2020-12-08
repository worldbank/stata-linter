/*****************************************************************************************************/
/* program stata_linter_detect_all : Linter do file: detect bad coding practices in files in a folder*/
/*****************************************************************************************************/

cap ssc install filelist

cap prog drop stata_linter_detect_all
program stata_linter_detect_all
    version 16
    syntax, [Input(string) Indent(string) Nocheck suppress summary excel(string) linemax(string) tab_space(string)]

    * if input is missing, set to the current folder
    if missing("`input'") local input "."

    * return error if input is not a folder
    capture confirm file "`input'"
    if _rc & ("`input'" != ".") {
			noi di as error `"{phang} Folder `input' is not found.{p_end}"'
			exit
    }

    * set indent size = 4 if indent is missing
    if missing("`indent'") local indent "4"

    * set whitespaces for tab (tab_space) = indent size if tab_space is missing
    if missing("`tab_space'") local tab_space "`indent'"
  
    * set linemax = 80 if missing
    if missing("`linemax'") local linemax "80"

    *if !missing("`excel'") cap erase `excel'
    if !missing("`excel'") cap rm `excel'

    local option_list "`nocheck' `suppress' `summary'"
    di "`option_list'"

    preserve
    filelist, dir("`input'") pat(*.do) norecursive
    levelsof filename, local(filename) 
    foreach l of local filename {
        di ""
        di "`l' **************************************"
        di ""

        if !missing("`excel'") {
            stata_linter_detect, input("${path}/`l'") indent("`indent'") `option_list' excel("`excel'") linemax("`linemax'") tab_space("`tab_space'")
        }
        else {
            stata_linter_detect, input("${path}/`l'") indent("`indent'") `option_list' linemax("`linemax'") tab_space("`tab_space'")
        }
    }
    restore

end


/* *********** END program stata_linter_detect_all ***************************************** */




