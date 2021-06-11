# stata_liner - Stata command for do file linter

## Installation

To install this command run the following:

```stata
net install stata_linter, from("https://raw.githubusercontent.com/worldbank/stata-linter/master") replace
```

## Requirements

1. Stata version 16 or higher.
2. Python 3 or higher

For setting up Stata to use Python, refer to [this web page](https://blog.stata.com/2020/08/18/stata-python-integration-part-1-setting-up-stata-to-use-python/). The `lint` command also requires the Python package `pandas`. Refer to [this web page](https://blog.stata.com/2020/09/01/stata-python-integration-part-3-how-to-install-python-packages/) to know more about installing Python packages. Finally, you can also refer to the wiki of this repo to know about requirements, examples, and more.

## Content

The `lint` command is an opinionated detector that attempts to improve readability of Stata do files. The command is written based on the good coding practices of the Development Impact Evaluation Unit at The World Bank. For these standards, refer to [DIME's Stata Coding practices](https://dimewiki.worldbank.org/wiki/Stata_Coding_Practices) and _Appendix: The DIME Analytics Coding Guide_ of [Development Research in Practice](https://worldbank.github.io/dime-data-handbook/).

The `lint` command can be broken into two functionalities:

1. **detection** which refers to identifying bad coding practices in one or multiple Stata do-files;
2. **correction** which refers to correcting bad coding practices in a Stata do-file.

> _Disclaimer_: Note that this command is not guaranteed to correct codes without changing results. It is strongly recommended that, after using this command, you check if results of the do file do not change.

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
Summary (number of lines where bad practices are detected) =======================

[Style]
Hard tabs instead of soft tabs (whitespaces) used: Yes
Abstract index used in for-loop: 3
Not proper indentation in for-loop for if-else statement: 7
Not proper indentation in newline: 1
Missing whitespaces around math symbols: 0
Incomplete conditions: 6
Not explicit if statement: 0
Delimit used: 1
cd used: 0
Lines too long: 5
Brackets not used for global macro: 0

[Check]
Missing values properly treated?: 7
Backslash used in file path?: 0
Bang (!) used instead of tilde (~) for negation?: 6
```

The output is divided into two:

1. `[Style]` chunk that shows the lines that likely contain bad coding practices, and;
2. `[Check]` chunk that shows the lines that contain bad coding practices that could produce erroneous results and are worth checking.

If you want to get the lines where those bad coding practices appear you can use the option `verbose`:

```stata
Style =====================
(line 14) style: Use 4 white spaces instead of tabs. (This may apply to other lines as well.)
(line 15) style: Avoid to use "delimit". For line breaks, use "///" instead.
(line 17) style: This line is too long (82 characters). Use "///" for line breaks so that one line has at most 80 characters.
(line 25) style: After declaring for loop statement or if-else statement, add indentation (4 whitespaces).
...
...
Check =====================
(line 25) check: Are you taking missing values into account properly? (Remember that "a != 0" includes cases where a is missing.)
(line 25) style: Are you using tilde (~) for negation? If so, for negation, use bang (!) instead of tilde (~).
...
...
```

You can also pass a folder path to detect all the bad practices in all the do-files that are in the same folder.

### 2. Correction

If you would like to correct bad practices in a do-file you can run the following:

```stata
lint "test/bad.do" using "test/bad_corrected.do"   
```

In this case, the lint command will export a do-file called `bad_corrected.do`. Stata will ask you if you would like to perform a set of correction. You can add the option `automatic` to perform the correction automatically. Additionally, it is strongly recommended that the output file has a different from the input file, as the original do-file should be kept as a backup.

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

### Other options

You can use the following options with the `lint` command:

- Options related to the **detection** feature:
  - `verbose`: shows all the lines where bad practices appear.
  - `nosummary`: suppress the summary of bad practices.
  - `excel()`: export detection results to excel.

- Options related to the **correction** feature:
  - `automatic`: correct all bad coding practices without asking if you want each bad coding practice to be corrected or not (use only with the correction feature).
  - `replace`: replace the existing output file (use only with the correction feature).
  - `inprep`: allow the output file name to be the same as the name of the input file (use only with the correction feature).
  
- Options for **both** features:
  - `indent()`: specify the number of whitespaces used for indentation (default is 4).
  - `nocheck`: removes suggestions to check and only show style problems.
  - `linemax()`: maximum number of characters in a line (default: 80)
  - `tab_space()`: number of whitespaces used instead of hard tabs (default is 4).

## Workflow

To minimize the risk of crashing a do-file, the `correction` feature works based on fewer rules than the `detection` feature. That is, we can can detect more bad coding practices with `lint "input_file"` in comparison to `lint "input_file" using "output_file"`. Therefore, after writing a do-file, you can first `detect` bad practices to check how many bad coding practices are contained in the do-file and later decide whether you would like to use the correction feature.

If there are not many bad practices, you can go through the lines flagged by the `detection` feature and manually correct them avoiding, in this case, potential crashes by the `correction` feature.

If there are many bad practices detected, you can use the `correction` feature first to correct some of the flagged lines, and then you can `detect` again and `correct` the remaining bad practices manually. After this process, do not forget to check if the results are not changed by the correction feature.

## License

**stata_linter** is developed under MIT license. See http://adampritchard.mit-license.org/ or see [the `LICENSE` file](https://github.com/worldbank/ietoolkit/blob/master/LICENSE) for details.

## Main Contact

Luiza Cardoso de Andrade ([dimeanalytics@worldbank.org](mailto:dimeanalytics@worldbank.org))

## **Authors**

This command is developed by DIME Analytics at DECIE, The World Bank's unit for Development Impact Evaluations.

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
