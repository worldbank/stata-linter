{smcl}
{* 7 Dec 2020}{...}
{hline}
help for {hi:stata_linter_detect}
{hline}

{title:Title}

{phang2}{cmdab:stata_linter_detect} {hline 2} detects bad coding practices in a do file

{title:Syntax}

{phang2}
{cmdab:stata_linter_detect}, {cmdab:input(}{it:{help filename}}{cmd:)}
[
{it:options}
]

{marker opts}{...}
{synoptset 23}{...}
{synopthdr:options}
{synoptline}
{pstd}{it:    {ul:{hi:Required options:}}}{p_end}

{synopt :{cmdab:input(}{it:{help filename}}{cmd:)}}do file in which the command is executed on

{pstd}{it:    {ul:{hi:Optional options:}}}{p_end}

{marker columnoptions}{...}
{synopt :{cmdab:indent(}{it:integer}{cmd:)}}The number of whitespaces used for indentation (default: 4){p_end}
{synopt :{cmdab:nocheck}}Do not show suggestions to check and only show style problems{p_end}
{synopt :{cmdab:suppress}}Do not show line-by-line results{p_end}
{synopt :{cmdab:summary}}Show summary results (number of bad practices){p_end}
{synopt :{cmdab:excel(}{it:{help filename}}{cmd:)}}Make an excel file of line-by-line results{p_end}
{synopt :{cmdab:linemax(}{it:integer}{cmd:)}}Maximum number of characters in a line (default: 80){p_end}
{synopt :{cmdab:tab_space(}{it:integer}{cmd:)}}The number of whitespaces used instead of hard tabs (default: same as {it:indent}){p_end}

{synoptline}

{title:Style rules}

{pstd}{hi:Use soft tabs (= whitespaces), not hard tabs}
{break}
Use white spaces (usually 2 or 4 whitespaces are used) instead of hard tabs.

{pstd}{hi:Avoid to use abstract index names}
{break}
In for loops, index names should describe what the code is looping over.
Hence, for example, avoid the code like this:

{pmore}{input:foreach i of var cassava maize wheat {  }}

{pstd}Instead, write like this:

{pmore}{input:foreach crop of var cassava maize wheat {  }}

{pstd}{hi:Use proper indentations}
{break}
After declaring for loop statement or if-else statement, add indentation with whitespaces (usually 2 or 4 whitespaces are used).

{pstd}{hi:Use indentations after declaring newline symbols (///)}
{break}
After new line statement ({cmdab:///}), add indentation (usually 2 or 4 whitespaces are used).

{pstd}{hi:Use "{cmdab:!missing}" function for conditions of missing values}
{break}
For clarity, use {cmdab:!missing(var)} instead of {cmdab:var < .} or {cmdab:var != .}

{pstd}{hi:Do not use "{cmdab:delimit}" command but use "///" for line breaks}
{break}
Avoid to use {cmdab:delimit}. For line breaks, use {cmdab:///} instead.

{pstd}{hi:Do not use cd command to change current folder}
{break}
Avoid to use {cmdab:cd} but use absolute and dynamic file paths.

{pstd}{hi:Use line breaks for too long lines}
{break}
For lines that are too long, use {cmdab:///} for line breaks and divide them into multiple lines.
It is recommended to restrict the number of characters in a line under 80.
Whereas sometimes this is difficult since, for example, Stata does not allow line breaks within double quotes, try to follow this rule when possible.

{pstd}{hi:Add whitespaces around math symbols such as +, =, <, >, etc.}
{break}
For better readability, add whitespaces around math symbols.
For example, do {cmdab:gen a = b + c if d == e} instead of {cmdab:gen a=b+c if d==e}.

{pstd}{hi:Specify the condition in the if statement}
{break}
Always explicitly specify the condition in the if statement.
For example, declare {cmdab:if var == 1} instead of {cmdab:if var}.

{pstd}{hi:Use parentheses for global macros}
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





