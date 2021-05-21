# version 0.0.2  21may2021  DIME Analytics dimeanalytics@worldbank.org
# Import packages ====================
import os
import re
import sys
import pandas as pd

# Style ===================

# Avoid to use abstract index names ----------------
def abstract_index_name(
    line_index, line, input_lines, indent,
    suppress, style_dictionary, excel_output_list,
    tab_space
    ):

    if re.search(r"^(qui[a-z]*\s+)?(foreach|forv)", line.lstrip()):
        list_of_words = line.split()
        # get the index used in for loops
        for word in list_of_words:
            if re.search(r"^(foreach)", word):
                index_in_loop = list_of_words[list_of_words.index(word) + 1]
                break
            elif re.search(r"^(forv)", word):
                index_in_loop = list_of_words[list_of_words.index(word) + 1].split("=")[0]
                break
        # warn if the number of characters in the index is just 1
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

# Use proper indentations in for-loops, while-loops, and if/else statements ----------------
def proper_indent(
    line_index, line, input_lines, indent,
    suppress, style_dictionary, excel_output_list,
    tab_space
    ):

    line_rstrip = re.sub(r"(\/\/)|(\/\*).*", r"", line).rstrip()
    if len(line_rstrip) > 0:
        # check if the line includes for-loop, while-loop, or if/else statements
        if (
            (re.search(r"^(qui[a-z]*\s+)?(foreach |forv|if |else )", line.lstrip()) != None) &
            (line_rstrip[-1] == "{")
            ):
            line_ws = line.expandtabs(tab_space)
            j = 1
            # find the next non-blank line 
            while (j + line_index <= len(input_lines)):
                if (j + line_index == len(input_lines)):
                    next_line = input_lines[line_index + 1]
                    break
                if (
                    (len(input_lines[line_index + j].strip()) > 0) &
                    (re.search(r"^(\*|\/\/)", input_lines[line_index + j].lstrip()) == None)
                    ):
                    next_line = input_lines[line_index + j]
                    break
                j += 1
            # warn if the next non-blank line is not properly indented
            next_line_ws = next_line.expandtabs(tab_space)
            line_left_spaces = len(line_ws) - len(line_ws.lstrip())
            next_line_left_spaces = len(next_line_ws) - len(next_line_ws.lstrip())
            if (next_line_left_spaces - line_left_spaces < indent) & (len(next_line_ws.strip()) > 0):
                print_output = (
                    '''After declaring for loop statement or if-else statement, ''' +
                    '''add indentation ({:d} whitespaces).'''.format(indent)
                    )

                if suppress != "1":
                    print(
                        '''(line {:d}) style: '''.format(line_index + 1) +
                        print_output
                        )

                style_dictionary["proper_indent"] += 1
                excel_output_list.append([line_index + 1, "style", print_output])
    return([style_dictionary, excel_output_list])

# Use indentations after line breaks (///) ----------------
def indent_after_newline(
    line_index, line, input_lines, indent,
    suppress, style_dictionary, excel_output_list,
    tab_space
    ):

    # check if the line includes "///" but the previous line does not include "///"
    if (
        (re.search(r"\/\/\/", line) != None) & 
        (re.search(r"\/\/\/", input_lines[max(line_index - 1, 0)]) == None)
        ):
        line_ws = line.expandtabs(tab_space)
        # warn if the following line (after line break) is not properly indented
        next_line = input_lines[line_index + 1]
        next_line_ws = next_line.expandtabs(tab_space)
        line_left_spaces = len(line_ws) - len(line_ws.lstrip())
        next_line_left_spaces = len(next_line_ws) - len(next_line_ws.lstrip())
        if (next_line_left_spaces - line_left_spaces < indent) & (len(next_line_ws.strip()) > 0):
            print_output = (
                '''After new line statement ("///"), add indentation ({:d} whitespaces).'''.format(indent)
                )

            if suppress != "1":
                print(
                    '''(line {:d}) style: '''.format(line_index + 1) +
                    print_output
                    )

            style_dictionary["indent_after_newline"] += 1
            excel_output_list.append([line_index + 1, "style", print_output])
    return([style_dictionary, excel_output_list])

