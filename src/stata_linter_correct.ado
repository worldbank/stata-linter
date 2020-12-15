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

    syntax, Input(string) Output(string) [Indent(string) automatic replace input_replace_force tab_space(string)]

    * unless input_replace_force, return error if input file and output file have the same name
    if !missing("`input_replace_force'") & ("`input'" == "`output'") {
			noi di as error `"{phang} Output file is recommended to have a different name from the input file since the output of this command is not guaranteed to function properly and you may want to keep a backup. If you want to replace the input file with the output of this command, use the option input_replace_force .{p_end}"'
			exit
    }

    * set indent size = 4 if indent is missing
    if missing("`indent'") local indent "4"

    * set whitespaces for tab (tab_space) = indent size if tab_space is missing
    if missing("`tab_space'") local tab_space "`indent'"
  
    * copy the input file to the output file, which will be edited by the commands below
    if !missing("`replace'") copy "`input'" "`output'", replace
    else copy "`input'" "`output'"

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
        *if 	("`createfile'" == "N") noi di as result "{pstd} File not corrected for this issue. {p_end}"
        if 	("`createfile'" == "N") noi di as result ""

        *If "manual" were used and input was Y or if manual was not used, create the file
        else if ("`createfile'" == "Y") {
            * call the python function
            python: `fun'("`output'", "`output'", "`indent'", "`tab_space'")

        }
    }

    cap confirm file `output'
    if !_rc {
        display "Created `output'."
    }
    else {
        display "Could not create `output'."
        error 1
    }

end

version 16
python:

# Import packages ============
import os
import re
import sys

# Function to update comment delimiter =============
# (detection works only when comment delimiter == 0)
def update_comment_delimiter(comment_delimiter, line):
    # if "/*" and "*/" are in the same line, never mind
    if re.search(r"\/\*.*\*\/", line):
        comment_delimiter += 0
    # if "/*" (opening) detected, add 1
    elif re.search(r"\/\*", line):
        comment_delimiter += 1
    # if "*/" (closing) detected, subtract 1
    elif (re.search(r"\*\/", line) != None) & (comment_delimiter > 0):
        comment_delimiter -= 1
    return(comment_delimiter)

# Functions for auto-correction ===================

# Convert delimit to three forward slashes -------------------
def delimit_to_three_forward_slashes(input_file, output_file, indent, tab_space):
    output_list = []
    with open(input_file, 'r') as reader:
        input_lines = reader.readlines()
        delimit_on = 0
        comment_delimiter = 0
        for line_index, line in enumerate(input_lines):
            # update comment_delimiter
            comment_delimiter = update_comment_delimiter(comment_delimiter, line)
            if comment_delimiter > 0:
                output_list.append(line)
            elif comment_delimiter == 0:
                # check if "#delimit (something other than cr)" is included in a line
                if re.search(r"^#delimit(?! cr)", line.lstrip()):
                    delimit_on = 1
                    # store the character used for line breaks (ignoring comments)
                    # (if not specified, default is ";")
                    line_split = re.split(r"//", line)[0].strip().split(" ")
                    if len(line_split) > 1:
                      delimit_symbol = line_split[1]
                    else:
                      delimit_symbol = ";"
                # check if "#delimit cr" appears in a line, which means
                # the end of delimit function
                elif re.search(r"^#delimit cr", line.lstrip()):
                    delimit_on = 0
                # for other lines, if delimit_on = 0, then just use the line, and
                # if delimit_on = 1, then add "///" at the end of line but before
                # any comments
                else:
                    if delimit_on == 0:
                        output_list.append(line)
                    elif delimit_on == 1:
                        # get any non-comment part of the line and
                        # strip any redundant whitespaces at the end 
                        line_split_for_comment = re.split(r"//", line)
                        line_main = line_split_for_comment[0]
                        if len(line_split_for_comment) > 1:
                            line_comment = line_split_for_comment[1]
                        line_main_rstrip = line_main.rstrip()
                        # if the line is not blank, add appropriate line break commands (///)
                        if len(line_main_rstrip) > 0:
                            # if the line does not end with the delimit symbol (such as ";"),
                            # then that means the command continues to the next line,
                            # so add a line break
                            if line_main_rstrip[-1] != delimit_symbol:
                                # if there is any comment in the line, then
                                # add "///" before the comment and append the comment
                                if len(line_split_for_comment) > 1:
                                    output_list.append(
                                        line_main_rstrip + " ///" + line_comment
                                        )
                                # if there is no comment in the line, then
                                # add "///", but do not forget to add a newline command (\n)
                                # which is removed when stripping redundant whitespaces above
                                elif len(line_split_for_comment) == 1:
                                    output_list.append(line_main_rstrip + " ///\n")
                            # if the line does end with the delimit symbol, then
                            # just remove the symbol
                            elif line_main_rstrip[-1] == delimit_symbol:
                                # if there is any comment in the line, then
                                # just append the comment 
                                if len(line_split_for_comment) > 1:
                                    output_list.append(
                                        re.sub(delimit_symbol, "", line_main).rstrip() + 
                                        " //" + line_comment
                                        )
                                # if there is no comment in the line, then
                                # just add a newline command (\n) at the end
                                elif len(line_split_for_comment) == 1:
                                    output_list.append(
                                        re.sub(delimit_symbol, "", line_main).rstrip() + 
                                        " \n"
                                        )
                        # if the line is blank, just append the blank line
                        elif len(line_main_rstrip) == 0:
                            output_list.append(line)
                        
    with open(output_file, 'w') as writer:
        for output_line in output_list:
            writer.write(output_line)


