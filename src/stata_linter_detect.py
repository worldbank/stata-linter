# version 1.02  06apr2023  DIME Analytics dimeanalytics@worldbank.org
# Import packages ====================
import os
import re
import sys
import pandas as pd
import argparse

# Version Global
## VERY IMPORTANT: Update the version number here every time there's an update
## in the package. Otherwise this will cause a major bug
VERSION = "1.02"

# simple run entry point
def run():
    parser = argparse.ArgumentParser(description='Lint a Stata do-file.')
    parser.add_argument('filename', metavar='file', type=str, nargs='?',
                        help='The name of the file to lint.')
    parser.add_argument('--indent', type=int, nargs='?', default=4,
                            help="Number of spaces to use for each indentation"
                            )
    parser.add_argument('--suppress', action='store_true',
                            help="Suppress line item printout"
                            )
    parser.add_argument('--summary', action='store_true',
                            help="Print a summary of bad practices detected"
                            )
    parser.add_argument('--linemax', type=int, nargs='?', default=80,
                            help="Maximum number of characters per line"
                            )
    parser.add_argument('--excel_output', type=str, nargs='?', default="",
                            help="If specified, save results to Excel workbook"
                            )


    args=parser.parse_args()
    return stata_linter_detect_py(
        input_file=args.filename,
        indent=args.indent,
        suppress="1" if args.suppress else "0",
        summary="1" if args.summary else "0",
        excel=args.excel_output,
        linemax=args.linemax,
        tab_space=args.indent
        )

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
                    '''(line {:d}): '''.format(line_index + 1) +
                    print_output
                    )

            style_dictionary["abstract_index_name"] += 1
            excel_output_list.append([line_index + 1, "style", print_output])

    return([style_dictionary, excel_output_list])

def loop_open(line):

    '''
    Detect if a line is opening a loop
    '''
    line_rstrip = re.sub(r"((\/\/)|(\/\*)).*", r"", line).rstrip()
    if len(line_rstrip) > 0:
        # check if the line includes for-loop, while-loop, or if/else statements
        if (
            (re.search(r"^(qui[a-z]*\s+)?(foreach |forv|if |else )", line.lstrip()) != None) &
            (line_rstrip[-1] == "{")
            ):
            return True
    return False


def loop_close(line):

    '''
    Detects if a line is closing a loop
    '''
    relevant_part = re.split('//', line)[0].rstrip()

    if len(relevant_part) > 0:

        if relevant_part[-1] =='}':
            return True
        else:
            return False

    else:
        return False

def bad_indent_in_loop(line, open_loop_line, indent, tab_space):

    '''
    Detect if a line is correctly indented by checking the indentation of
    the first line of the loop
    '''
    line_ws = line.expandtabs(tab_space)
    line_left_spaces1 = len(open_loop_line) - len(open_loop_line.lstrip())
    line_left_spaces2 = len(line_ws) - len(line_ws.lstrip())
    if (line_left_spaces2 - line_left_spaces1 < indent) & (len(line_ws.strip()) > 0):
        return True
    else:
        return False

# Use proper indentations in for-loops, while-loops, and if/else statements ----------------
def detect_bad_indent(line_index, line, input_lines, indent, tab_space):

    if loop_open(line):
        line_ws = line.expandtabs(tab_space)
        j = 1
        embedded_loops = 0

        # Checking the lines inside the loop
        while j + line_index < len(input_lines):
            next_line = input_lines[line_index + j]

            # (next) line is opening another loop
            if loop_open(next_line):
                embedded_loops += 1
                j += 1
                continue

            # (next) line is closing a loop
            if loop_close(next_line):
                if embedded_loops > 0:
                    # closing an embedded loop
                    embedded_loops -= 1
                else:
                    # closing the main loop
                    break

            # (next) line is inside an embedded loop, we don't check it here.
            # it will be checked when this function is applied on its
            # correcponding loop level
            if embedded_loops > 0:
                j += 1
                continue

            # for other cases, we check they're non-blank lines and then
            # correct indentation
            if (
                (len(next_line.strip()) > 0) &
                (re.search(r"^(\*|\/\/)", next_line.lstrip()) == None)
                ):
                if bad_indent_in_loop(next_line, line_ws, indent, tab_space):
                    return True

            j += 1

    # No bad indentations detected
    return False

