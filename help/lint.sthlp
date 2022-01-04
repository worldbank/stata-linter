{smcl}
{* 9 Jun 2021}{...}
{hline}
help for {hi:lint}
{hline}

{title:Title}

{p 4 4 2}
{cmdab:lint} {hline 2} detects and corrects bad coding practices in do files

{p 4 4 2}
For this command to run, you will need Stata >=16, python, and a python package, {browse "https://pandas.pydata.org/":pandas}, has to be installed. On how to install python, refer to {browse "https://blog.stata.com/2020/08/18/stata-python-integration-part-1-setting-up-stata-to-use-python/":this page}.
On how to install python packages, refer to {browse "https://blog.stata.com/2020/09/01/stata-python-integration-part-3-how-to-install-python-packages/":this page}.

{title:Basic syntax}

{p 4 4 2}
{cmdab:lint} "input_file" using "output_file", {it:options}

{marker opts}{...}
{synoptset 25}{...}
{synopthdr:options}
{synoptline}
{pstd}{it:    {ul:{hi:Optional options:}}}{p_end}

{marker columnoptions}{...}
{synopt :{cmdab:verbose}}Shows line-by-line results{p_end}
{synopt :{cmdab:nosummary}}Excludes summary results (number of bad practices){p_end}
{synopt :{cmdab:indent(}{it:integer}{cmd:)}}The number of whitespaces used for indentation (default: 4){p_end}
{synopt :{cmdab:tab_space(}{it:integer}{cmd:)}}The number of whitespaces used instead of hard tabs (default: same as {it:indent}){p_end}
{synopt :{cmdab:linemax(}{it:integer}{cmd:)}}Maximum number of characters in a line (default: 80){p_end}
{synopt :{cmdab:excel(}{it:{help filename}}{cmd:)}}Make an excel file of line-by-line results{p_end}
{synopt :{cmdab:inprep}}Allow the output file name to be the same as the name of the input file{p_end}
{synopt :{cmdab:automatic}}Correct all bad coding practices without asking if you want each bad coding practice to be corrected or not{p_end}
{synopt :{cmdab:replace}}Replace the existing {it:output} file{p_end}

{synoptline}

{p 4 4 2} The lint command can be broken into two functionalities:

      1. {it:detection} which refers to identifying bad coding practices in one or multiple Stata do-files;
      2. {it:correction} which refers to correcting bad coding practices in a Stata do-file.

{title:Style rules}

{pstd}{hi:Use soft tabs (i.e, whitespaces), not hard tabs}
{break}
Use white spaces (usually 2 or 4 whitespaces are used) instead of hard tabs. You can change this option in the do-file editor preferences.

{pstd}{hi:Avoid to use abstract index names}
{break}
In for loops, index names should describe what the code is looping over.
Hence, for example, avoid the code like this:

{pmore}{input:foreach i of var cassava maize wheat {  }}

{pstd}Instead, when looping commands should name that index descriptively:

{pmore}{input:foreach crop of var cassava maize wheat {  }}

{pstd}{hi:Use proper indentations}
{break}
After declaring for loop statement or if-else statement, add indentation with whitespaces (usually 2 or 4 whitespaces).