# Convert hard tabs to soft tabs (= whitespaces) ----------------------
def tab_to_space(input_file, output_file, indent, tab_space):
    output_list = []
    with open(input_file, 'r') as reader:
        input_lines = reader.readlines()
        comment_delimiter = 0
        for line_index, line in enumerate(input_lines):
            # update comment_delimiter
            comment_delimiter = update_comment_delimiter(comment_delimiter, line)
            if comment_delimiter > 0:
                output_list.append(line)
            elif comment_delimiter == 0:
                # replace the hard tabs detected in a line to soft tabs (whitespaces)
                output_list.append(line.replace("\t", " " * int(tab_space)))
    with open(output_file, 'w') as writer:
        for output_line in output_list:
            writer.write(output_line)

# Use indents in brackets after for and while loops or if/else conditions --------------------
def indent_in_bracket(input_file, output_file, indent, tab_space):
    with open(input_file, 'r') as reader:
        input_lines = reader.readlines()
        loop_start = []
        bracket_start = []
        bracket_pair = []
        nest_level = 0
        max_nest_level = 0
        comment_delimiter = 0
        for line_index, line in enumerate(input_lines):
            # update comment_delimiter
            comment_delimiter = update_comment_delimiter(comment_delimiter, line)
            if comment_delimiter == 0:
                # get the main command of the line (ignoring comments at the end) and remove
                # redundant whitespaces
                line_rstrip = re.sub(r'(\/\/)|(\/\*).*', r'', line).rstrip()
                # if the line is not blank or has any command other than comments,
                # do the followings
                if len(line_rstrip) > 0:
                    # check if the line starts with commands that potentially have curly brackets
                    if re.search(re.compile(r"^(foreach |while |forval|if |else |cap)"), line.lstrip()) != None:
                        # if the line ends with an open curly bracket,
                        # then tag it (here the depth of the nests are stored as well)
                        if line_rstrip[-1] == "{":
                            loop_start.append(line_index)
                            bracket_start.append(line_index)
                            nest_level += 1
                            max_nest_level = max(max_nest_level, nest_level)
                        # if the line does not end with an open curly bracket but includes line breaks,
                        # then search for the line including the open curly bracket in the following lines 
                        # and tag the line
                        elif (line_rstrip[-1] != "{") & (re.search(r"//", line) != None):
                            loop_start.append(line_index)
                            for i in range(line_index, len(input_lines)):
                                temp_line_rstrip = re.sub(r'//.*', r'', input_lines[i]).rstrip()
                                if temp_line_rstrip[-1] == "{":
                                    bracket_start.append(i)
                                    break
                            nest_level += 1
                            max_nest_level = max(max_nest_level, nest_level)
                    # check if the line ends with a closing curly bracket 
                    # (ignore it if that is not used for global macro)
                    if (line_rstrip[-1] == "}") & (not re.search(r'\$.?{', line)):
                        bracket_pair.append([loop_start.pop(), line_index, nest_level, bracket_start.pop()])
                        nest_level -= 1
        # for each depth of nests, add appropriate indentations
        for nest_level in range(1, max_nest_level + 1):
            for pair in bracket_pair:
                if pair[2] == nest_level:
                    # get the position of where to start indentations
                    start_indent = len(input_lines[pair[0]]) - len(input_lines[pair[0]].lstrip())
                    # for each line in the nest, do the followings
                    for j in range(pair[0] + 1, pair[1]):
                        # if the line is blank, ignore it
                        if len(input_lines[j].lstrip()) == 0:
                            pass
                        # if the line is not blank, then add indentations at the beginning of the line
                        elif len(input_lines[j].lstrip()) > 0:
                            input_lines[j] = ' ' * (start_indent + int(indent)) + (input_lines[j].lstrip())
    with open(output_file, 'w') as writer:
        for output_line in input_lines:
            writer.write(output_line)

