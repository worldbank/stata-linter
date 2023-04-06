{smcl}
{* 06 Apr 2023}{...}
{hline}
help for {hi:lint}
{hline}

{title:Title}

{p 4 4 2}

{cmdab:lint} {hline 2} detects and corrects bad coding practices in Stata do-files following the {browse "https://worldbank.github.io/dime-data-handbook/coding.html#the-dime-analytics-stata-style-guide":DIME Analytics Stata Style Guide}.

{p 4 4 2}
For this command to run, you will need Stata version 16 or greater, Python,
  and the Python package {browse "https://pandas.pydata.org/":Pandas} installed. {break}
	To install Python and integrate it with Stata, refer to {browse "https://blog.stata.com/2020/08/18/stata-python-integration-part-1-setting-up-stata-to-use-python/":this page}. {break}
  To install Python packages, refer to {browse "https://blog.stata.com/2020/09/01/stata-python-integration-part-3-how-to-install-python-packages/":this page}.

{title:Basic syntax}

{p 4 6 6}
{cmdab:lint} "{it:input_file}" [using "{it:output_file}"] , [{it:options}]
{p_end}
{break}
{p 4 4 2} The lint command can be broken into two functionalities:
      {break}1. {hi:Detection} identifies bad coding practices in a Stata do-files
      {break}2. {hi:Correction} corrects bad coding practices in a Stata do-file.
{p_end}
{break}
{p 4 4 6} If an {it:output_file} is specified with {opt using},
  then the linter will apply the {hi:Correction} functionality and will write
  a new file with corrections.{break}
	If not, the command will only apply the {hi:Detection} functionality, returning
  a report of suggested corrections	and potential issues of the do-file
  in Stata's Results window.{break}
  Users should note that not all the bad practices identified in {hi:Detection}
  can be amended by {hi:Correction}.{p_end}

{marker opts}{...}
{synoptset 25}{...}
{synopthdr:Option}
{synoptline}

{synopt :{cmdab:v:erbose}}Report bad practices and issues found on each line of the do-file.{p_end}
{synopt :{cmdab:nosum:mary}}Suppress summary table of bad practices and potential issues.{p_end}
{synopt :{cmdab:i:ndent(}{it:integer}{cmd:)}}Number of whitespaces used when checking indentation coding practices (default: 4).{p_end}
{synopt :{cmdab:s:pace(}{it:integer}{cmd:)}}Number of whitespaces used instead of hard tabs when checking indentation practices (default: same as {it:indent}).{p_end}
{synopt :{cmdab:l:inemax(}{it:integer}{cmd:)}}Maximum number of characters in a line when checking line extension practices (default: 80).{p_end}
{synopt :{cmdab:e:xcel(}{it:{help filename}}{cmd:)}}Save an Excel file of line-by-line results.{p_end}
{synopt :{cmdab:force}}Allow the output file name to be the same as the name of the input file;
  overwriting the original do-file. {hi:The use of this option is not recommended} because it is
  slightly possible that the corrected do-file created by the command will break something
  in your code and you should always keep a backup of it.{p_end}
{synopt :{cmdab:auto:matic}}Correct all bad coding practices without asking
  if you want each bad coding practice to be corrected or not.
	By default, the command will ask the user about each correction interactively
	after producing the summary report.{p_end}
{synopt :{cmdab:replace}}Overwrite any existing {it:output} file.{p_end}

{synoptline}


{title:{it:Detect} functionality: Bad style practices and potential issues detected}

{pstd}{hi:Use whitespaces instead of hard tabs}
{break}
Use whitespaces (usually 2 or 4) instead of hard tabs.

{pstd}{hi:Avoid abstract index names}
{break}
In for-loop statements, index names should describe what the code is looping over.
For example, avoid writing code like this:

{pmore}{input:foreach i of varlist cassava maize wheat {  }}

{pstd}Instead, looping commands should name the index local descriptively:

{pmore}{input:foreach crop of varlist cassava maize wheat {  }}

{pstd}{hi:Use proper indentations}
{break}
After declaring for-loop statements or if-else statements, add indentation with
whitespaces (usually 2 or 4) in the lines inside the loop.

