/********************************************************************************/
/* program stata_linter_correct : Linter ado file: correct bad coding practices */
/********************************************************************************/
cap prog drop stata_linter_correct
program def stata_linter_correct

    version 16
    cap python search
    if _rc {
        noi di as error `"{phang} For this command, Python installation is required. Refer to {browse "https://blog.stata.com/2020/08/18/stata-python-integration-part-1-setting-up-stata-to-use-python/":this page} for how to integrate Python to Stata. {p_end}"'
        exit
    }

    syntax, INPUt(string) Output(string) [INDent(string) Automatic Replace INPRep Tab_space(string)]

    * unless inprep is used, return error if input file and output file have the same name
    if missing("`inprep'") & ("`input'" == "`output'") {
        noi di as error `"{phang} It is recommended that input file and output file have different names since the output of this command is not guaranteed to function properly and you may want to keep a backup. If you want to replace the input file with the output of this command, use the option inprep .{p_end}"'
        exit
    }

    * set indent size = 4 if indent is missing
    if missing("`indent'") local indent "4"

    * set whitespaces for tab (tab_space) = indent size if tab_space is missing
    if missing("`tab_space'") local tab_space "`indent'"
  
    * copy the input file to the output file, which will be edited by the commands below
    if (!missing("`replace'") | !missing("`inprep'")) copy "`input'" "`output'", replace
    else copy "`input'" "`output'"

    * import python functions
    qui: findfile stata_linter_correct.py
    if c(os) == "Windows" {
        local ado_path = subinstr(r(fn), "\", "/", .) 
    }
    else {
        local ado_path = r(fn)
    }
    python: import sys, os
    python: sys.path.append(os.path.dirname(r"`ado_path'"))
    python: from stata_linter_correct import *

    * correct the output file, looping for each python command
    foreach fun in "delimit_to_three_forward_slashes" "tab_to_space" "indent_in_bracket" ///
        "too_long_line" "space_before_curly" "remove_blank_lines_before_curly_close" ///
        "remove_duplicated_blank_lines" ///
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
            *Copy user input to local
            local createfile = upper("${confirmation}")

            * If user wrote "BREAK" then exit the code
            if ("`createfile'" == "BREAK") error 1
        }
        * If automatic is used, always create the file
        else local createfile "Y"

        * If manual was used and input was N, file is not corrected for this issue
        *if ("`createfile'" == "N") noi di as result "{pstd} File not corrected for this issue. {p_end}"
        if ("`createfile'" == "N") noi di as result ""

        *If "manual" were used and input was Y or if manual was not used, create the file
        else if ("`createfile'" == "Y") {
            * call the python function
            python: `fun'("`output'", "`output'", "`indent'", "`tab_space'")

        }
    }

    cap confirm file "`output'"
    if !_rc {
        display "Created `output'."
    }
    else {
        display "Could not create `output'."
        error 1
    }

end

/* *********** END program stata_linter_correct ***************************************** */



