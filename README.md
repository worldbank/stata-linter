# stata_linter - Stata Commands for do file linter

## Installation

Run the code beloew to install the current version in the `master` branch. If you want to install unpublished branches, replace _master_ in the URL below with the name of the branch you want to install from.

```stata
net install stata_linter, from("https://raw.githubusercontent.com/worldbank/stata-linter/master") replace
```

### Python Stand-alone

To install the linter to run directly with Python and not via Stata, clone the repository and then install using `pip`:

```python
pip install -e src/
```

This will also install `pandas` if it is not currently installed.

## Requirements

1. Stata version 16 or higher.
2. Python 3 or higher

For setting up Stata to use Python, refer to [this web page](https://blog.stata.com/2020/08/18/stata-python-integration-part-1-setting-up-stata-to-use-python/).
Also, for `stata_linter_detect` command in the package, a Python package `pandas` needs to be installed.
For how to install Python packages, refer to [this web page](https://blog.stata.com/2020/09/01/stata-python-integration-part-3-how-to-install-python-packages/). Refer to the wiki of this repo to more information about the requirements.

## Content

`stata_linter` provides a set of commands that attempt to improve readability of Stata do files. The commands are written based on good coding practices according to the standards at DIME (The World Bank’s unit for Impact Evaluations).

For these standards, refer to [DIME's Stata Coding practices](https://dimewiki.worldbank.org/wiki/Stata_Coding_Practices) and _Appendix: The DIME Analytics Coding Guide_ of [Development Research in Practice](https://worldbank.github.io/dime-data-handbook/).

This package contains two commands:

1. **stata_linter_detect** which detects bad coding practices in one or multiple Stata do files and returns the results.
2. **stata_linter_correct** which corrects bad coding practices in a Stata do file. Note that this command is not guaranteed to correct codes without changing results. It is strongly recommended that, after using this command, you check if results of the do file do not change.

## Examples

### stata_linter_detect

This function detects bad coding practices in one or multiple do-files and notifies which lines should be modified for better code readability. A required option is `file()` for one do-file or `folder()` for all do-files in a folder, but not both.

The basic usage is:

```stata
stata_linter_detect, file("test/bad.do") 
```

and on your Stata console you will get the results of which bad coding practices are found and in which lines:

```stata
Style =====================
(line 14) style: Use 4 white spaces instead of tabs. (This may apply to other lines as well.)
(line 15) style: Avoid to use "delimit". For line breaks, use "///" instead.
(line 17) style: This line is too long (82 characters). Use "///" for line breaks so that one line has at most 80 characters.
(line 25) style: After declaring for loop statement or if-else statement, add indentation (4 whitespaces).
(line 25) style: Use "!missing(var)" instead of "var < ." or "var != .".
...
...
Check =====================
(line 25) check: Are you taking missing values into account properly? (Remember that "a != 0" includes cases where a is missing.)
(line 25) style: Are you using tilde (~) for negation? If so, for negation, use bang (!) instead of tilde (~).
...
...

```

You see that there are two kinds of outputs:

1. `Style` chunk that shows the lines that likely contain bad coding practices, and;
2. `Check` chunk that shows the lines that potentially contain bad coding practices and are worth checking.

Using options `suppress` and `summary`, the command returns a summary of the results:

```stata
stata_linter_detect, file("test/bad.do") suppress summary
```

```stata
Summary (number of lines where bad practices are detected) =======================

[Style]
Hard tabs instead of soft tabs (whitespaces) used: Yes
Abstract index used in for-loop: 2
Not proper indentation in for-loop for if-else statement: 6
Not proper indentation in newline: 1
No whitespaces around math symbols: 0
Condition incomplete: 7
Not explicit if statement: 0
Delimit used: 1
cd used: 0
Line too long: 6
Parentheses not used for global macro: 0

[Check]
Missing values properly treated?: 7
Backslash used in file path?: 0
Bang (!) used instead of tilde (~) for negation?: 7
```

The results can be stored in an excel file with an option `excel()`:

```stata
stata_linter_detect, file("test/bad.do") excel("test/detect_output.xlsx")
```
### stata_linter_correct

> Note that this command is not guaranteed to correct codes without changing results. It is strongly recommended that, after using this command, you check if results of the do file do not change.

This command corrects bad coding practices in a do-file.
The required options are `input()` and `output()`. The file path to a do-file that you want to correct is passed to `input()` and `output()` will be the file name of the corrected do-file.

> It is strongly recommended that the output file name should be different from the input file name as the original do-file should be kept as a backup.

The basic usage of the command is as follows, and Stata will ask you which practices you would like to correct:

```stata
stata_linter_correct, input("${test_dir}/bad.do") output("${test_dir}/bad_correct.do") replace
```

If you would like to apply all rules, you can use an option `automatic`:

```stata
stata_linter_correct, input("${test_dir}/bad.do") output("${test_dir}/bad_correct.do") replace automatic
```

As a result of this command, for example,

```stata
#delimit ;

foreach something in something something something something something something
  something something{ ; // some comment
  do something ;
} ;

#delimit cr

```

becomes

```stata
foreach something in something something something something something something /// 
    something something {  // some comment
    do something  
}  
```

and

```stata
if something ~= 1 & something != . {
do something
if another == 1 {
do that
} 
}
```

becomes

```stata
if something ~= 1 & something != . {
    do something
    if another == 1 {
        do that
    } 
}
```

## Workflow example

To minimize the risk of crashing a do-file, `stata_linter_correct` works based on fewer rules than `stata_linter_detect`.
That is, `stata_linter_detect` can detect more bad coding practices that `stata_linter_correct` does.
Therefore, after writing codes in a do-file, you can first use `stata_linter_detect` to check how many bad coding practices are contained in the .do-file.

Afterwards, if there are not many bad practices, you can go through the lines flagged by `stata_linter_detect` and manually correct them, in which way you can avoid the potential crash by `stata_linter_correct` command.
If there are many bad practices detected, then you can use `stata_linter_correct` to correct some of the flagged lines, and then you can use `stata_linter_detect` again and correct the remaining bad practices manually.
After this process, do not forget to check if the results are not changed by `stata_linter_correct`.

## License

**stata_linter** is developed under MIT license. See http://adampritchard.mit-license.org/ or see [the `LICENSE` file](https://github.com/worldbank/ietoolkit/blob/master/LICENSE) for details.

## Main Contact
Luiza Cardoso de Andrade ([dimeanalytics@worldbank.org](mailto:dimeanalytics@worldbank.org))

## **Authors**
DIME Analytics Team, The World Bank

## About DIME Analytics

[DIME](https://www.worldbank.org/en/research/dime) is the World Bank's impact evaluation department. Part of DIME’s mission is to intensify the production of and access to public goods that improve the quantity and quality of global development research, while lowering the costs of doing IE for the entire research community. This Library is developed and maintained by [DIME Analytics](https://www.worldbank.org/en/research/dime/data-and-analytics). DIME Analytics supports quality research processes across the DIME portfolio, offers public trainings, and develops tools for the global community of development researchers.

Other DIME Analytics public goods are:
- [Development Research in Practice:](https://worldbank.github.io/dime-data-handbook/) the DIME Analytics Data Handbook
- [DIME Wiki:](https://dimewiki.worldbank.org/wiki/Main_Page) a one-stop-shop for impact evaluation resources
- [ietoolkit:](https://github.com/worldbank/ietoolkit) Stata package for impact evaluations
- [iefieldkit:](https://github.com/worldbank/iefieldkit) Stata package for primary data collection
- [Stata Visual Library](https://github.com/worldbank/stata-visual-library)
- [R Econ Visual Library](https://github.com/worldbank/r-econ-visual-library)
- [DIME Research Standards:](https://github.com/worldbank/dime-standards/blob/master/dime-research-standards/) DIME's commitments to best practices
