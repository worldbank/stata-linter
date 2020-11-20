/*****************************************************************************/
/* program stata_linter_detect : Linter do file: detect bad coding practices */
/*****************************************************************************/
cap prog drop stata_linter_detect
program stata_linter_detect 
    version 16
    syntax, Input(string) [Indent(string) Nocheck suppress summary excel(string)]

    * set indent size = 4 if indent is missing
    if missing("`indent'") local indent "4"

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
    python: stata_linter_detect_py("`input'", "`indent'", "`nocheck_flag'", "`suppress_flag'", "`summary_flag'", "`excel'")

end

version 16
python:

# Import packages ====================
import os
import re
import sys
import pandas as pd

# Style ===================

def abstract_index_name(
    line_index, line, input_lines, indent,
    suppress, style_dictionary, excel_output_list
    ):

    if re.search(re.compile(r"^(foreach)|(forval)"), line.lstrip()):
        list_of_words = line.split()
        for word in list_of_words:
            if re.search(re.compile(r"^(foreach)"), word):
                index_in_loop = list_of_words[list_of_words.index(word) + 1]
            elif re.search(re.compile(r"^(forval)"), word):
                index_in_loop = list_of_words[list_of_words.index(word) + 1].split("=")[0]
            break
        if len(set(index_in_loop)) == 1:
            print_output = (
                '''In for loops, index names should describe what the code is looping over. ''' +
                '''Do not use an abstract index such as "{:s}".'''.format(index_in_loop)
                )
            if suppress != "1":
                print(
                    '''(line {:d}) style: '''.format(line_index + 1) +
                    print_output
                    )

            style_dictionary["abstract_index_name"] += 1
            excel_output_list.append([line_index + 1, "style", print_output])

    return([style_dictionary, excel_output_list])

def proper_indent(
    line_index, line, input_lines, indent,
    suppress, style_dictionary, excel_output_list
    ):

    if re.search(re.compile(r"^(foreach |forval|if |else )"), line.lstrip()):
        line_ws = line.expandtabs(indent)
        next_line = input_lines[line_index + 1]
        next_line_ws = next_line.expandtabs(indent)
        line_left_spaces = len(line_ws) - len(line_ws.lstrip())
        next_line_left_spaces = len(next_line_ws) - len(next_line_ws.lstrip())
        if (next_line_left_spaces - line_left_spaces != indent) & (len(next_line_ws.strip()) > 0):
            print_output = (
                '''After declaring for loop statement or if-else statement, add indentation ({:d} whitespaces).'''.format(indent)
                )

            if suppress != "1":
                print(
                    '''(line {:d}) style: '''.format(line_index + 1) +
                    print_output
                    )

            style_dictionary["proper_indent"] += 1
            excel_output_list.append([line_index + 1, "style", print_output])
    return([style_dictionary, excel_output_list])

def condition_missing(
    line_index, line, input_lines, indent,
    suppress, style_dictionary, excel_output_list
    ):

    if re.search(re.compile(r"(<|!=)( )*\."), line):
        print_output = (
            '''Use "!missing(var)" instead of "var < ." or "var != .".'''
            )
        if suppress != "1":
            print(
                '''(line {:d}) style: '''.format(line_index + 1) +
                print_output
                )

        style_dictionary["condition_missing"] += 1
        excel_output_list.append([line_index + 1, "style", print_output])
    return([style_dictionary, excel_output_list])

def dont_use_delimit(
    line_index, line, input_lines, indent,
    suppress, style_dictionary, excel_output_list
    ):

    if re.search(re.compile(r"#delimit(?! cr)"), line):
        print_output = (
            '''Avoid to use "delimit". For line breaks, use "///" instead.'''
            )
        if suppress != "1":
            print(
                '''(line {:d}) style: '''.format(line_index + 1) +
                print_output
                )

        style_dictionary["dont_use_delimit"] += 1
        excel_output_list.append([line_index + 1, "style", print_output])
    return([style_dictionary, excel_output_list])

def dont_use_cd(
    line_index, line, input_lines, indent,
    suppress, style_dictionary, excel_output_list
    ):

    if re.search(re.compile(r"^cd "), line.lstrip()):
        print_output = (
            '''Do not use "cd" but use absolute and dynamic file paths.'''
            )
        if suppress != "1":
            print(
                '''(line {:d}) style: '''.format(line_index + 1) +
                print_output
                )

        style_dictionary["dont_use_cd"] += 1
        excel_output_list.append([line_index + 1, "style", print_output])
    return([style_dictionary, excel_output_list])

def too_long_line(
    line_index, line, input_lines, indent,
    suppress, style_dictionary, excel_output_list
    ):

    if (len(line) >= 80) & ("///" not in line):
        print_output = (
            '''This line is too long ({:d} characters). '''.format(len(line)) +
            '''Use "///" for line breaks so that one line has at most 80 characters.'''
            )
        if suppress != "1":
            print(
                '''(line {:d}) style: '''.format(line_index + 1) +
                print_output
                )

        style_dictionary["too_long_line"] += 1
        excel_output_list.append([line_index + 1, "style", print_output])
    return([style_dictionary, excel_output_list])

