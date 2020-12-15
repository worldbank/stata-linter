global src_dir "/Users/mizuhirosuzuki/Documents/GitHub/stata-linter/src"
global test_dir "/Users/mizuhirosuzuki/Documents/GitHub/stata-linter/test"

cd "${src_dir}"

stata_linter_correct_all, input("${test_dir}") automatic indent(2) replace
stata_linter_detect_all, Input("${test_dir}") Indent(2) suppress summary excel("${test_dir}/detect_output.xlsx") linemax(140)



