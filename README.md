**stata_linter - Stata Commands for do file linter**
=====

### **Install and Update**

<!-- #### Installing published versions of `ietoolkit`
To install **ietoolkit**, type **`ssc install ietoolkit`** in Stata. This will install the latest published version of **ietoolkit**. The main version of the code in the repo (the `master` branch) is what is published on SSC as well. 

If you think something is different in version in this repo, and the version installed on your computer, make sure that you both look at the `master` branch in this repo, and that you have the most recent version of **ietoolkit** installed. To update all files associated with **ietoolkit** type **`adoupdate ietoolkit, update`** in Stata. (It is wise to be in the habit of regularly checking if any of your .ado files installed in Stata need updates by typing **`adoupdate`**.)

When we are publishing new versions of **ietoolkit** then there could be a discrepancy between the master branch and the version on SSC as the master branch is updates a couple of days before. You can confirm if that could be the case by checking if we recently published a new [release](https://github.com/worldbank/ietoolkit/releases). -->

<!---#### Installing unpublished branches of this repository--->
<!---Follow the instructions above if you want the most recent published version of **ietoolkit**. If you want a yet to be published version of **ietoolkit** then you can use the code below. ---> 
The code below installs the version currently in the `master` branch.
If you want to install unpublished branches, replace _master_ in the URL below with the name of the branch you want to install from. 
<!---You can also install older version of **ietoolkit** like this but it will only go back to January 2019 when we set up this method of installing the package.--->

```stata
net install stata_linter, from("https://raw.githubusercontent.com/worldbank/stata-linter/master") replace
```

#### Requirements
Stata version 16 or later and Python installation are required for this package of commands.
For setting up Stata to use Python, refer to [this web page](https://blog.stata.com/2020/08/18/stata-python-integration-part-1-setting-up-stata-to-use-python/).
Also, for `stata_linter_detect` command in the package, a Python package `pandas` needs to be installed.
For how to install Python packages, refer to [this web page](https://blog.stata.com/2020/09/01/stata-python-integration-part-3-how-to-install-python-packages/).

### **Background**
These commands are developed by people that work at or with the Development Impact Evaluations (DIME) department at the World Bank. 

<!---
### **Bug Reports and Feature Requests**
If you are familiar with GitHub go to the **Contributions** section below for advanced instructions.

An easy but still very efficient way to provide any feedback on these commands is to create an *issue* in GitHub. You can read *issues* submitted by other users or create a new *issue* in the top menu below [**worldbank**/**ietoolkit**](https://github.com/worldbank/ietoolkit) at [https://github.com/worldbank/ietoolkit](https://github.com/worldbank/ietoolkit). While the word *issue* has a negative connotation outside GitHub, it can be used for any kind of feedback. If you have an idea for a new command, or a new feature on an existing command, creating an *issue* is a great tool for suggesting that. Please read already existing *issues* to check whether someone else has made the same suggestion or reported the same error before creating a new *issue*.

While we have a slight preference for receiving feedback here on GitHub, you are still very welcome to send a regular email with your feedback to [dimeanalytics@worldbank.org](mailto:dimeanalytics@worldbank.org).
--->

### **Content**
**stata_linter** provides a set of commands that attempt to improve readability of Stata do files.
The list of commands will be extended continuously, and suggestions for new commands are greatly appreciated. 
The commands are written based on good coding practices according to the standards at DIME (The World Bank’s unit for Impact Evaluations).
For these standards, refer to [DIME's Stata Coding practices](https://dimewiki.worldbank.org/wiki/Stata_Coding_Practices) and _Appendix: The DIME Analytics Coding Guide_ of [Development Research in Practice](https://worldbank.github.io/dime-data-handbook/).
For the commands in this package, the corresponding help files provide justifications for the standardized best practices applied.

- **stata_linter_detect** detects bad coding practices in one or multiple Stata do files and returns the results.
- **stata_linter_correct** corrects bad coding practices in a Stata do file. **Note that this command is not guaranteed to correct codes without changing results. It is strongly recommended that, after using this command, you check if results of the do file do not change.**

### **Examples**

#### `stata_linter_detect`

This function detects bad coding practices in one or multiple `.do` files and notifies which lines should be modified for better code readability.
A required option is `file()` for one `.do` file or `folder()` for all `.do` files in a folder, but not both.
A basic command is

```
  stata_linter_detect, file("test/bad.do") 
```

and on Stata console you will get the results of which bad coding practices are found in which lines:

```
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
`Style` chunk shows the lines that likely contain bad coding practices, and `Check` chunk shows the lines that potentially contain bad coding practices and worth checking. 
If you only want to see `Style` outputs, use `nocheck` option.

Using options `suppress` and `summary`, the command returns the summary results:

```
  stata_linter_detect, file("test/bad.do") suppress summary
```

```
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

```
  stata_linter_detect, file("test/bad.do") excel("test/detect_output.xlsx")
```

If an option `folder()`, not `file()`, is used, the command is applied to all `.do` files in a folder.
The following command checks bad coding practices in all `.do` files in a folder and store the results in an excel file:

```
  stata_linter_detect, folder("test") excel("test/detect_output.xlsx")
```

#### `stata_linter_correct`

**Note that this command is not guaranteed to correct codes without changing results. It is strongly recommended that, after using this command, you check if results of the do file do not change.**

This command corrects bad coding practices in a `.do` file.
Required options are `input()` and `output()`:
the file path to a `.do` file that you want to correct is passed to `input()` and `output()` will be the file name of the corrected `.do` file.
**It is strongly recommended that the output file name should be different from the input file name as the original `.do` file should be kept as a backup.**

There are several rules used in the command: indentations are added in curly brackets, a long line is split into multiple lines, etc.
The following command asks you which rule you would like to apply to your `.do` file:

```
  stata_linter_correct, input("${test_dir}/bad.do") output("${test_dir}/bad_correct.do") replace
```

If you would like to apply all rules, you can use an option `automatic`:

```
  stata_linter_correct, input("${test_dir}/bad.do") output("${test_dir}/bad_correct.do") replace automatic
```

As a results of this command, for example,

```
	#delimit ;

	foreach something in something something something something something something
		something something{ ; // some comment
		do something ;
	} ;

	#delimit cr

```

becomes

```
    foreach something in something something something something something something /// 
        something something {  // some comment
        do something  
    }  
```

and

```
	if something ~= 1 & something != . {
	do something
	if another == 1 {
	do that
	} 
	}

```

becomes

```
    if something ~= 1 & something != . {
        do something
        if another == 1 {
            do that
        } 
    }
```

### Workflow example

To minimize the risk of crashing a `.do` file, `stata_linter_correct` works based on fewer rules than `stata_linter_detect`.
That is, `stata_linter_detect` can detect more bad coding practices that `stata_linter_correct` does.
Therefore, after writing codes in a `.do` file, you can first use `stata_linter_detect` to check how many bad coding practices are contained in the `.do` file.
Afterwards, if there are not many bad practices, you can go through the lines flagged by `stata_linter_detect` and manually correct them, in which way you can avoid the potential crash by `stata_linter_correct` command.
If there are many bad practices detected, then you can use `stata_linter_correct` to correct some of the flagged lines, and then you can use `stata_linter_detect` again and correct the remaining bad practices manually.
After this process, do not forget to check if the results are not changed by `stata_linter_correct`.

<!----
### **Contributions**
If you are not familiar with GitHub see the **Bug reports and feature requests** section above for a less technical but still very helpful way to contribute to **ietoolkit**.

GitHub is a wonderful tool for collaboration on code. We appreciate contributions directly to the code and will of course give credit to anyone providing contributions that we merge to the master branch. If you have any questions on anything in this section, please do not hesitate to email [dimeanalytics@worldbank.org](mailto:dimeanalytics@worldbank.org). See [CONTRIBUTING.md](https://github.com/worldbank/ietoolkit/blob/master/CONTRIBUTING.md) for some more details on for example naming conventions.

The Stata files on the `master` branch are the files most recently released on the SSC server. README, LICENSE and similar files are updated directly to `master` in between releases. Check out any of the `develop` branches (if there are any) if you want to see what future updates we are currently working on.

Please make pull requests to the `master` branch **only** if you wish to contribute to README, LICENSE or similar meta data files. If you wish to make a contribution to any Stata file, then please **do not** use the `master` branch. If you wish to make a contribution to any Stata files that we have published at least once, then please fork from and make your pull request to the `develop` branch. The `develop` branch includes all minor edits we have made to already published commands since the last release that we will include in the next version released on the SSC server. If your addition is related to a specific issue in this repository, then see the naming convention in the [CONTRIBUTING.md](https://github.com/worldbank/ietoolkit/blob/master/CONTRIBUTING.md) file.

All Stata commands we are working on that we have yet to release a first version of, are found in the branches called `develop-NAME` where *NAME* corresponds to the working name of the command that is yet to be published. If you wish to contribute to any of those commands, then please fork from the branch of the command you want to contribute to, and only make edits to the .ado/.do and .sthlp that correspond to that command. If you want to make contributions to multiple commands that have yet to be released, then you will have to fork from and make pull request to multiple branches.

If you wish to make a contribution by making *forks and pull requests* but are not exactly sure how to do so, feel free to send an email to [dimeanalytics@worldbank.org](mailto:dimeanalytics@worldbank.org).
---->

### **License**
**stata_linter** is developed under MIT license. See http://adampritchard.mit-license.org/ or see [the `LICENSE` file](https://github.com/worldbank/ietoolkit/blob/master/LICENSE) for details.

### **Main Contact**
Luiza Cardoso de Andrade ([dimeanalytics@worldbank.org](mailto:dimeanalytics@worldbank.org))

### **Authors**
Kristoffer Bjärkefur, Luiza Cardoso de Andrade, Benjamin Daniels

### **About us**
[DIME](https://www.worldbank.org/en/research/dime) is the World Bank's impact evaluation department. Part of DIME’s mission is to intensify the production of and access to public goods that improve the quantity and quality of global development research, while lowering the costs of doing IE for the entire research community. This Library is developed and maintained by [DIME Analytics](https://www.worldbank.org/en/research/dime/data-and-analytics). DIME Analytics supports quality research processes across the DIME portfolio, offers public trainings, and develops tools for the global community of development researchers.

Other DIME Analytics public goods are:
- [Development Research in Practice:](https://worldbank.github.io/dime-data-handbook/) the DIME Analytics Data Handbook
- [DIME Wiki:](https://dimewiki.worldbank.org/wiki/Main_Page) a one-stop-shop for impact evaluation resources
- [ietoolkit:](https://github.com/worldbank/ietoolkit) Stata package for impact evaluations
- [iefieldkit:](https://github.com/worldbank/iefieldkit) Stata package for primary data collection
- [Stata Visual Library](https://github.com/worldbank/stata-visual-library)
- [R Econ Visual Library](https://github.com/worldbank/r-econ-visual-library)
- [DIME Research Standards:](https://github.com/worldbank/dime-standards/blob/master/dime-research-standards/) DIME's commitments to best practices