def explicit_if(
    line_index, line, input_lines, indent,
    suppress, style_dictionary, excel_output_list
    ):

    if (re.search(re.compile(r"^(if|else if) "), line.lstrip()) != None) & (re.search(re.compile(r"((=|<|>))"), line) == None):
        print_output = (
            '''style: Always explicitly specify the condition in the if statement. ''' +
            '''(For example, declare "if var == 1" instead of "if var".) '''
            )
        if suppress != "1":
            print(
                '''(line {:d}) style: '''.format(line_index + 1) +
                print_output
                )

        style_dictionary["too_long_line"] += 1
        excel_output_list.append([line_index + 1, "style", print_output])
    return([style_dictionary, excel_output_list])

def parentheses_for_global_macro(
    line_index, line, input_lines, indent,
    suppress, style_dictionary, excel_output_list
    ):

    if re.search(re.compile(r"\\$\w"), line):
        print_output = (
            '''style: Always use "\${}" for global macros. '''
            )
        if suppress != "1":
            print(
                '''(line {:d}) style: '''.format(line_index + 1) +
                print_output
                )

        style_dictionary["parentheses_for_global_macro"] += 1
        excel_output_list.append([line_index + 1, "style", print_output])
    return([style_dictionary, excel_output_list])

# Check ===================

def check_missing(
    line_index, line, input_lines, indent,
    suppress, check_dictionary, excel_output_list
    ):
    if re.search(re.compile(r"(~=)|(!=)"), line):
        print_output = (
            '''Are you taking missing values into account properly? ''' +
            '''(Remember that "a != 0" includes cases where a is missing.)'''
            )
        if suppress != "1":
            print(
                '''(line {:d}) check: '''.format(line_index + 1) +
                print_output
                )

        check_dictionary["check_missing"] += 1
        excel_output_list.append([line_index + 1, "check", print_output])
    return([check_dictionary, excel_output_list])

def backslash_in_path(
    line_index, line, input_lines, indent,
    suppress, check_dictionary, excel_output_list
    ):
    if re.search(r"\\(\w| |-)+\\", line):
        print_output = (
            '''Are you using backslashes ("\\") for a file path? ''' +
            '''If so, use forward slashes ("/") instead.'''
            )
        if suppress != "1":
            print(
                '''(line {:d}) check: '''.format(line_index + 1) +
                print_output
                )

        check_dictionary["check_missing"] += 1
        excel_output_list.append([line_index + 1, "check", print_output])
    return([check_dictionary, excel_output_list])

def bang_not_tilde(
    line_index, line, input_lines, indent,
    suppress, check_dictionary, excel_output_list
    ):

    if re.search(re.compile(r"~"), line):
        print_output = (
            '''Are you using tilde (~) for negation? ''' +
            '''If so, for negation, use bang (!) instead of tilde (~).'''
            )

        if suppress != "1":
            print(
                '''(line {:d}) style: '''.format(line_index + 1) +
                print_output
                )

        check_dictionary["check_missing"] += 1
        excel_output_list.append([line_index + 1, "check", print_output])
    return([check_dictionary, excel_output_list])

# Function to update comment delimiter ======================
# (detection works only when comment delimiter == 0)
def update_comment_delimiter(comment_delimiter, line):
    # if "/*" and "*/" are in the same line, never mind
    if re.search(r"\/\*.*\*\/", line):
        pass
    # if "/*" (opening) detected, add 1
    elif re.search(r"\/\*", line):
        comment_delimiter += 1
    # if "*/" (closing) detected, subtract 1
    elif (re.search(r"\*\/", line) != None) & (comment_delimiter > 0):
        comment_delimiter -= 1
    return(comment_delimiter)


