global src_dir "/Users/mizuhirosuzuki/Documents/GitHub/stata-linter/src"
global test_dir "/Users/mizuhirosuzuki/Documents/GitHub/stata-linter/test"

cd "${src_dir}"

*stata_linter_correct_all, input("${test_dir}") automatic indent(2) replace
*stata_linter_detect_all, input("${test_dir}") indent(2) suppress summary excel("${test_dir}/detect_output.xlsx") linemax(140)

stata_linter_detect_all, input("/Users/mizuhirosuzuki/Documents/GitHub/Stata2R/Library/Banerjee2015_replication") indent(2) suppress summary excel("${test_dir}/detect_output.xlsx") linemax(140)
stata_linter_correct_all, input("/Users/mizuhirosuzuki/Documents/GitHub/Stata2R/Library/Banerjee2015_replication") automatic indent(2) replace

exit
stata_linter_correct, input("/Users/mizuhirosuzuki/Documents/GitHub/brazil_audit/Codes/Stata/data_clean/data_clean_br.do") output("${test_dir}/aa.do") automatic indent(2) replace

stata_linter_detect, input("/Users/mizuhirosuzuki/Documents/GitHub/Stata2R/Library/Kaboski2012_replication/AEJApp2009-0115_data/documentation/Tables9and10.do") indent(2) suppress summary linemax(140)

cd "/Users/mizuhirosuzuki/Documents/GitHub/Stata2R/Library/Banerjee2015_replication"
do 2013-0533_do_figures.do
do 2013-0533_do_figures_correct.do


global src_dir "/Users/mizuhirosuzuki/Documents/GitHub/stata-linter/src"
global test_dir "/Users/mizuhirosuzuki/Documents/GitHub/stata-linter/test"

cd "${src_dir}"

run stata_linter_detect.ado

stata_linter_detect, input("${test_dir}/bad.do") indent(2) suppress


