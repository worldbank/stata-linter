global src_dir "/Users/mizuhirosuzuki/Documents/GitHub/stata-linter/src"
global test_dir "/Users/mizuhirosuzuki/Documents/GitHub/stata-linter/test"

cd "${src_dir}"

stata_linter_correct_all, input("${test_dir}") 
