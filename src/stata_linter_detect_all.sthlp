{smcl}
{* 7 Dec 2020}{...}
{hline}
help for {hi:stata_linter_detect_all}
{hline}

{title:Title}

{phang2}{cmdab:stata_linter_detect_all} {hline 2} applies {cmdab:stata_linter_detect} command to all files in a folder

{title:Syntax}

{phang2}
{cmdab:stata_linter_detect_all},
[
{it:options}
]

{marker opts}{...}
{synoptset 23}{...}
{synopthdr:options}
{synoptline}

{pstd}{it:    {ul:{hi:Optional options:}}}{p_end}

{marker columnoptions}{...}
{synopt :{cmdab:input(}{it:{help filename}}{cmd:)}}Specify which folder the command works on (default: current folder){p_end}
{synopt :{cmdab:indent(}{it:integer}{cmd:)}}The number of whitespaces used for indentation (default: 4){p_end}
{synopt :{cmdab:nocheck}}Do not show suggestions to check and only show style problems{p_end}
{synopt :{cmdab:suppress}}Do not show line-by-line results{p_end}
{synopt :{cmdab:summary}}Show summary results (number of bad practices){p_end}
{synopt :{cmdab:excel(}{it:{help filename}}{cmd:)}}Make an excel file of line-by-line results (the results of each file are stored in different sheets, where file names are used for sheet names){p_end}
{synopt :{cmdab:linemax(}{it:integer}{cmd:)}}Maximum number of characters in a line (default: 80){p_end}
{synopt :{cmdab:tab_space(}{it:integer}{cmd:)}}The number of whitespaces used instead of hard tabs (default: 4){p_end}

{synoptline}