{pstd}{hi:Use indentations after declaring newline symbols (///)}
{break}
After a new line statement (///), add indentation (usually 2 or 4 whitespaces).

{pstd}{hi:Use "{cmdab:!missing}" function for conditions of missing values}
{break}
For clarity, use {cmdab:!missing(var)} instead of {cmdab:var < .} or {cmdab:var != .}

{pstd}{hi:Do not use "{cmdab:delimit}", instead use "///" for line breaks}
{break}
More information about the use of line breaks {browse "https://worldbank.github.io/dime-data-handbook/coding.html#line-breaks":here}.

{pstd}{hi:Do not use cd to change current folder}
{break}
Use absolute and dynamic file paths. More about this {browse "https://worldbank.github.io/dime-data-handbook/coding.html#writing-file-paths":here}.

{pstd}{hi:Use line breaks for too long lines}
{break}
For lines that are too long, use {cmdab:///} for line breaks and divide them into multiple lines.
It is recommended to restrict the number of characters in a line under 80.
Whereas sometimes this is difficult since, for example, Stata does not allow line breaks within double quotes, try to follow this rule when possible.

{pstd}{hi:Add whitespaces around math symbols such as {cmdab:+, =, <, >,} etc.}
{break}
For better readability, add whitespaces around math symbols.
For example, do {cmdab:gen a = b + c if d == e} instead of {cmdab:gen a=b+c if d==e}.

{pstd}{hi:Specify the condition in the if statement}
{break}
Always explicitly specify the condition in the if statement.
For example, declare {cmdab:if var == 1} instead of {cmdab:if var}.

{pstd}{hi:Use curly brackets for global macros}
{break}
Always use {cmdab:${ }} for global macros.
For instance, use {cmdab:${global}} instead of {cmdab:$global}.

{title:Check suggestions}

{pstd}{hi:Check if missing values are properly taken into account}
{break}
Note that {cmdab:a != 0} includes cases where {cmdab:a} is missing.

{pstd}{hi:Check if backslashes are not used in file paths}
{break}
Check if backslashes ({cmdab:\}) are not used in file paths.
If you are using them, then replace them with forward slashes ({cmdab:/}).

{pstd}{hi:Check if tildes (~) are not used for negations}
{break}
If you are using tildes ({cmdab:~}) are used for negations, replace them with bangs ({cmdab:!}).

{marker exa}
{title:Examples}

{p 4 4 2}
The following examples are intended to illustrate the basic usage of
{cmd:lint}. Additional examples can be found at
{browse "https://github.com/worldbank/stata-linter/wiki/Lint"}.

{pstd}{hi:1. Detecting bad coding practices}

{p 4 4 2} The basic usage is to point to a do-file that requires revision as follows:

        {com}. lint "test/bad.do"

{p 4 4 2} For the detection feature you can use all the options but {it:automatic, inprep, and replace}.

        Options:

        1. Show in which lines there are bad coding practices
        {com}. lint "test/bad.do", verbose

        2. Remove the summary of bad practices
        {com}. lint "test/bad.do", nosummary

        3. Specify the number of whitespaces (default: 4):
        {com}. lint "test/bad.do", indent(2)

        4. Specify the maximum number of characters in a line (default: 80):
        {com}. lint "test/bad.do", linemax(100)

        5. Specify the number of whitespaces used instead of hard tabs (default: 4):
        {com}. lint "test/bad.do", tab_space(100)

        6. Exports to excel the results of the line by line analysis
        {com}. lint "test/bad.do", excel("test_dir/detect_output.xlsx")

        7. You can also use this command to test all the do-files that are in a folder:
        {com}. lint "test"

{pstd}{hi:2. Correcting bad coding practices}

{p 4 4 2} In the case of correcting a do file, the basic usage is to point to a do-file
that will be corrected and assign a new name to said do-file. If you do not include any
options, Stata will ask you confirm if you want a specific bad practice to be corrected:

        1. Basic usage (Stata will prompt you with questions):
        {com}. lint "test/bad.do" using "test/bad_corrected.do"

        2. Automatic (Stata will correct the file automatically):
        {com}. lint "test/bad.do" using "test/bad_corrected.do", automatic

        3. Have the same name for the output file:
        {com}. lint "test/bad.do" using "test/bad.do", automatic inprep

        4. Replace the output file
        {com}. lint "test/bad.do" using "test/bad_corrected.do", automatic replace

{title:Authors}

{phang}This command is developed by DIME Analytics at DECIE, The World Bank's unit for Development Impact Evaluations.

{phang}Please send bug-reports, suggestions and requests for clarifications
		 writing "stata linter" in the subject line to:{break}
		 dimeanalytics@worldbank.org

{phang}You can also see the code, make comments to the code, see the version
		 history of the code, and submit additions or edits to the code through {browse "https://github.com/worldbank/stata-linter":the GitHub repository of this package}.{p_end}
