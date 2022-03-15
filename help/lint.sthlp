{smcl}
{* 9 Jun 2021}{...}
{hline}
help for {hi:lint}
{hline}

{title:Title}

{p 4 4 2}
{cmdab:lint} {hline 2} detects and corrects bad coding practices in do-files

{p 4 4 2}
For this command to run, you will need Stata >=16, Python, and the Python packages {cmdab:pandas}, {cmdab:openpyxl}, and {cmdab:sfi}.
Refer to {browse "https://blog.stata.com/2020/08/18/stata-python-integration-part-1-setting-up-stata-to-use-python/":this page} for instructions on how to install Python.
Refer to {browse "https://blog.stata.com/2020/09/01/stata-python-integration-part-3-how-to-install-python-packages/":this page} for instructions on how to install Python packages.

{title:Basic syntax}

{p 4 4 2}
{cmdab:lint} {it:input_file} [using {it:output_file}], {it:options}

{marker opts}{...}
{synoptset 25}{...}
{synopthdr:options}
{synoptline}
{pstd}{it:    {ul:{hi:Options:}}}{p_end}

{marker columnoptions}{...}
{synopt :{cmdab:verbose}}Shows line-by-line results{p_end}
{synopt :{cmdab:nosummary}}Excludes summary results (number of bad practices){p_end}
{synopt :{cmdab:indent(}{it:integer}{cmd:)}}Defines the number of whitespaces used for indentation checks (default: 4){p_end}
{synopt :{cmdab:tab_space(}{it:integer}{cmd:)}}Defines the number of whitespaces used to replace hard tabs (default: 4){p_end}
{synopt :{cmdab:linemax(}{it:integer}{cmd:)}}Defines the maximum number of characters of a line (default: 80){p_end}
{synopt :{cmdab:excel(}{it:{help filename}}{cmd:)}}Creates an excel file with line-by-line results{p_end}
{synopt :{cmdab:inprep}}Allows the output file name to be the same as the name of the input file. Can only be used when an output file is specified{p_end}
{synopt :{cmdab:automatic}}Corrects all bad coding practices without asking if you want each bad coding practice to be corrected or not. Can only be used when an output file is specified{p_end}
{synopt :{cmdab:replace}}Replaces the existing {it:output} file. Can only be used when an output file is specified{p_end}

{synoptline}

{p 4 4 2} The lint command can be broken into two functionalities:

      1. {it:detection} identifies bad coding practices in one or multiple Stata do-files
      2. {it:correction} corrects bad coding practices in a Stata do-file. This feature is activated when an output file is specified with {it:using}

{title:Coding practices to be detected}

{pstd}{hi:Use soft tabs (i.e, whitespaces), not hard tabs}
{break}
Use white spaces (usually 2 or 4 whitespaces are used) instead of hard tabs. You can change this option in the do-file editor preferences.

{pstd}{hi:Avoid to use abstract index names}
{break}
In for loops, index names should describe what the code is looping over.
Hence, for example, avoid the code like this:

{pmore}{input:foreach i of var cassava maize wheat {  }}

{pstd}Instead, looping commands should name the index local descriptively:

{pmore}{input:foreach crop of var cassava maize wheat {  }}

{pstd}{hi:Use proper indentations}
{break}
After declaring for loop statement or if-else statement, add indentation with whitespaces (usually 2 or 4 whitespaces).

