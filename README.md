# stata_linter - Stata command for do file linter

## Installation

### Installing published versions of `stata_linter`

To install `stata_linter`, type `ssc install stata_linter` and restart Stata.

This will install the most recent published version of `stata_linter`.
The main version of the code in this repository (the `master` branch) is what
is published on SSC as well.

### Python stand-alone installation

To install the linter to run directly with Python and not via Stata, clone this repository and then run the following command on your terminal:

```python
pip install -e src/
```

This will also install `pandas` and `openpyxl` if they are not currently installed.

## Requirements

1. Stata version 16 or higher.
2. Python 3 or higher

For setting up Stata to use Python, refer to [this web page](https://blog.stata.com/2020/08/18/stata-python-integration-part-1-setting-up-stata-to-use-python/).
`stata_linter` also requires the Python package `pandas` and `openpyxl`.
Refer to [this web page](https://blog.stata.com/2020/09/01/stata-python-integration-part-3-how-to-install-python-packages/) to know more about installing Python packages.

## Content

The `stata_linter` package works through the `lint` command.
`lint` is an opinionated detector that attempts to improve the readability and organization of Stata do files.
The command is written based on the good coding practices of the Development Impact Evaluation Unit at The World Bank.
For these standards, refer to [DIME's Stata Coding practices](https://dimewiki.worldbank.org/wiki/Stata_Coding_Practices) and _Appendix: The DIME Analytics Coding Guide_ of [Development Research in Practice](https://worldbank.github.io/dime-data-handbook/).

The `lint` command can be broken into two functionalities:

1. **detection** identifies bad coding practices in one or multiple Stata do-files
2. **correction** corrects a few of the bad coding practices detected in a Stata do-file

> _Disclaimer_: Please note that this command is not guaranteed to correct codes without changing results.
It is strongly recommended that after using this command you check if results of the do file do not change.

## Syntax and basic usage

```stata
lint "input_file" using "output_file", options  
```

### 1. Detection

To detect bad practices in a do-file you can run the following:

```stata
lint "test/bad.do"
```

and on your Stata console you will get a summary of bad coding practices that were found in your code:

```stata
-------------------------------------------------------------------------------------
Bad practice                                                          Occurrences                   
-------------------------------------------------------------------------------------
Hard tabs used instead of soft tabs:                                  Yes       
One-letter local name in for-loop:                                    3
Non-standard indentation in { } code block:                           7
No indentation on line following ///:                                 1
Missing whitespaces around operators:                                 0
Implicit logic in if-condition:                                       1
Delimiter changed:                                                    1
Working directory changed:                                            0
Lines too long:                                                       5
Global macro reference without { }:                                   0
Use of . where missing() is appropriate:                              6
Backslash detected in potential file path:                            0
Tilde (~) used instead of bang (!) in expression:                     5
-------------------------------------------------------------------------------------
```

If you want to get the lines where those bad coding practices appear you can use the option `verbose`. For example:

```stata
lint "test/bad.do", verbose
```

Gives the following information before the regular output of the command.

```stata
(line 14): Use 4 white spaces instead of tabs. (This may apply to other lines as well.)
(line 15): Avoid to use "delimit". For line breaks, use "///" instead.
(line 17): This line is too long (82 characters). Use "///" for line breaks so that one line has at m
> ost 80 characters.
(line 25): After declaring for loop statement or if-else statement, add indentation (4 whitespaces).
(line 25): Always explicitly specify the condition in the if statement. (For example, declare "if var
>  == 1" instead of "if var".)
...
```

You can also pass a folder path to detect all the bad practices in all the do-files that are in the same folder.

### 2. Correction

If you would like to correct bad practices in a do-file you can run the following:

```stata
lint "test/bad.do" using "test/bad_corrected.do"   
```

In this case, the lint command will create a do-file called `bad_corrected.do`.
Stata will ask you if you would like to perform a set of corrections for each bad practice detected, one by one.
You can add the option `automatic` to perform the corrections automatically and skip the manual confirmations.
It is strongly recommended that the output file has a different name from the input file, as the original do-file should be kept as a backup.

As a result of this command, a piece of Stata code as the following:

```stata
#delimit ;

foreach something in something something something something something something
  something something{ ; // some comment
  do something ;
} ;

#delimit cr

```

becomes:

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

### Other options

You can use the following options with the `lint` command:

- Options related to the **detection** feature:
  - `verbose`: show all the lines where bad practices appear.
  - `nosummary`: suppress the summary of bad practices.
  - `excel()`: export detection results to Excel.

- Options exclusive to the **correction** feature:
  - `automatic`: correct all bad coding practices without asking if you want each bad coding practice detected to be corrected or not.
  - `replace`: replace the existing output file.
  - `force`: allow the output file name to be the same as the name of the input file (not recommended).

- Options for **both** features:
  - `indent()`: specify the number of whitespaces used for indentation (default is 4).
  - `linemax()`: maximum number of characters in a line (default: 80)
  - `tab_space()`: number of whitespaces used instead of hard tabs (default is 4).

## Coding practices to be detected

- **Use soft tabs (i.e., whitespaces), not hard tabs:**
Use white spaces (usually 2 or 4 whitespaces are used) instead of hard tabs.
You can change this option in the do-file editor preferences.

- **Avoid using abstract index names:**
In *for loops*, index names should describe what the code is looping over.
Hence, for example, avoid coding like this:

  ```{stata}
  foreach i of var cassava maize wheat { }
  ```

  Instead, looping commands should name the index local descriptively:

  ```{stata}
  foreach crop of var cassava maize wheat { }
  ```

- **Use proper indentations:**
After declaring a for loop statement or if-else statement, add indentation with whitespaces (usually 2 or 4 whitespaces).

- **Use indentations after declaring newline symbols `///`:**
After a new line statement `(///)`, add indentation (usually 2 or 4 whitespaces).

- **Use `!missing()` function for conditions of missing values:**
For clarity, use `!missing(var)` instead of `var < .` or `var != .`

- **Add whitespaces around math symbols (`+`, `=`, `<`, `>`):**
For better readability, add whitespaces around math symbols.
For example, write `gen a = b + c if d == e` instead of `gen a=b+c if d==e`.

- **Specify the condition in the if statement:**
Always explicitly specify the condition in the if statement.
For example, declare `if var == 1` instead of `if var`.

- **Do not use `delimit`, instead use `///` for line breaks:**
More information about the use of line breaks [here](https://worldbank.github.io/dime-data-handbook/coding.html#line-breaks).

- **Do not use the `cd` command to change the current folder:**
Use absolute and dynamic file paths. More about this [here](https://worldbank.github.io/dime-data-handbook/coding.html#writing-file-paths).

- **Use line breaks for too long lines:**
For lines that are too long, use `///` for line breaks and divide them into multiple lines.
It is recommended to restrict the number of characters in a line under 80.
Though sometimes this is difficult since, for example, Stata does not allow line
breaks within double quotes, try to follow this rule when possible.

- **Use curly brackets for global macros:**
Always use `${ }` for global macros.
For instance, use `${global}` instead of `$global`.

- **Include missing values in condition expressions:**
Condition expressions like `var != 0` or `var > 0` are evaluated to true for missing values.
Make sure to explicitly take missing values into account by using `missing()` in expressions.

- **Check if backslashes are not used in file paths:**
Check if backslashes `(\)` are not used in file paths.
If you are using them, then replace them with forward slashes `(/)`.

- **Check if tildes `(~)` are not used for negations:**
If you are using tildes `(~)` for negations, replace them with the bang symbol `(!)`.

## Coding practices to be corrected

The `correction` feature does not correct all the bad practices detected by `detect`.
It only corrects the following:

- Replaces the use of `delimit` with three forward slashes (`///`) in each line affected by `delimit`
- Replaces hard tabs with soft spaces (4 by default). The amount of spaces can be set with the `tab_space()` option
- Indents lines inside curly brackets with 4 spaces by default. The amount of spaces can be set with the `indent()` option
- Breaks long lines into two lines. Long lines are considered to have more than 80 characters by default, but this setting can be changed with the option `linemax()`
- Adds a whitespace before opening curly brackets, except for globals
- Removes redundant blank lines after closing curly brackets
- Removes duplicated blank lines

If the option `automatic` is omitted, `lint` will prompt the user to confirm that they want to correct each of these bad practices only in case they are detected. If none of these are detected, it will show the message:

  ```{stata}
  Nothing to correct.
  The issues lint is able to correct are not present in your dofile.
  No output files were generated.
  ```

## Recommended use

To minimize the risk of crashing a do-file, the `correction` feature works based on fewer rules than the `detection` feature.
That is, we can can detect more bad coding practices with `lint "input_file"` in comparison to `lint "input_file" using "output_file"`.
Therefore, after writing a do-file, you can first `detect` bad practices to check how many bad coding practices are contained in the do-file and later decide whether you would like to use the correction feature.

If there are not too many bad practices, you can go through the lines flagged by the `detection` feature and manually correct them.
This also avoids potential crashes by the `correction` feature.

If there are many bad practices detected, you can use the `correction` feature first to correct some of the flagged lines, and then you can `detect` again and `correct` the remaining bad practices manually.
We strongly recommend not overwriting the original input do-file so it can remain as a backup in case `correct` introduces unintended changes in the code.
Additionally, we recommend checking that the results of the do-file are not changed by the correction feature.

## Bug Reports and Feature Requests

If you are familiar with GitHub go to the [**Contributions**](https://github.com/worldbank/stata-linter#contributions) section below for advanced instructions.

An easy but still very efficient way to provide any feedback on these commands is to create an *issue* in GitHub. You can read *issues* submitted by other users or create a new *issue* in the top menu below [**worldbank**/**stata-linter**](https://github.com/worldbank/stata-linter). If you have an idea for a new command, or a new feature on an existing command, creating an *issue* is a great tool for suggesting that. Please read already existing *issues* to check whether someone else has made the same suggestion or reported the same error before creating a new *issue*.

While we have a slight preference for receiving feedback here on GitHub, you are still very welcome to send a regular email with your feedback to [dimeanalytics@worldbank.org](mailto:dimeanalytics@worldbank.org).

## Contributions

If you are not familiar with GitHub see the [**Bug reports and feature requests**](https://github.com/worldbank/stata-linter#bug-reports-and-feature-requests) section above for a less technical but still very helpful way to contribute to **stata-linter**.

We appreciate contributions directly to the code and will give credit to anyone providing contributions that we merge to the master branch.
If you have any questions on anything in this section, please do not hesitate to email [dimeanalytics@worldbank.org](mailto:dimeanalytics@worldbank.org).

The files on the `master` branch are the files most recently released on the SSC server.
README, LICENSE and similar files are updated directly to `master` in between releases.
All the other files are updated in the `develop` branch before being merged into `master`.
Check out the `develop` branch if you want to see what future updates we are currently working on.

Please make pull requests to the `master` branch **only** if you wish to contribute to README, LICENSE or similar meta data files.
If you wish to make a contribution to any other file, then please **do not** use the `master` branch.
Instead, please fork this repository from `develop` and make your pull request to that branch.
The `develop` branch includes all minor edits we have made to already published commands since the last release that we will include in the next version released on the SSC server.

## License

**stata_linter** is developed under MIT license. See http://adampritchard.mit-license.org/ or see [the `LICENSE` file](https://github.com/worldbank/ietoolkit/blob/master/LICENSE) for details.

## Main Contact

Luis Eduardo San Martin ([dimeanalytics@worldbank.org](mailto:dimeanalytics@worldbank.org))

## **Authors**

This command is developed by DIME Analytics at DIME, The World Bank's department for Development Impact Evaluations.

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
