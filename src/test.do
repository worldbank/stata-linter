
stata_linter_correct, input(bad.do) output(better.do) automatic replace indent(2)

exit

*stata_linter_detect, input(bad_detect.do) 
*
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

stata_linter_detect, input(${path}/check-in.do) indent(2)

stata_linter_detect, input(${path}/check-out.do) indent(2)
