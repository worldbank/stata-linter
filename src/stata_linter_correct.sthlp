{smcl}
{* 7 Dec 2020}{...}
{hline}
help for {hi:stata_linter_correct}
{hline}

{title:Title}

{phang2}{cmdab:stata_linter_correct} {hline 2} corrects bad coding practices in a do file and outputs a new do file

{title:Syntax}

{phang2}
{cmdab:stata_linter_correct}, {cmdab:input(}{it:{help filename}}{cmd:)} {cmdab:output(}{it:{help filename}}{cmd:)}
[
{it:options}
]

{marker opts}{...}
{synoptset 23}{...}
{synopthdr:options}
{synoptline}
{pstd}{it:    {ul:{hi:Required options:}}}{p_end}

{synopt :{cmdab:input(}{it:{help filename}}{cmd:)}}do file in which the command is executed on{p_end}
{synopt :{cmdab:output(}{it:{help filename}}{cmd:)}}new do file generated as a result of this command, in which bad coding practices are corrected{p_end}

{pstd}{it:    {ul:{hi:Optional options:}}}{p_end}

{marker columnoptions}{...}
{synopt :{cmdab:indent(}{it:integer}{cmd:)}}The number of whitespaces used for indentation (default: 4){p_end}
{synopt :{cmdab:automatic}}Correct all bad coding practices without asking if you want each bad coding practice to be corrected or not{p_end}
{synopt :{cmdab:replace}}Replace the existing {it:output} file{p_end}
{synopt :{cmdab:input_replace_force}}Allow the output file name to be the same as the name of the input file{p_end}
{synopt :{cmdab:tab_space(}{it:integer}{cmd:)}}The number of whitespaces used instead of hard tabs (default: 4){p_end}

{synoptline}

{title:Style rules}

{pstd}{hi:Replace delimit to three forward slashes (///)}
{break}
It is recommended to avoid to use {cmdab:delimit} command.
This command removes the delimit command and add three forward slashes {cmdab:///} to appropriate places.

{pstd}{hi:Replace hard tabs to soft tabs (= whitespaces)}
{break}
It is recommended to avoid to use hard tabs.
This command replaces them with soft tabs (= whitespaces, usually 2 or 4 whitespaces are used).

{pstd}{hi:Use indents in brackets after for and while loops or if/else conditions}
{break}
For better readability, it is recommended to add indentations within brackets of for-loops, while-loops, and if/else statements.
If there are no proper indentations, this command adds whitespaces.

{pstd}{hi:Break too long lines}
{break}
Too long lines should be avoided.
When a line is too long, this command breaks the line into multiple lines using line breaks ({cmdab:///}).

{pstd}{hi:Add a whitespace before a curly bracket}
{break}
This command adds a whitespace before a curly bracket of for-loops, while-loops, or if/else statements.

{pstd}{hi:Remove blank lines before closing curly brackets}
{break}
This command removes blank lines before closing curly brackets of for-loops, while-loops, or if/else statements.

{pstd}{hi:Remove duplicated blank lines}
{break}
This command removes duplicated blank lines.





