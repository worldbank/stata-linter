/********************************************************************************/
/* program stata_linter_correct : Linter sdo file: correct bad coding practices */
/********************************************************************************/
cap prog drop stata_linter_correct
program def stata_linter_correct
    version 16
    syntax, Input(string) Output(string) [Indent(string)]

    * set indent size = 4 if indent is missing
    if missing("`indent'") local indent "4"

    * call the python function
    python: stata_linter_correct_py("`input'", "`output'", "`indent'")

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

# Functions for auto-correction ===================

# Convert delimit to three forward slashes
def delimit_to_three_forward_slashes(input_file, output_file, indent):
    output_list = []
    with open(input_file, 'r') as reader:
        input_lines = reader.readlines()
        delimit_on = 0
        for line_index, line in enumerate(input_lines):
            if re.search(r"#delimit ((?!cr).+)", line):
                delimit_on = 1
                delimit_symbol = re.search(r"#delimit ((?!cr).+)", line).group(1).strip()
            elif re.search(r"#delimit cr", line):
                delimit_on = 0
            else:
                if delimit_on == 0:
                    output_list.append(line)
                elif delimit_on == 1:
                    line_split_for_comment = re.split(r"//", line)
                    line_main = line_split_for_comment[0]
                    if len(line_split_for_comment) > 1:
                        line_comment = line_split_for_comment[1]

                    line_main_rstrip = line_main.rstrip()
                    if len(line_main_rstrip) > 0:
                        if line_main_rstrip[-1] != delimit_symbol:
                            if len(line_split_for_comment) > 1:
                                output_list.append(line_main_rstrip + " ///" + line_comment)
                            elif len(line_split_for_comment) == 1:
                                output_list.append(line_main_rstrip + " ///\n")
                        elif line_main_rstrip[-1] == delimit_symbol:
                            if len(line_split_for_comment) > 1:
                                output_list.append(re.sub(delimit_symbol, "", line_main).rstrip() + " //" + line_comment)
                            elif len(line_split_for_comment) == 1:
                                output_list.append(re.sub(delimit_symbol, "", line_main).rstrip() + " \n")
                    if len(line_main_rstrip) == 0:
                        output_list.append(line)
                    
    with open(output_file, 'w') as writer:
        for output_line in output_list:
            writer.write(output_line)


# Convert hard tabs to soft tabs (= whitespaces)
def tab_to_space(input_file, output_file, indent):
    output_list = []
    with open(input_file, 'r') as reader:
        input_lines = reader.readlines()
        for line_index, line in enumerate(input_lines):
            output_list.append(line.replace("\t", " " * int(indent)))
    with open(output_file, 'w') as writer:
        for output_line in output_list:
            writer.write(output_line)

# Use indents in brackets after for and while loops or if/else conditions
def indent_in_bracket(input_file, output_file, indent):
    with open(input_file, 'r') as reader:
        input_lines = reader.readlines()
        loop_start = []
        bracket_start = []
        bracket_pair = []
        nest_level = 0
        max_nest_level = 0
        for line_index, line in enumerate(input_lines):
            line_rstrip = re.sub(r'//.*', r'', line).rstrip()
            if len(line_rstrip) > 0:
                if re.search(re.compile(r"^(foreach |while |forval|if |else |cap)"), line.lstrip()) != None:
                    if line_rstrip[-1] == "{":
                        loop_start.append(line_index)
                        bracket_start.append(line_index)
                        nest_level += 1
                        max_nest_level = max(max_nest_level, nest_level)
                    elif (line_rstrip[-1] != "{") & (re.search(r"//", line) != None):
                        loop_start.append(line_index)
                        for i in range(line_index, len(input_lines)):
                            temp_line_rstrip = re.sub(r'//.*', r'', input_lines[i]).rstrip()
                            if temp_line_rstrip[-1] == "{":
                                bracket_start.append(i)
                                break
                        nest_level += 1
                        max_nest_level = max(max_nest_level, nest_level)
                if (line_rstrip[-1] == "}") & (not re.search(r'\$.?{', line)):
                    bracket_pair.append([loop_start.pop(), line_index, nest_level, bracket_start.pop()])
                    nest_level -= 1
        for nest_level in range(1, max_nest_level + 1):
            for pair in bracket_pair:
                if pair[2] == nest_level:
                    start_indent = len(input_lines[pair[0]]) - len(input_lines[pair[0]].lstrip())
                    for j in range(pair[0] + 1, pair[1]):
                        if len(input_lines[j].lstrip()) == 0:
                            pass
                        elif len(input_lines[j].lstrip()) > 0:
                            input_lines[j] = ' ' * (start_indent + int(indent)) + (input_lines[j].lstrip())
    with open(output_file, 'w') as writer:
        for output_line in input_lines:
            writer.write(output_line)

