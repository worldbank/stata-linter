### TITLE:
'STATA_LINTER': tool to detect and correct bad Stata coding practices

### DESCRIPTION
The stata_linter package provides a linter for Stata code.
Read about what a linter is here: https://en.wikipedia.org/wiki/Lint_(software).
The package contains a command that detects bad Stata coding practices in a do-file so that users can manually correct them.
The command can also correct some of the issues flagged in a new do-file.
The purpose of the command is to help users improve code clarity, readability, and organization in Stata do-files.
This linter is based on the best practices outlined in The DIME Analytics Coding Guide published as an appendix to the book Development Research in Practice.
See here https://worldbank.github.io/dime-data-handbook/coding.html. For more info about this linter, see https://github.com/worldbank/stata_linter.

### AUTHOR:
"DIME Analytics, DIME, The World Bank Group", dimeanalytics@worldbank.org

### KEYWORDS:
- linter
- style guide
- code best practices

### STATA VERSION REQUIREMENT:
Stata 16

### FILES IN PACKAGE
- lint.ado
- lint.sthlp
- stata_linter_correct.py
- stata_linter_detect.py
- stata_linter_utils.py