{pstd}{hi:Use indentations after declaring newline symbols (///)}
{break}
After a new line statement (///), add indentation (usually 2 or 4 whitespaces).

{pstd}{hi:Use the "{cmdab:!missing()}" function for conditions with missing values}
{break}
For clarity, use {cmdab:!missing(var)} instead of {cmdab:var < .} or {cmdab:var != .}

{pstd}{hi:Add whitespaces around math symbols ({cmdab:+, =, <, >})}
{break}
For better readability, add whitespaces around math symbols.
For example, do {cmdab:gen a = b + c if d == e} instead of {cmdab:gen a=b+c if d==e}.

{pstd}{hi:Specify the condition in an "if" statement}
{break}
Always explicitly specify the condition in the if statement.
For example, declare {cmdab:if var == 1} instead of just using {cmdab:if var}.

{pstd}{hi:Do not use "{cmdab:#delimit}", instead use "///" for line breaks}
{break}
More information about the use of line breaks {browse "https://worldbank.github.io/dime-data-handbook/coding.html#line-breaks":here}.

{pstd}{hi:Do not use cd to change current folder}
{break}
Use absolute and dynamic file paths. More about this {browse "https://worldbank.github.io/dime-data-handbook/coding.html#writing-file-paths":here}.

{pstd}{hi:Use line breaks in long lines}
{break}
For lines that are too long, use {cmdab:///} to divide them into multiple lines.
It is recommended to restrict the number of characters in a line to 80 or less.

{pstd}{hi:Use curly brackets for global macros}
{break}
Always use {cmdab:${ }} for global macros.
For exmaple, use {cmdab:${global_name}} instead of {cmdab:$global_name}.

{pstd}{hi:Include missing values in condition expressions}
{break}
Condition expressions like {cmdab:var != 0} or {cmdab:var > 0} are evaluated to true for missing values.
Make sure to explicitly take missing values into account by using {cmdab:missing(var)} in expressions.

{pstd}{hi:Check if backslashes are not used in file paths}
{break}
Check if backslashes ({cmdab:\}) are not used in file paths.
If you are using them, then replace them with forward slashes ({cmdab:/}).
Users should note that the linter might not distinguish perfectly which uses of
a backslash are file paths. In general, this flag will come up every time a
backslash is used in the same line as a local, glocal, or the {it:cd} command.

{pstd}{hi:Check if tildes (~) are not used for negations}
{break}
If you are using tildes ({cmdab:~}) are used for negations, replace them with bangs ({cmdab:!}).

{title:{it:Correct} functionality: coding practices to be corrected}

{p 4 4 2}
Users should note that the {it:Correct} feature does not correct all the bad practices detected.
It only corrects the following:

{pstd}- Replaces the use of {cmdab:#delimit} with three forward slashes ({cmdab:///}) in each line affected by {cmdab:#delimit}

{pstd}- Replaces hard tabs with soft spaces (4 by default). The amount of spaces can be set with the {cmdab:tab_space()} option

{pstd}- Indents lines inside curly brackets with 4 spaces by default. The amount of spaces can be set with the {cmdab:indent()} option

{pstd}- Breaks long lines into multiple lines. Long lines are considered to have more than 80 characters by default,
but this setting can be changed with the option {cmdab:linemax()}.
Note that lines can only be split in whitespaces that are not inside
parentheses, curly brackets, or double quotes. If a line does not have any
whitespaces, the linter will not be able to break a long line.

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
The following examples illustrate the basic usage of {cmd:lint}.
Additional examples can be found at
{browse "https://github.com/worldbank/stata-linter/"}.

{pstd}{hi:1. Detecting bad coding practices}

{p 4 4 2} The basic usage is to point to a do-file that requires revision as follows:

        {com}. lint "test/bad.do"

{p 4 4 2} For the detection feature you can use all the options but {it:automatic}, {it:force}, and {it:replace}, which are part of the correction functionality.

        Options:

        1. Show bad coding practices line-by-line
        {com}. lint "test/bad.do", verbose

        2. Remove the summary of bad practices
        {com}. lint "test/bad.do", nosummary

        3. Specify the number of whitespaces used for detecting indentation practices (default: 4):
        {com}. lint "test/bad.do", indent(2)

        4. Specify the number of whitespaces used instead of hard tabs for detecting indentation practices (default: same value used in {it:indent}):
        {com}. lint "test/bad.do", tab_space(6)

        5. Specify the maximum number of characters in a line allowed when detecting line extension (default: 80):
        {com}. lint "test/bad.do", linemax(100)

        6. Export to Excel the results of the line by line analysis
        {com}. lint "test/bad.do", excel("test_dir/detect_output.xlsx")

        7. You can also use this command to test all the do-files in a folder:
        {com}. lint "test/"

{pstd}{hi:2. Correcting bad coding practices}

{p 4 4 2} The basic usage of the correction feature requires to specify the input do-file
and the output do-file that will have the corrections.
If you do not include any options, the linter will ask you confirm if you want a specific bad practice to be corrected
for each bad practice detected:

        1. Basic correction use (the linter will ask what to correct):
        {com}. lint "test/bad.do" using "test/bad_corrected.do"

        2. Automatic use (Stata will correct the file automatically):
        {com}. lint "test/bad.do" using "test/bad_corrected.do", automatic

        3. Use the same name for the output file (note that this will overwrite the input file, this is not recommended):
        {com}. lint "test/bad.do" using "test/bad.do", automatic force

        4. Replace the output file if it already exists
        {com}. lint "test/bad.do" using "test/bad_corrected.do", automatic replace

{title:Acknowledgements}

{phang}This work is a product of the initial idea and work of Mizuhiro Suzuki.
  Rony Rodriguez Ramirez, Luiza Cardoso de Andrade and Luis Eduardo San Martin also contributed to this command,
  and Kristoffer Bjärkefur and Benjamin B. Daniels provided comments and code reviews.

{title:Authors}

{phang}This command was developed by DIME Analytics at DIME, The World Bank's department for Development Impact Evaluations.

{phang}Please send bug reports, suggestions, and requests for clarifications
  writing "Stata linter" in the subject line to:{break}
  dimeanalytics@worldbank.org

{phang}You can also see the code, make comments to the code, see the version
		 history of the code, and submit additions or edits to the code through {browse "https://github.com/worldbank/stata-linter":the GitHub repository of this package}.{p_end}