# Split too long line (> 80 characters) to multiple lines
# (but do not break strings in double quotes (""))
def too_long_line(input_file, output_file, indent):
    output_list = []
    with open(input_file, 'r') as reader:
        input_lines = reader.readlines()
        newline_flag = 0
        for line_index, line in enumerate(input_lines):
            if (len(line) <= 80) | ((line.lstrip() + ' ')[0] == "*") | ((line.lstrip() + '  ')[:2] == "//") | ("///" in line):
                output_list.append(line)
            else:
                line_split_for_comment = re.split(r"//", line)
                line_main = line_split_for_comment[0]
                if len(line_split_for_comment) > 1:
                    line_comment = line_split_for_comment[1]
                line_indent = len(line_main) - len(line_main.expandtabs(int(indent)).lstrip())

                i = 0
                break_line = []
                double_quote_count = 0
                parenthesis_count = 0
                curly_count = 0
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
                        (((i >= 30) & (c == ',')) | (i >= 70)) & 
                        (double_quote_count == 0) & (parenthesis_count == 0) & (curly_count == 0)
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

                line_split = []
                break_line_index = [0]
                break_line_index.extend(break_line)
                break_line_index.append(len(line_main))
                for k in range(len(break_line_index) - 1):
                    line_split.append(line_main[break_line_index[k]:break_line_index[k + 1]])

                if len(line_split) == 1:
                    if len(line_split_for_comment) > 1:
                        output_list.append(' ' * line_indent + line_split[0].lstrip() + " //" + line_comment)
                    elif len(line_split_for_comment) == 1:
                        output_list.append(' ' * line_indent + line_split[0].lstrip() + "\n")
                elif len(line_split) > 1:
                    for i, temp_line in enumerate(line_split):
                        if i == 0:
                            new_line = ' ' * line_indent + temp_line.lstrip() + " ///\n"
                        elif (i > 0) & (i < len(line_split) - 1):
                            if newline_flag == 0:
                                new_line = ' ' * (line_indent + int(indent)) + temp_line.lstrip() + " ///\n"
                            elif newline_flag == 1:
                                new_line = ' ' * (line_indent) + temp_line.lstrip() + " ///\n"
                        elif (i == len(line_split) - 1):
                            if newline_flag == 0:
                                new_line = ' ' * (line_indent + int(indent)) + temp_line.lstrip()
                            elif newline_flag == 1:
                                new_line = ' ' * (line_indent) + temp_line.lstrip()
                            if len(line_split_for_comment) > 1:
                                new_line = new_line + " //" + line_comment
                        output_list.append(new_line)
            if "///" in line:
                newline_flag = 1
            else:
                newline_flag = 0
    with open(output_file, 'w') as writer:
        for output_line in output_list:
            writer.write(output_line)

# Add a white space before a curly bracket
# (but not if the curly bracket is used for global macro, as in "${---}")
def space_before_curly(input_file, output_file, indent):
    output_list = []
    with open(input_file, 'r') as reader:
        input_lines = reader.readlines()
        for line_index, line in enumerate(input_lines):
            output_list.append(re.sub(r'([^ $]){', r'\1 {', line))
    with open(output_file, 'w') as writer:
        for output_line in output_list:
            writer.write(output_line)

# Remove blank lines before curly brackets are closed
def remove_blank_lines_before_curly_close(input_file, output_file, indent):
    output_list = []
    with open(input_file, 'r') as reader:
        input_lines = reader.readlines()
        for line_index, line in enumerate(input_lines):
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


# Remove duplicated blank lines
def remove_duplicated_blank_lines(input_file, output_file, indent):
    output_list = []
    with open(input_file, 'r') as reader:
        input_lines = reader.readlines()
        blank_line_flag = 0
        for line_index, line in enumerate(input_lines):
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
def stata_linter_correct_py(input_file, output_file, indent):
    delimit_to_three_forward_slashes(input_file, output_file, indent)
    tab_to_space(output_file, output_file, indent)
    indent_in_bracket(output_file, output_file, indent)
    too_long_line(output_file, output_file, indent)
    space_before_curly(output_file, output_file, indent)
    remove_blank_lines_before_curly_close(output_file, output_file, indent)
    remove_duplicated_blank_lines(output_file, output_file, indent)

end

/* *********** END program stata_linter_correct ***************************************** */



