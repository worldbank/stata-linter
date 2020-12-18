
  * --------------- *
  * Global settings *
  * --------------- *

  * Set the global to folder where .ado files are stored
  global src_dir "/Users/mizuhirosuzuki/Documents/GitHub/stata-linter/src"
  * Set the global to folder where test files are stored
  global test_dir "/Users/mizuhirosuzuki/Documents/GitHub/stata-linter/test"
  
  * To run the command, you need to change your current directory to src_dir
  cd "${src_dir}"

  * -------------------- *
  * Run example commands *
  * -------------------- *

  stata_linter_correct, input("../test/bad.do") output("../test/bad_correct.do")



