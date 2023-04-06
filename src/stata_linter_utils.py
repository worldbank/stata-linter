# version 1.02  06apr2023  DIME Analytics dimeanalytics@worldbank.org
# Import packages ====================
import re
import pandas as pd
import stata_linter_detect as sld

# functions

def read_dofile(file, include_comments=False):

    '''
    Returns a list of the lines in the dofile
    Omits comment lines or commented-out code by default
    '''

    with open(file, "r") as f:
        dofile_lines = f.readlines()

    if include_comments:
        return dofile_lines

    dofile_lines2 = []
    comment_delimiter = 0

    for line in dofile_lines:

        comment_delimiter = sld.update_comment_delimiter(comment_delimiter, line)

        if comment_delimiter == 0:
            # Removing end-of-line comments
            filtered_line = re.sub(r"\s*((\/\/)|(\/\*)).*", r"", line)
            dofile_lines2.append(filtered_line)

    return dofile_lines2

def detect_duplicated_blank_line_in_file(file):

    dofile_lines = read_dofile(file, include_comments=True)

    for line_index, line in enumerate(dofile_lines):

        if sld.detect_duplicated_blank_line(line_index, line, dofile_lines):
            return True

    return False

def detect_blank_line_before_curly_close_in_file(file):

    dofile_lines = read_dofile(file, include_comments=True)

    for line_index, line in enumerate(dofile_lines):

        if sld.detect_blank_line_before_curly_close(line_index, line, dofile_lines):
            return True

    return False

def detect_no_space_before_curly_bracket_in_file(file):

    dofile_lines = read_dofile(file)

    for line in dofile_lines:

        if sld.detect_no_space_before_curly_bracket(line):
            return True

    return False

def detect_line_too_long_in_file(file, linemax):

    dofile_lines = read_dofile(file)
    linemax = int(linemax)

    for line in dofile_lines:

        if sld.detect_line_too_long(line, linemax):
            return True

    return False

def detect_bad_indent_in_file(file, indent, tab_space):

    dofile_lines = read_dofile(file)
    indent = int(indent)
    tab_space = int(tab_space)

    for line_index, line in enumerate(dofile_lines):

        if sld.detect_bad_indent(line_index, line, dofile_lines, indent, tab_space):
            return True

    return False

def detect_hard_tab_in_file(file):

    dofile_lines = read_dofile(file)

    for line in dofile_lines:

        if sld.detect_hard_tab(line):
            return True

    # No hard tabs detected in any line
    return False

def detect_delimit_in_file(file):

    dofile_lines = read_dofile(file)

    for line in dofile_lines:

        if sld.detect_delimit(line):
            # whenever the first delimiter is detected, return True
            # and interrupt script
            return True

    # if delimiters were never detected, return False
    return False
