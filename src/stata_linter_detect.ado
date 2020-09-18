/*****************************************************************************/
/* program stata_linter_detect : Linter do file: detect bad coding practices */
/*****************************************************************************/
cap prog drop stata_linter_detect
program stata_linter_detect 
    version 16
    syntax, Input(string) 
  
    * call the python function
    python: stata_linter_detect_py("`input'")

end

version 16
python:

# Import packages ====================
import os
import re
import sys

# Style ===================

def abstract_index_name(line_index, line, input_lines):

    if re.search(re.compile(r"^(foreach)|(forval)"), line.lstrip()):
        list_of_words = line.split()
        for word in list_of_words:
            if re.search(re.compile(r"^(foreach)|(forval)"), word):
                index_in_loop = list_of_words[list_of_words.index(word) + 1]
            break
        if len(set(index_in_loop)) == 1:
            print(
                f'''(line {line_index + 1}) style: ''' +
                '''In for loops, index names should describe what the code is looping over. ''' +
                f'''Do not use an abstract index such as "{index_in_loop}".'''
                )

def find_tab(line_index, line, input_lines):

    if re.search(r"\t", line):
        print(
            f'''(line {line_index + 1}) style: ''' +
            '''Use 4 white spaces instead of tabs.'''
            )

def proper_indent(line_index, line, input_lines):

    if re.search(re.compile(r"^(foreach |forval|if |else )"), line.lstrip()):
        line_ws = line.expandtabs(4)
        next_line = input_lines[line_index + 1]
        next_line_ws = next_line.expandtabs(4)
        line_left_spaces = len(line) - len(line_ws.lstrip())
        next_line_left_spaces = len(next_line) - len(next_line_ws.lstrip())
        if next_line_left_spaces - line_left_spaces != 4:
            print(
                f'''(line {line_index + 1}) style: ''' +
                '''After declaring for-loop statement or if-else statement, add indentation (4 whitespaces).'''
                )

def condition_missing(line_index, line, input_lines):

    if re.search(re.compile(r"(<|!=)( )*\."), line):
        print(
            f'''(line {line_index + 1}) style: ''' +
            '''Use "!missing(var)" instead of "var < ." or "var != .".'''
            )

def dont_use_delimit(line_index, line, input_lines):

    if re.search(re.compile(r"#delimit(?! cr)"), line):
        print(
            f'''(line {line_index + 1}) style: ''' +
            '''Avoid to use "delimit". For line breaks, use "///" instead.'''
            )

def dont_use_cd(line_index, line, input_lines):

    if re.search(re.compile(r"^cd "), line.lstrip()):
        print(
            f'''(line {line_index + 1}) style: ''' +
            '''Do not use "cd" but use absolute and dynamic file paths.'''
            )

def too_long_line(line_index, line, input_lines):

    if len(line) >= 80:
        print(
            f'''(line {line_index + 1}) style: ''' +
            f'''This line is too long ({len(line)} characters). ''' +
            f'''Use "///" for line breaks so that one line has at most 80 characters.'''
            )

def explicit_if(line_index, line, input_lines):

    if (re.search(re.compile(r"^(if|else if) "), line.lstrip()) != None) & (re.search(re.compile(r"((=|<|>))"), line) == None):
        print(
            f'''(line {line_index + 1}) ''' +
            '''style: Always explicitly specify the condition in the if statement. ''' +
            '''(For example, declare "if var == 1" instead of "if var".) '''
            )

def parentheses_for_global_macro(line_index, line, input_lines):

    if re.search(re.compile(r"\\$\w"), line):
        print(
            f'''(line {line_index + 1}) ''' +
            '''style: Always use "\${}" for global macros. '''
            )

# Check ===================

def check_missing(line_index, line, input_lines):
    if re.search(re.compile(r"(~=)|(!=)"), line):
        print(
            f'''(line {line_index + 1}) check: ''' +
            '''Are you taking missing values into account properly? ''' +
            '''(Remember that "a != 0" includes cases where a is missing.)'''
            )

def backslash_in_path(line_index, line, input_lines):
    if re.search(r"\\(\w| |-)+\\", line):
        print(
            f'''(line {line_index + 1}) check: ''' +
            '''Are you using backslashes ("\\") for a file path? ''' +
            '''If so, use forward slashes ("/") instead.'''
            )

def bang_not_tilde(line_index, line, input_lines):

    if re.search(re.compile(r"~"), line):
        print(
            f'''(line {line_index + 1}) style: ''' +
            '''Are you using tilde (~) for negation? ''' +
            '''If so, for negation, use bang (!) instead of tilde (~).'''
            )

# Run linter program to detect bad coding practices ===================
def stata_linter_detect_py(input_file):
    # style ============
    print("Style =====================")
    # Any hard tabs in the do file
    with open(input_file, "r") as f:
        input_lines = f.readlines()
        for line_index, line in enumerate(input_lines):
            if re.search(r"\t", line):
                print(
                    f'''(line {line_index + 1}) style: ''' +
                    '''Use 4 white spaces instead of tabs.'''
                    )
                break
    # Other line-by-line bad practices
    with open(input_file, "r") as f:
        input_lines = f.readlines()
        for line_index, line in enumerate(input_lines):
            abstract_index_name(line_index, line, input_lines)
            proper_indent(line_index, line, input_lines)
            condition_missing(line_index, line, input_lines)
            explicit_if(line_index, line, input_lines)
            dont_use_delimit(line_index, line, input_lines)
            dont_use_cd(line_index, line, input_lines)
            too_long_line(line_index, line, input_lines)
            parentheses_for_global_macro(line_index, line, input_lines)
    # check ============
    print("Check =====================")
    with open(input_file, "r") as f:
        input_lines = f.readlines()
        for line_index, line in enumerate(input_lines):
            check_missing(line_index, line, input_lines)
            backslash_in_path(line_index, line, input_lines)
            bang_not_tilde(line_index, line, input_lines)

end


/* *********** END program stata_linter_detect ***************************************** */