# Split too long line (> 80 characters) to multiple lines
# (but do not break strings in double quotes (""), parentheses, or curly brackets) --------------------
def too_long_line(input_file, output_file, indent, tab_space):
    output_list = []
    with open(input_file, 'r') as reader:
        input_lines = reader.readlines()
        newline_flag = 0
        comment_delimiter = 0
        for line_index, line in enumerate(input_lines):
            # update comment_delimiter
            comment_delimiter = update_comment_delimiter(comment_delimiter, line)
            if comment_delimiter > 0:
                output_list.append(line)
            elif comment_delimiter == 0:
                # do nothing if any of the following conditions are met
                if (
                    (len(line) <= 80) | # the line if not too long, or
                    ((line.lstrip() + ' ')[0] == "*") | # the line is a comment
                    ((line.lstrip() + '  ')[:2] == "//") | # the line ends with a line break
                    ("///" in line) # line contains a comment
                    ):
                    output_list.append(line)
                # otherwise, do the followings
                else:
                    # separate the comment part and the command part of the line
                    line_split_for_comment = re.split(r"//", line)
                    line_main = line_split_for_comment[0]
                    if "\n" in line_main:
                        line_main = line_main.rstrip() + "\n"
                    else:
                        line_main = line_main.rstrip()
                    if len(line_split_for_comment) > 1:
                        line_comment = line_split_for_comment[1]
                    line_indent = len(line_main.rstrip()) - 
                        len(line_main.rstrip().expandtabs(int(indent)).lstrip())

                    i = 0
                    break_line = []
                    double_quote_count = 0
                    parenthesis_count = 0
                    curly_count = 0
                    # looking at each character of a line, tag where to break the line
                    for j, c in enumerate(line_main):
                        if c == '''"''':
                            double_quote_count = 1 - double_quote_count
                        if c == "(":
                            parenthesis_count += 1
                        if c == ")":
                            parenthesis_count -= 1
                        if c == "{":
                            curly_count += 1
                        if c == "}":
                            curly_count -= 1
                        if (
                            (
                                ((i >= 30) & (c == ',')) | # break line at "," if characters > 30
                                (i >= (70 - line_indent)) # break line if characters > 70
                                ) & 
                            (double_quote_count == 0) & # ignore if in double quotes
                            (parenthesis_count == 0) & # ignore if in parentheses
                            (curly_count == 0)# ignore if in curly brackets
                            ):
                            if (c == ' '):
                                break_line.append(j)
                                i = 0
                            if (c == ','):
                                break_line.append(j + 1)
                                i = 0
                            else:
                                i += 1
                        else:
                            i += 1

                    # break lines
                    line_split = []
                    break_line_index = [0]
                    break_line_index.extend(break_line)
                    break_line_index.append(len(line_main))
                    for k in range(len(break_line_index) - 1):
                        # if no line break is needed, just append the line
                        if (break_line_index == 2):
                            line_split.append(
                                line_main[break_line_index[k]:break_line_index[k + 1]].rstrip()
                                )
                        # otherwise, break the line according to the positions of characters tagged above
                        else:
                            line_split.append(line_main[break_line_index[k]:break_line_index[k + 1]])

                    # if no line break if needed, then just append the line 
                    # with appropriate indentations (and commends if needed)
                    if len(line_split) == 1:
                        if len(line_split_for_comment) > 1:
                            output_list.append(
                                ' ' * line_indent + line_split[0].lstrip() + " //" + line_comment
                                )
                        elif len(line_split_for_comment) == 1:
                            output_list.append(' ' * line_indent + line_split[0].lstrip() + "\n")
                    # otherwise, break the line
                    elif len(line_split) > 1:
                        for i, temp_line in enumerate(line_split):
                            # the first line
                            if i == 0:
                                new_line = ' ' * line_indent + temp_line.lstrip() + " ///\n"
                            # from the second to the last to the second line
                            elif (i > 0) & (i < len(line_split) - 1):
                                # if the previous line does not include a line break, then
                                # add an appropriate indentations
                                if newline_flag == 0:
                                    new_line = ' ' * (line_indent + int(indent)) + temp_line.lstrip() + " ///\n"
                                # if the previous line does include a line break, then
                                # assuming that the indentation is correctly done,
                                # add no indentations
                                elif newline_flag == 1:
                                    new_line = ' ' * (line_indent) + temp_line.lstrip() + " ///\n"
                            # the last line
                            elif (i == len(line_split) - 1):
                                # if the previous line does not include a line break, then
                                # add an appropriate indentations
                                if newline_flag == 0:
                                    new_line = ' ' * (line_indent + int(indent)) + temp_line.lstrip()
                                # if the previous line does include a line break, then
                                # assuming that the indentation is correctly done,
                                # add no indentations
                                elif newline_flag == 1:
                                    new_line = ' ' * (line_indent) + temp_line.lstrip()
                                # if there is any comment in the original line, add it at the end
                                if len(line_split_for_comment) > 1:
                                    new_line = new_line + " //" + line_comment
                            output_list.append(new_line)
                # flag if the line includes a line break, which will be used
                # in the next line
                if "///" in line:
                    newline_flag = 1
                else:
                    newline_flag = 0
    with open(output_file, 'w') as writer:
        for output_line in output_list:
            writer.write(output_line)