{pstd}{hi:Use indentations after declaring newline symbols (///)}
{break}
After a new line statement (///), add indentation (usually 2 or 4 whitespaces).

{pstd}{hi:Use "{cmdab:!missing()}" function for conditions of missing values}
{break}
For clarity, use {cmdab:!missing(var)} instead of {cmdab:var < .} or {cmdab:var != .}

{pstd}{hi:Add whitespaces around math symbols ({cmdab:+, =, <, >})}
{break}
For better readability, add whitespaces around math symbols.
For example, do {cmdab:gen a = b + c if d == e} instead of {cmdab:gen a=b+c if d==e}.

{pstd}{hi:Specify the condition in the if statement}
{break}
Always explicitly specify the condition in the if statement.
For example, declare {cmdab:if var == 1} instead of {cmdab:if var}.

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

{pstd}{hi:Use curly brackets for global macros}
{break}
Always use {cmdab:${ }} for global macros.
For instance, use {cmdab:${global}} instead of {cmdab:$global}.

{pstd}{hi:Include missing values in condition expressions}
Condition expressions like {cmdab:var != 0} or {cmdab:var > 0} are evaluated to true for missing values.
Make sure to explicitly take missing values into account by using {cmdab:missing()} in expressions.

{pstd}{hi:Check if backslashes are not used in file paths}
{break}
Check if backslashes ({cmdab:\}) are not used in file paths.
If you are using them, then replace them with forward slashes ({cmdab:/}).

{pstd}{hi:Check if tildes (~) are not used for negations}
{break}
If you are using tildes ({cmdab:~}) are used for negations, replace them with bangs ({cmdab:!}).

{title:Coding practices to corrected}

{p 4 4 2}
The correction feature does not correct all the bad practices detected.
It only corrects the following:

{pstd}- Replaces the use of {cmdab:delimit} with three forward slashes ({cmdab:///}) in each line affected by {cmdab:delimit}

{pstd}- Replaces hard tabs with soft spaces (4 by default). The amount of spaces can be set with the {cmdab:tab_space()} option

{pstd}- Indents lines inside curly brackets with 4 spaces by default. The amount of spaces can be set with the {cmdab:indent()} option

{pstd}- Breaks long lines into two lines. Long lines are considered to have more than 80 characters by default, but this setting can be changed with the option {cmdab:linemax()}

{pstd}- Adds a whitespace before opening curly brackets, except for globals

{pstd}- Removes redundant blank lines after closing curly brackets

{pstd}- Removes duplicated blank lines

{p 4 4 2}
If the option {cmdab:automatic} is omitted, Stata will prompt the user to confirm that
they want to correct each of these bad practices only in case they are detected.
If none of these are detected, it will show a message saying that none of the
bad practices it can correct were detected.

{marker exa}
{title:Examples}

{p 4 4 2}
The following examples are intended to illustrate the basic usage of {cmd:lint}.
Additional examples can be found at
{browse "https://github.com/worldbank/stata-linter/wiki/Lint"}.

{pstd}{hi:1. Detecting bad coding practices}

{p 4 4 2} The basic usage is to point to a do-file that requires revision as follows:

        {com}. lint "test/bad.do"

{p 4 4 2} For the detection feature you can use all the options but {it:automatic, inprep, and replace}.

        Options:

        1. Show which lines have bad coding practices
        {com}. lint "test/bad.do", verbose

        2. Remove the summary of bad practices
        {com}. lint "test/bad.do", nosummary

        3. Specify the number of whitespaces (default: 4):
        {com}. lint "test/bad.do", indent(2)

        4. Specify the maximum number of characters in a line (default: 80):
        {com}. lint "test/bad.do", linemax(100)

        5. Specify the number of whitespaces used instead of hard tabs (default: 4):
        {com}. lint "test/bad.do", tab_space(6)

        6. Export to Excel the results of the line by line analysis
        {com}. lint "test/bad.do", excel("test_dir/detect_output.xlsx")

        7. You can also use this command to test all the do-files that are in a folder:
        {com}. lint "test"

{pstd}{hi:2. Correcting bad coding practices}

{p 4 4 2} The basic usage of the correction feature requires to specify the input do-file
and the output do-file that will have the corrections.
If you do not include any options, Stata will ask you confirm if you want a specific bad practice to be corrected
for each bad practice detected:

        1. Basic usage (Stata will prompt you with questions):
        {com}. lint "test/bad.do" using "test/bad_corrected.do"

        2. Automatic (Stata will correct the file automatically):
        {com}. lint "test/bad.do" using "test/bad_corrected.do", automatic

        3. Use the same name for the output file (this will overwrite the input file):
        {com}. lint "test/bad.do" using "test/bad.do", automatic inprep

        4. Replace the output file if it already exists
        {com}. lint "test/bad.do" using "test/bad_corrected.do", automatic replace

{title:Authors}

{phang}This command is developed by DIME Analytics at DIME, The World Bank's department for Development Impact Evaluations.

{phang}Please send bug-reports, suggestions and requests for clarifications
		 writing "stata linter" in the subject line to:{break}
		 dimeanalytics@worldbank.org

{phang}You can also see the code, make comments to the code, see the version
		 history of the code, and submit additions or edits to the code through {browse "https://github.com/worldbank/stata-linter":the GitHub repository of this package}.{p_end}