# No whitespaces around math symbols ----------------
def whitespace_symbol(
    line_index, line, input_lines, indent,
    suppress, style_dictionary, excel_output_list,
    tab_space
    ):

    # warn if no whitespaces around math symbols
    if re.search(r"(( )*(<|>|=|==|\+)\w|\w(<|>|=|==|\+)( )*)", line):
        print_output = (
            '''Before and after math symbols (>, <, =, +, etc), it is recommended to use whitespaces. ''' +
            '''(For example, do "gen a = b + c" instead of "gen a=b+c".)'''
            )
        if suppress != "1":
            print(
                '''(line {:d}) style: '''.format(line_index + 1) +
                print_output
                )

        style_dictionary["whitespace_symbol"] += 1
        excel_output_list.append([line_index + 1, "style", print_output])
    return([style_dictionary, excel_output_list])

# For missing values "var < ." or "var != ." are used (!missing(var) is recommended) ----------------
def condition_missing(
    line_index, line, input_lines, indent,
    suppress, style_dictionary, excel_output_list,
    tab_space
    ):

    # warn if "var < ." or "var != ." are used 
    if re.search(r"(<|!=)( )*\.", line):
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

# Using "#delimit" should be avoided
def dont_use_delimit(
    line_index, line, input_lines, indent,
    suppress, style_dictionary, excel_output_list,
    tab_space
    ):

    # warn if "#delimit" is used
    if re.search(r"#delimit(?! cr)", line):
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

# Using "cd" should be avoided
def dont_use_cd(
    line_index, line, input_lines, indent,
    suppress, style_dictionary, excel_output_list,
    tab_space
    ):

    # warn if "#cd" is used
    if re.search(r"(^| )cd ", line.lstrip()):
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

# If a line is too lone, it should be broken into multiple lines
def too_long_line(
    line_index, line, input_lines, indent, linemax,
    suppress, style_dictionary, excel_output_list,
    tab_space
    ):

    # warn if the line is too long (and line breaks are not used yet)
    if (len(line) >= linemax) & ("///" not in line):
        print_output = (
            '''This line is too long ({:d} characters). '''.format(len(line)) +
            '''Use "///" for line breaks so that one line has at most {:d} characters.'''.format(linemax)
            )
        if suppress != "1":
            print(
                '''(line {:d}) style: '''.format(line_index + 1) +
                print_output
                )

        style_dictionary["too_long_line"] += 1
        excel_output_list.append([line_index + 1, "style", print_output])
    return([style_dictionary, excel_output_list])

# "if" condition should be explicit 
def explicit_if(
    line_index, line, input_lines, indent,
    suppress, style_dictionary, excel_output_list,
    tab_space
    ):

    # warn if "if" statement is used but the condition is not explicit
    search_if = re.search(r"^(if|else if) ", line.lstrip())
    if (search_if != None):
        if (
            (re.search(r"missing\(", line[search_if.span()[0]:]) == None) &
            (re.search(r"((=|<|>))", line[search_if.span()[0]:]) == None)
            ):
            print_output = (
                '''Always explicitly specify the condition in the if statement. ''' +
                '''(For example, declare "if var == 1" instead of "if var".) '''
                )
            if suppress != "1":
                print(
                    '''(line {:d}) style: '''.format(line_index + 1) +
                    print_output
                    )
            style_dictionary["explicit_if"] += 1
            excel_output_list.append([line_index + 1, "style", print_output])

    return([style_dictionary, excel_output_list])