# Add a white space before a curly bracket
# (but not if the curly bracket is used for global macro, as in "${}") --------------------
def space_before_curly(input_file, output_file, indent, tab_space):
    output_list = []
    with open(input_file, 'r') as reader:
        input_lines = reader.readlines()
        comment_delimiter = 0
        for line_index, line in enumerate(input_lines):
            # update comment_delimiter
            comment_delimiter = update_comment_delimiter(comment_delimiter, line)
            if comment_delimiter > 0:
                output_list.append(line)
            elif comment_delimiter == 0:
                # replace "{" with " {" if there is no whitespace 
                # before an open curly bracket, but ignore if
                # "${" since this is for global macro
                output_list.append(re.sub(r'([^ $]){', r'\1 {', line))
    with open(output_file, 'w') as writer:
        for output_line in output_list:
            writer.write(output_line)

# Remove blank lines before curly brackets are closed --------------------
def remove_blank_lines_before_curly_close(input_file, output_file, indent, tab_space):
    output_list = []
    with open(input_file, 'r') as reader:
        input_lines = reader.readlines()
        comment_delimiter = 0
        for line_index, line in enumerate(input_lines):
            # update comment_delimiter
            comment_delimiter = update_comment_delimiter(comment_delimiter, line)
            if comment_delimiter > 0:
                output_list.append(line)
            elif comment_delimiter == 0:
                if len(line.strip()) == 0:
                    for i in range(line_index + 1, len(input_lines)):
                        if len(input_lines[i].strip()) == 0:
                            pass
                        elif len(input_lines[i].strip()) > 0:
                            line_rstrip = ' ' + re.sub(r'//.*', r'', input_lines[i]).rstrip()
                            if (line_rstrip[-1] == "}") & (not re.search(r'\$.*{', input_lines[i])):
                                break
                            else:
                                output_list.append(line)
                                break
                elif len(line.strip()) > 0:
                    output_list.append(line)
    with open(output_file, 'w') as writer:
        for output_line in output_list:
            writer.write(output_line)


# Remove duplicated blank lines --------------------
def remove_duplicated_blank_lines(input_file, output_file, indent, tab_space):
    output_list = []
    with open(input_file, 'r') as reader:
        input_lines = reader.readlines()
        blank_line_flag = 0
        comment_delimiter = 0
        for line_index, line in enumerate(input_lines):
            # update comment_delimiter
            comment_delimiter = update_comment_delimiter(comment_delimiter, line)
            if comment_delimiter > 0:
                output_list.append(line)
            elif comment_delimiter == 0:
                if len(line.strip()) == 0:
                    if blank_line_flag == 1:
                        pass
                    elif blank_line_flag == 0:
                        output_list.append(line)
                    blank_line_flag = 1
                elif len(line.strip()) > 0:
                    blank_line_flag = 0
                    output_list.append(line)
    with open(output_file, 'w') as writer:
        for i, output_line in enumerate(output_list):
            if i < len(output_list) - 1:
                writer.write(output_line)
            elif i == len(output_list) - 1:
                writer.write(output_line + "\n")

# Run linter program to correct script ===================
def stata_linter_correct_py(input_file, output_file, indent, tab_space):
    delimit_to_three_forward_slashes(input_file, output_file, indent, tab_space)
    tab_to_space(output_file, output_file, indent, tab_space)
    indent_in_bracket(output_file, output_file, indent, tab_space)
    too_long_line(output_file, output_file, indent, tab_space)
    space_before_curly(output_file, output_file, indent, tab_space)
    remove_blank_lines_before_curly_close(output_file, output_file, indent, tab_space)
    remove_duplicated_blank_lines(output_file, output_file, indent, tab_space)

end

/* *********** END program stata_linter_correct ***************************************** */



