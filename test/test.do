
*stata_linter_correct, input(bad.do) output(better.do) automatic replace indent(2)
*
*exit
*
*stata_linter_correct_all, input(.) indent(2) automatic replace

stata_linter_detect_all, input(.) indent(2) linemax(140) summary suppress
stata_linter_detect_all, input(.) indent(2) linemax(140) suppress summary excel(detect_output.xlsx)

exit

*di "------------------------------------------"
*
*stata_linter_detect, input(bad_detect.do) suppress
*
*di "------------------------------------------"
*
*stata_linter_detect, input(bad_detect.do) suppress summary
*
*di "------------------------------------------"
*
*stata_linter_detect, input(bad_detect.do) suppress summary excel(detect_output.xlsx)
*
*di "------------------------------------------"
*
*stata_linter_detect, input(bad_detect.do) suppress excel(detect_output.xlsx)
*
*di "------------------------------------------"
*
*stata_linter_detect, input(bad_detect.do) nocheck suppress excel(detect_output.xlsx)

exit

global path "/Users/mizuhirosuzuki/Downloads/rio-safe-space-master/Replication Package/dofiles/rider-audits/baseline/2. Cleaning/"
stata_linter_detect, input("${path}/check-in.do") indent(4) tab_space(2)
stata_linter_correct, input("${path}/exit.do") output(test_better.do) indent(4) tab_space(2) automatic replace

global path "/Users/mizuhirosuzuki/Downloads/rio-safe-space-master/Replication Package/dofiles/rider-audits/congestion"
stata_linter_detect_all, input("${path}") indent(2) tab_space(2) linemax(140) suppress excel(detect_output.xlsx)

global path "/Users/mizuhirosuzuki/Dropbox/Replication/AER_Political_Resource_Curse_DATA"
stata_linter_detect_all, input("${path}") indent(2) tab_space(2) linemax(140) suppress excel(detect_output.xlsx)

global path "/Users/mizuhirosuzuki/Dropbox/Replication/AER_Political_Resource_Curse_DATA"
/Users/mizuhirosuzuki/Dropbox/Replication/AKY06_data/SEED+Zip/do files
stata_linter_detect, input("${path}/PRC_AER_Tab6.do") indent(2) tab_space(2) linemax(140)

global path "/Users/mizuhirosuzuki/Dropbox/Replication/AKY06_data/SEED+Zip/do files"
stata_linter_detect_all, input("${path}") indent(2) tab_space(2) linemax(140) suppress excel(detect_output.xlsx)