# Use parentheses for global macros
def parentheses_for_global_macro(
    line_index, line, input_lines, indent,
    suppress, style_dictionary, excel_output_list,
    tab_space
    ):

    # warn if global macros are used without parentheses
    if re.search(r"\\$\w", line):
        print_output = (
            '''Always use "\${}" for global macros. '''
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

# Ask if missing variables are properly taken into account
def check_missing(
    line_index, line, input_lines, indent,
    suppress, check_dictionary, excel_output_list,
    tab_space
    ):
    # ask if missing variables are properly taken into account
    if re.search(r"(~=)|(!=)(?!(( )*\.))", line):
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

# Ask if the user may be using backslashes in file paths
def backslash_in_path(
    line_index, line, input_lines, indent,
    suppress, check_dictionary, excel_output_list,
    tab_space
    ):
    # warn if anything is sandwiched by backslashes, 
    # which suggests that the user may be using backslashes for file paths
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

        check_dictionary["backslash_in_path"] += 1
        excel_output_list.append([line_index + 1, "check", print_output])
    return([check_dictionary, excel_output_list])

def bang_not_tilde(
    line_index, line, input_lines, indent,
    suppress, check_dictionary, excel_output_list,
    tab_space
    ):

    # warn if tilde is used, which suggests 
    # that the user may be using tilde for negation
    if re.search(r"~", line):
        print_output = (
            '''Are you using tilde (~) for negation? ''' +
            '''If so, for negation, use bang (!) instead of tilde (~).'''
            )

        if suppress != "1":
            print(
                '''(line {:d}) style: '''.format(line_index + 1) +
                print_output
                )

        check_dictionary["bang_not_tilde"] += 1
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
def stata_linter_detect_py(
    input_file, indent, nocheck, 
    suppress, summary, excel, linemax,
    tab_space
    ):

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
                        '''Use {:d} white spaces instead of tabs. '''.format(int(indent)) +
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
        "indent_after_newline": 0,
        "whitespace_symbol": 0,
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
                    suppress, style_dictionary, excel_output_list,
                    int(tab_space)
                    )
                style_dictionary, excel_output_list = proper_indent(
                    line_index, line, input_lines, int(indent),
                    suppress, style_dictionary, excel_output_list,
                    int(tab_space)
                    )
                style_dictionary, excel_output_list = indent_after_newline(
                    line_index, line, input_lines, int(indent),
                    suppress, style_dictionary, excel_output_list,
                    int(tab_space)
                    )
                style_dictionary, excel_output_list = whitespace_symbol(
                    line_index, line, input_lines, int(indent),
                    suppress, style_dictionary, excel_output_list,
                    int(tab_space)
                    )
                style_dictionary, excel_output_list = condition_missing(
                    line_index, line, input_lines, int(indent),
                    suppress, style_dictionary, excel_output_list,
                    int(tab_space)
                    )
                style_dictionary, excel_output_list = explicit_if(
                    line_index, line, input_lines, int(indent),
                    suppress, style_dictionary, excel_output_list,
                    int(tab_space)
                    )
                style_dictionary, excel_output_list = dont_use_delimit(
                    line_index, line, input_lines, int(indent),
                    suppress, style_dictionary, excel_output_list,
                    int(tab_space)
                    )
                style_dictionary, excel_output_list = dont_use_cd(
                    line_index, line, input_lines, int(indent),
                    suppress, style_dictionary, excel_output_list,
                    int(tab_space)
                    )
                style_dictionary, excel_output_list = too_long_line(
                    line_index, line, input_lines, int(indent), int(linemax),
                    suppress, style_dictionary, excel_output_list,
                    int(tab_space)
                    )
                style_dictionary, excel_output_list = parentheses_for_global_macro(
                    line_index, line, input_lines, int(indent),
                    suppress, style_dictionary, excel_output_list,
                    int(tab_space)
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
                        suppress, check_dictionary, excel_output_list,
                        int(tab_space)
                        )
                    check_dictionary, excel_output_list = backslash_in_path(
                        line_index, line, input_lines, int(indent),
                        suppress, check_dictionary, excel_output_list,
                        int(tab_space)
                        )
                    check_dictionary, excel_output_list = bang_not_tilde(
                        line_index, line, input_lines, int(indent),
                        suppress, check_dictionary, excel_output_list,
                        int(tab_space)
                        )

    if summary == "1":
        print("\nSummary (number of lines where bad practices are detected) =======================")

        print("\n[Style]")
        print("Hard tabs instead of soft tabs (whitespaces) used: {:s}".format(hard_tab))
        print("Abstract index used in for-loop: {:d}".format(style_dictionary["abstract_index_name"]))
        print("Not proper indentation in for-loop for if-else statement: {:d}".format(style_dictionary["proper_indent"]))
        print("Not proper indentation in newline: {:d}".format(style_dictionary["indent_after_newline"]))
        print("No whitespaces around math symbols: {:d}".format(style_dictionary["whitespace_symbol"]))
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
        if (output_df.empty == True):
            output_df = pd.DataFrame(columns = ["Line", "Type", "Problem"])
        output_df.columns = ["Line", "Type", "Problem"]
        if os.path.exists(excel):
            with pd.ExcelWriter(excel, engine = "openpyxl", mode = "a") as writer:
                output_df.to_excel(writer, index = False, sheet_name = os.path.basename(input_file)[:20])
        else:
            with pd.ExcelWriter(excel) as writer:
                output_df.to_excel(writer, index = False, sheet_name = os.path.basename(input_file)[:20])
        print("\n File {:s} created".format(excel))