def proper_indent(
    line_index, line, input_lines, indent,
    suppress, style_dictionary, excel_output_list,
    tab_space
    ):

    if detect_bad_indent(line_index, line, input_lines, indent, tab_space):

        print_output = (
            '''After declaring for loop statement or if-else statement, ''' +
            '''add indentation ({:d} whitespaces).'''.format(indent)
            )

        if suppress != "1":
            print(
                '''(line {:d}): '''.format(line_index + 1) +
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

    # check if the previous line doesn't have "///" or if it's first line in dofile
    if not re.search(r"\/\/\/", input_lines[max(line_index - 1, 0)]) or line_index == 0:
        # no "///" found, the function finishes here
        return([style_dictionary, excel_output_list])

    else:
        # Now we check which of the previous lines contained "///"
        # we then check indentation spaces with respect of the first
        # line with "///"
        i = 0
        while re.search(r"\/\/\/", input_lines[line_index - (i + 1)]):
            i += 1
            pass

        first_line = input_lines[line_index - i].expandtabs(tab_space)
        first_line_indent = len(first_line) - len(first_line.lstrip())

        line_ws = line.expandtabs(tab_space)
        line_left_spaces = len(line_ws) - len(line_ws.lstrip())

        if line_left_spaces - first_line_indent < indent:
            print_output = (
                '''After new line statement ("///"), add indentation ({:d} whitespaces).'''.format(indent)
                )

            if suppress != "1":
                print(
                    '''(line {:d}): '''.format(line_index + 1) +
                    print_output
                    )

            style_dictionary["indent_after_newline"] += 1
            excel_output_list.append([line_index + 1, "style", print_output])

        return([style_dictionary, excel_output_list])

# No whitespaces around math symbols ----------------
def no_space_before_symbol(line):

    line = line.split('///')[0]
    groups = line.split('"')
    pattern = r"(?:[a-z]|[A-Z]|[0-9]|_|\)|')(?:<|>|=|\+|-|\*|\^)"

    for i, group in enumerate(groups):

        if i % 2 == 0:
            if re.search(pattern, group):
                return True

    return False

def no_space_after_symbol(line):

    line = line.split('///')[0]
    groups = line.split('"')
    pattern = r"(?:(?:<|>|=|\+|-|\*|\^)(?:[a-z]|[A-Z]|_|\(|`|\.|$))|(?:(?:<|>|=|\+|\*|\^)(?:[0-9]))"

    for i, group in enumerate(groups):

        if i % 2 == 0:
            if re.search(pattern, group):
                return True

    return False

def whitespace_symbol(
    line_index, line, input_lines, indent,
    suppress, style_dictionary, excel_output_list,
    tab_space
    ):

    # warn if no whitespaces around math symbols
    if no_space_before_symbol(line) or no_space_after_symbol(line):
        print_output = (
            '''Before and after math symbols (>, <, =, +, etc), it is recommended to use whitespaces. ''' +
            '''(For example, do "gen a = b + c" instead of "gen a=b+c".)'''
            )
        if suppress != "1":
            print(
                '''(line {:d}): '''.format(line_index + 1) +
                print_output
                )

        style_dictionary["whitespace_symbol"] += 1
        excel_output_list.append([line_index + 1, "style", print_output])
    return([style_dictionary, excel_output_list])

# For missing values "var < ." or "var != ." are used (!missing(var) is recommended) ----------------
def has_condition_missing(line):

    if re.search(r"(<|<=|!=|~=)( )*(\.(?![0-9]))", line):
        return True
    else:
        return False

def condition_missing(
    line_index, line, input_lines, indent,
    suppress, style_dictionary, excel_output_list,
    tab_space
    ):

    # warn if "var < ." or "var != ." or "var ~= ." are used
    if has_condition_missing(line):
        print_output = (
            '''Use "!missing(var)" instead of "var < ." or "var != ." or "var ~= ."'''
            )
        if suppress != "1":
            print(
                '''(line {:d}): '''.format(line_index + 1) +
                print_output
                )

        style_dictionary["condition_missing"] += 1
        excel_output_list.append([line_index + 1, "style", print_output])
    return([style_dictionary, excel_output_list])

# Using "#delimit" should be avoided
def detect_delimit(line):

    if re.search(r"#delimit(?! cr)", line):
        return True
    else:
        return False

def dont_use_delimit(
    line_index, line, input_lines, indent,
    suppress, style_dictionary, excel_output_list,
    tab_space
    ):

    # warn if "#delimit" is used
    if detect_delimit(line):
        print_output = (
            '''Avoid to use "delimit". For line breaks, use "///" instead.'''
            )
        if suppress != "1":
            print(
                '''(line {:d}): '''.format(line_index + 1) +
                print_output
                )

        style_dictionary["dont_use_delimit"] += 1
        excel_output_list.append([line_index + 1, "style", print_output])
    return([style_dictionary, excel_output_list])

def check_cd(line):

    if re.search(r"^cd\s", line.lstrip()):
        return True
    else:
        return False

# Using "cd" should be avoided
def dont_use_cd(
    line_index, line, input_lines, indent,
    suppress, style_dictionary, excel_output_list,
    tab_space
    ):

    # warn if "#cd" is used
    if check_cd(line):
        print_output = (
            '''Do not use "cd" but use absolute and dynamic file paths.'''
            )
        if suppress != "1":
            print(
                '''(line {:d}): '''.format(line_index + 1) +
                print_output
                )

        style_dictionary["dont_use_cd"] += 1
        excel_output_list.append([line_index + 1, "style", print_output])
    return([style_dictionary, excel_output_list])

# If a line is too lone, it should be broken into multiple lines
def detect_line_too_long(line, linemax):

    # if the last char is a line break, we leave it out
    if len(line) > 0 and line[-1] == '\n':
        line = line[:-1]

    if (len(line) > linemax):
        return True
    else:
        return False

def too_long_line(
    line_index, line, input_lines, indent, linemax,
    suppress, style_dictionary, excel_output_list,
    tab_space
    ):

    # warn if the line is too long (and line breaks are not used yet)
    if detect_line_too_long(line, linemax):
        print_output = (
            '''This line is too long ({:d} characters). '''.format(len(line)) +
            '''Use "///" for line breaks so that one line has at most {:d} characters.'''.format(linemax)
            )
        if suppress != "1":
            print(
                '''(line {:d}): '''.format(line_index + 1) +
                print_output
                )

        style_dictionary["too_long_line"] += 1
        excel_output_list.append([line_index + 1, "style", print_output])
    return([style_dictionary, excel_output_list])

# "if" condition should be explicit
def detect_implicit_if(line):

    search_if  = re.search(r"(?:^|\s)(?:if|else if)\s", line.lstrip())

    if search_if != None:

        line = line[search_if.span()[0]:]
        if (
            (re.search(r"missing\(", line) == None) &
            (re.search(r"inrange\(", line) == None) &
            (re.search(r"inlist\(", line) == None) &
            (re.search(r"=|<|>", line) == None)
            ):
            return True

    return False

def explicit_if(
    line_index, line, input_lines, indent,
    suppress, style_dictionary, excel_output_list,
    tab_space
    ):

    # warn if "if" statement is used but the condition is not explicit
    if detect_implicit_if(line):
        print_output = (
            '''Always explicitly specify the condition in the if statement. ''' +
            '''(For example, declare "if var == 1" instead of "if var".) '''
            )
        if suppress != "1":
            print(
                '''(line {:d}): '''.format(line_index + 1) +
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
    if re.search(r"\$[a-zA-Z]", line):
        print_output = (
            '''Always use "${}" for global macros. '''
            )
        if suppress != "1":
            print(
                '''(line {:d}): '''.format(line_index + 1) +
                print_output
                )

        style_dictionary["parentheses_for_global_macro"] += 1
        excel_output_list.append([line_index + 1, "style", print_output])
    return([style_dictionary, excel_output_list])

# Check ===================

# Ask if missing variables are properly taken into account
def check_missing_expression(line):

    if re.search(r"(<|!=|~=)( )*(\.(?![0-9]))|!missing\(.+\)", line):
        return True
    else:
        return False

def check_expression(line):

    if re.search(r"(~=|!=|>|>=)(?! *\.(?![0-9]))", line):
        return True
    else:
        return False


def check_missing(
    line_index, line, input_lines, indent,
    suppress, check_dictionary, excel_output_list,
    tab_space
    ):
    # ask if missing variables are properly taken into account

    expression = check_expression(line)
    missing_expression = check_missing_expression(line)

    if expression and not missing_expression:
        print_output = (
            '''Are you taking missing values into account properly? ''' +
            '''(Remember that "a != 0" or "a > 0" include cases where a is missing.)'''
            )
        if suppress != "1":
            print(
                '''(line {:d}): '''.format(line_index + 1) +
                print_output
                )

        check_dictionary["check_missing"] += 1
        excel_output_list.append([line_index + 1, "check", print_output])
    return([check_dictionary, excel_output_list])

# Ask if the user may be using backslashes in file paths
def check_global(line):

    if re.search(r"^global\s", line.lstrip()):
        return True
    else:
        return False

def check_local(line):
    if re.search(r"^local\s", line.lstrip()):
        return True
    else:
        return False

def check_backslash(line):
    if re.search(r"\\", line):
        return True
    else:
        return False

def backslash_in_path(
    line_index, line, input_lines, indent,
    suppress, check_dictionary, excel_output_list,
    tab_space
    ):
    # warn if anything is sandwiched by backslashes,
    # which suggests that the user may be using backslashes for file paths
    changes_dir = check_cd(line)
    is_local = check_local(line)
    is_global = check_global(line)
    has_backslash = check_backslash(line)

    if (changes_dir | is_local | is_global) & has_backslash:
        print_output = (
            '''Are you using backslashes ("\\") for a file path? ''' +
            '''If so, use forward slashes ("/") instead.'''
            )
        if suppress != "1":
            print(
                '''(line {:d}): '''.format(line_index + 1) +
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
    if re.search(r"~=\s*([^\s.]|\.[0-9]+)", line):
        print_output = (
            '''Are you using tilde (~) for negation? ''' +
            '''If so, for negation, use bang (!) instead of tilde (~).'''
            )

        if suppress != "1":
            print(
                '''(line {:d}): '''.format(line_index + 1) +
                print_output
                )

        check_dictionary["bang_not_tilde"] += 1
        excel_output_list.append([line_index + 1, "check", print_output])
    return([check_dictionary, excel_output_list])

def detect_hard_tab(line):

    if re.search(r"\t", line):
        return True
    else:
        return False

def detect_no_space_before_curly_bracket(line):

    if re.search(r"([^ $]){", line):
        return True
    else:
        return False

def detect_blank_line_before_curly_close(line_index, line, dofile_lines):

    if len(line.strip()) > 0 or line_index == len(dofile_lines) - 1:
        # non-blank lines or last line in the dofile
        return False

    # only blank lines from this point
    else:
        next_line = dofile_lines[line_index+1]
        next_line_rstrip = " " + re.sub(r"//.*", r"", next_line).rstrip()

        # Checking if next line is a closing bracket
        if (next_line_rstrip[-1] == "}") & (not re.search(r"\$.*{", next_line)):
            return True
        else:
            return False

def detect_duplicated_blank_line(line_index, line, dofile_lines):

    #if len(line.strip()) > 0 or line_index == len(dofile_lines) - 1:
    if len(line.strip()) > 0:
        # non-blank lines
        return False

    # only blank lines from this point
    else:
        # Check if there is not next line -- note that Python doesn't show
        # empty next lines as an empty last element
        if line_index+1 >= len(dofile_lines):
            return True

        # Check if next line is also blank:
        next_line = dofile_lines[line_index+1]
        if len(next_line.strip()) == 0:
            return True
        else:
            return False

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
    input_file, indent,
    suppress, summary, excel, linemax,
    tab_space
    ):

    excel_output_list = []

    # style ============
    # Any hard tabs in the do file
    with open(input_file, "r") as f:
        input_lines = f.readlines()
        comment_delimiter = 0
        for line_index, line in enumerate(input_lines):

            comment_delimiter = update_comment_delimiter(comment_delimiter, line)

            if comment_delimiter == 0:
                hard_tab = "No"
                if detect_hard_tab(line):
                    hard_tab = "Yes"
                    print_output = (
                        '''Use {:d} white spaces instead of tabs. '''.format(int(indent)) +
                        '''(This may apply to other lines as well.)'''
                        )
                    excel_output_list.append([line_index + 1, "style", print_output])
                    if suppress != "1":
                        print(
                            '''(line {:d}): '''.format(line_index + 1) +
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
        print("")

    if summary == "1":
        print("-------------------------------------------------------------------------------------")
        print("{:69s} {:30s}".format("Bad practice", "Occurrences"))
        print("-------------------------------------------------------------------------------------")

        print("{:69s} {:10s}".format("Hard tabs used instead of soft tabs: ", hard_tab))
        print("{:60s} {:10d}".format("One-letter local name in for-loop: ", style_dictionary["abstract_index_name"]))
        print("{:60s} {:10d}".format("Non-standard indentation in { } code block: ", style_dictionary["proper_indent"]))
        print("{:60s} {:10d}".format("No indentation on line following ///: ", style_dictionary["indent_after_newline"]))
        print("{:60s} {:10d}".format("Use of . where missing() is appropriate: ", style_dictionary["condition_missing"]))
        print("{:60s} {:10d}".format("Missing whitespaces around operators: ", style_dictionary["whitespace_symbol"]))
        print("{:60s} {:10d}".format("Implicit logic in if-condition: ", style_dictionary["explicit_if"]))
        print("{:60s} {:10d}".format("Delimiter changed: ", style_dictionary["dont_use_delimit"]))
        print("{:60s} {:10d}".format("Working directory changed: ", style_dictionary["dont_use_cd"]))
        print("{:60s} {:10d}".format("Lines too long: ", style_dictionary["too_long_line"]))
        print("{:60s} {:10d}".format("Global macro reference without { }: ", style_dictionary["parentheses_for_global_macro"]))
        print("{:60s} {:10d}".format("Potential omission of missing values in expression: ", check_dictionary["check_missing"]))
        print("{:60s} {:10d}".format("Backslash detected in potential file path: ", check_dictionary["backslash_in_path"]))
        print("{:60s} {:10d}".format("Tilde (~) used instead of bang (!) in expression: ", check_dictionary["bang_not_tilde"]))

    output_df = pd.DataFrame(excel_output_list)
    if excel != "":
        if (output_df.empty == True):
            output_df = pd.DataFrame(columns = ["Line", "Type", "Problem"])
        output_df.columns = ["Line", "Type", "Problem"]
        if os.path.exists(excel):
            with pd.ExcelWriter(excel, engine = "openpyxl", mode = "a") as writer:
                output_df.to_excel(writer, index = False, sheet_name = os.path.basename(input_file)[:20])
        else:
            with pd.ExcelWriter(excel) as writer:
                output_df.to_excel(writer, index = False, sheet_name = os.path.basename(input_file)[:20])

    return( not output_df.empty )