# Run linter program to detect bad coding practices ===================
def stata_linter_detect_py(input_file, indent, nocheck, suppress, summary, excel):

    excel_output_list = []

    # style ============
    if suppress != "1":
        print("Style =====================")
    # Any hard tabs in the do file
    with open(input_file, "r") as f:
        input_lines = f.readlines()
        comment_delimiter = 0
        for line_index, line in enumerate(input_lines):

            comment_delimiter = update_comment_delimiter(comment_delimiter, line)

            if comment_delimiter == 0:
                hard_tab = "No"
                if re.search(r"\t", line):
                    hard_tab = "Yes"
                    print_output = (
                        '''Use {:d} white spaces instead of tabs.'''.format(int(indent)) +
                        '''(This may apply to other lines as well.)'''
                        )
                    excel_output_list.append([line_index + 1, "style", print_output])
                    if suppress != "1":
                        print(
                            '''(line {:d}) style: '''.format(line_index + 1) +
                            print_output
                            )
                    break

    # Other line-by-line bad practices
    style_dictionary = {
        "abstract_index_name": 0,
        "proper_indent": 0,
        "condition_missing": 0,
        "explicit_if": 0,
        "dont_use_delimit": 0,
        "dont_use_cd": 0,
        "too_long_line": 0,
        "parentheses_for_global_macro": 0
    }

    with open(input_file, "r") as f:
        input_lines = f.readlines()
        comment_delimiter = 0
        for line_index, line in enumerate(input_lines):
            # update comment delimiter
            comment_delimiter = update_comment_delimiter(comment_delimiter, line)

            if re.search(r"^(\*|\/\/)", line.lstrip()) != None:
                pass
            elif comment_delimiter > 0:
                pass
            else:
                style_dictionary, excel_output_list = abstract_index_name(
                    line_index, line, input_lines, int(indent),
                    suppress, style_dictionary, excel_output_list
                    )
                style_dictionary, excel_output_list = proper_indent(
                    line_index, line, input_lines, int(indent),
                    suppress, style_dictionary, excel_output_list
                    )
                style_dictionary, excel_output_list = condition_missing(
                    line_index, line, input_lines, int(indent),
                    suppress, style_dictionary, excel_output_list
                    )
                style_dictionary, excel_output_list = explicit_if(
                    line_index, line, input_lines, int(indent),
                    suppress, style_dictionary, excel_output_list
                    )
                style_dictionary, excel_output_list = dont_use_delimit(
                    line_index, line, input_lines, int(indent),
                    suppress, style_dictionary, excel_output_list
                    )
                style_dictionary, excel_output_list = dont_use_cd(
                    line_index, line, input_lines, int(indent),
                    suppress, style_dictionary, excel_output_list
                    )
                style_dictionary, excel_output_list = too_long_line(
                    line_index, line, input_lines, int(indent),
                    suppress, style_dictionary, excel_output_list
                    )
                style_dictionary, excel_output_list = parentheses_for_global_macro(
                    line_index, line, input_lines, int(indent),
                    suppress, style_dictionary, excel_output_list
                    )
    # check ============
    check_dictionary = {
        "check_missing": 0,
        "backslash_in_path": 0,
        "bang_not_tilde": 0,
    }

    if int(nocheck) == 0:
        if suppress != "1":
            print("Check =====================")
        with open(input_file, "r") as f:
            input_lines = f.readlines()
            comment_delimiter = 0
            for line_index, line in enumerate(input_lines):

                # update comment delimiter
                comment_delimiter = update_comment_delimiter(comment_delimiter, line)

                if re.search(r"^(\*|\/\/)", line.lstrip()) != None:
                    pass
                elif comment_delimiter > 0:
                    pass
                else:
                    check_dictionary, excel_output_list = check_missing(
                        line_index, line, input_lines, int(indent),
                        suppress, check_dictionary, excel_output_list
                        )
                    check_dictionary, excel_output_list = backslash_in_path(
                        line_index, line, input_lines, int(indent),
                        suppress, check_dictionary, excel_output_list
                        )
                    check_dictionary, excel_output_list = bang_not_tilde(
                        line_index, line, input_lines, int(indent),
                        suppress, check_dictionary, excel_output_list
                        )

    if summary == "1":
        print("\nSummary (number of lines where bad practices are detected) =======================")

        print("\n[Style]")
        print("Hard tabs instead of soft tabs (whitespaces) used: {:s}".format(hard_tab))
        print("Abstract index used in for-loop: {:d}".format(style_dictionary["abstract_index_name"]))
        print("Not proper indentation: {:d}".format(style_dictionary["proper_indent"]))
        print("Condition incomplete: {:d}".format(style_dictionary["condition_missing"]))
        print("Not explicit if statement: {:d}".format(style_dictionary["explicit_if"]))
        print("Delimit used: {:d}".format(style_dictionary["dont_use_delimit"]))
        print("cd used: {:d}".format(style_dictionary["dont_use_cd"]))
        print("Line too long: {:d}".format(style_dictionary["too_long_line"]))
        print("Parentheses not used for global macro: {:d}".format(style_dictionary["parentheses_for_global_macro"]))

        if int(nocheck) == 0:
            print("\n[Check]")
            print("Missing values properly treated?: {:d}".format(check_dictionary["check_missing"]))
            print("Backslash used in file path?: {:d}".format(check_dictionary["backslash_in_path"]))
            print("Bang (!) used instead of tilde (~) for negation?: {:d}".format(check_dictionary["bang_not_tilde"]))

    if excel != "":
        output_df = pd.DataFrame(excel_output_list)
        output_df.columns = ["Line", "Type", "Problem"]
        output_df.to_excel(excel, index = False)
        print("\n File {:s} created".format(excel))

end


/* *********** END program stata_linter_detect ***************************************** */




