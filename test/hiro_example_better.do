/* 
version 16.0
University of Wisconsin, Madison
Creator: Mizuhiro Suzuki (msuzuki7@wisc.edu)
Date Created : Apr 12, 2020
*/

version 16.0
*HIRO COMPUTER:
  global Output /Users/mizuhirosuzuki/Dropbox/Brazil_Audit/Outputs/
  global data "/Users/mizuhirosuzuki/Dropbox/Brazil_Audit/Documents/Data/Temp"
  global dofiles "/Users/mizuhirosuzuki/Dropbox/Brazil_Audit/Codes/Stata/regression"

cd $dofiles

* Summary statistics ---------------
use $data/main_data_br_col.dta, clear

bysort municipality_ibge_code: gen audit_time = _n
recode audit_time (1 = 0) (2 = 1)

gen pos_image = (num_image > 0)
gen pos_table = (num_table > 0)

gen ratio_str_sub = pol_str_sub_pri / num_token * 100
gen ratio_weak_sub = pol_weak_sub_pri / num_token * 100
gen ratio_sub = (pol_str_sub_pri + pol_weak_sub_pri) / num_token * 100
gen ratio_pos = pol_pos_pri / num_token * 100
gen ratio_neg = pol_neg_pri / num_token * 100

label var page_number "Page Counts"
label var num_image "Number of images"
label var pos_image "Non-zero images"
label var num_table "Number of tables"
replace num_token = num_token / 1000
label var num_token "Number of words (1,000)"
label var temp_lr_dt "Long-run average temp."
label var wb_lr_dt "Long-run average wet bulb temp."
label var prcp_lr "Long-run average rainfall"
label var share_urban "Share of urban pop. ($\%$)"
label var share_worker_public "Share of public workers ($\%$)"
label var ln_pop "Log pop."
label var percent_poor "Share of poor pop. ($\%$)"
label var income_percap "Income per capita"
label var audit_time "Second-time audit"
label var ratio_str_sub "Share of strong subj. words ($\%$)"
label var ratio_weak_sub "Share of weak subj. words ($\%$)"
label var ratio_sub "Share of subjective words ($\%$)"
label var ratio_pos "Share of positive words ($\%$)"
label var ratio_neg "Share of negative words ($\%$)"

gen broad_reverse = 0
replace broad_reverse = 1 if broad == 0
gen narrow_reverse = 0
replace narrow_reverse = 1 if narrow == 0

local summary_variables page_number num_image pos_image num_table num_token ///
  ratio_str_sub ratio_weak_sub ratio_sub ratio_pos ratio_neg temp_fw_dt ///
  wb_fw_dt prcp_fw temp_lr_dt wb_lr_dt prcp_lr share_urban ln_pop percent_poor ///
  audit_time

eststo sum1: qui estpost tabstat `summary_variables' if broad == 1, ///
  stat(mean sd) col(stat)
eststo sum2: qui estpost tabstat `summary_variables' if broad == 0, ///
  stat(mean sd) col(stat)
eststo sum3: qui estpost ttest `summary_variables', by(broad_reverse)
esttab sum1 sum2 sum3 using "$Output/tex/_20200806_sumstat_broad.tex", ///
  label cells("mean(pattern(1 1 0) fmt(2)) sd(pattern(1 1 0)) b(star pattern(0 0 1) fmt(2)) se(pattern(0 0 1) par fmt(2))") ///
  replace mlabels("Broad = 1" "Broad = 0" "Difference ((1) - (2))", span prefix(\multicolumn {@span} {c} {) suffix(}))
eststo clear

eststo sum1: qui estpost tabstat `summary_variables' if narrow == 1, ///
  stat(mean sd) col(stat)
eststo sum2: qui estpost tabstat `summary_variables' if narrow == 0, ///
  stat(mean sd) col(stat)
eststo sum3: qui estpost ttest `summary_variables', by(narrow_reverse)
esttab sum1 sum2 sum3 using "$Output/tex/_20200806_sumstat_narrow.tex", ///
  label cells("mean(pattern(1 1 0) fmt(2)) sd(pattern(1 1 0)) b(star pattern(0 0 1) fmt(2)) se(pattern(0 0 1) par fmt(2))") ///
  replace mlabels("Narrow = 1" "Narrow = 0" "Difference ((1) - (2))", span prefix(\multicolumn {@span} {c} {) suffix(}))
eststo clear

* Preparation

clear all

* define a program to run a series of FE regressions
program define fe_reg_series
syntax, outfile(name) outcome(varlist ts fv) ctitle(string asis) weather_var(varlist ts fv) ///
  other_weather(varlist ts fv) fixed_effect(varlist ts fv) control(varlist ts fv) ///
  control_lr(varlist ts fv) vce(namelist) addtext(string asis)
  local n : word count `outcome'
  forvalues i = 1/`n' {
    local outcome_i : word `i' of `outcome'
    local ctitle_i : word `i' of `ctitle'
    local weather_i : word `i' of `weather_var'
    local control_lr_i : word `i' of `control_lr'

    qui: reghdfe `outcome_i' `weather_i' `other_weather' `control_lr_i' ///
      `control', a(`fixed_effect') vce(`vce')
    qui: sum `outcome_i' 
    scalar mean_outcome = r(mean)
    local mean_outcome=scalar(mean_outcome)
    qui: sum `weather_i' 
    scalar sd_weather = r(sd)
    local sd_weather=scalar(sd_weather)
    outreg2 using "$Output/tex/`outfile'", ///
      label tex(frag) keep(`weather_i' `other_weather') sortvar(`weather_var') ///
      adds(Mean of outcome, `mean_outcome', SD of temperature, `sd_weather') ///
      nocons ctitle(`ctitle_i') nonotes addnote("*** p<0.01, ** p<0.05, * p<0.1") ///
      addtext(`addtext')
  }

end

program define fe_reg_series_nl
syntax, outfile(name) outcome(varlist ts fv) ctitle(string asis) weather_var1(varlist ts fv) ///
  weather_var2(varlist ts fv) other_weather(varlist ts fv) fixed_effect(varlist ts fv) ///
  control(varlist ts fv) control_lr(varlist ts fv) vce(namelist) addtext(string asis)

  * 1 ======
  local outcome_i : word 1 of `outcome'
  local ctitle_i : word 1 of `ctitle'
  local control_lr_i : word 1 of `control_lr'

  qui: reghdfe `outcome_i' `weather_var1' `other_weather' `control_lr_i' ///
    `control', a(`fixed_effect') vce(`vce')
  matrix coef = e(b)
  matrix var_cov = e(V)
  mat2txt, matrix(coef) saving("$Output/txt/`outfile'_b1.txt") replace
  mat2txt, matrix(var_cov) saving("$Output/txt/`outfile'_v1.txt") replace
  qui: sum `outcome_i' 
  scalar mean_outcome = r(mean)
  local mean_outcome=scalar(mean_outcome)
  outreg2 using "$Output/tex/`outfile'", ///
    label tex(frag) keep(`weather_var1') sortvar(`weather_var1' `weather_var2') ///
    adds(Mean of outcome, `mean_outcome') nocons ctitle(`ctitle_i') nonotes ///
    addnote("*** p<0.01, ** p<0.05, * p<0.1") addtext(`addtext')

  * 2 ======
  local outcome_i : word 2 of `outcome'
  local ctitle_i : word 2 of `ctitle'
  local control_lr_i : word 1 of `control_lr'

  qui: reghdfe `outcome_i' `weather_var1' `other_weather' `control_lr_i' ///
    `control', a(`fixed_effect') vce(`vce')
  matrix coef = e(b)
  matrix var_cov = e(V)
  mat2txt, matrix(coef) saving("$Output/txt/`outfile'_b2.txt") replace
  mat2txt, matrix(var_cov) saving("$Output/txt/`outfile'_v2.txt") replace
  qui: sum `outcome_i' 
  scalar mean_outcome = r(mean)
  local mean_outcome=scalar(mean_outcome)
  outreg2 using "$Output/tex/`outfile'", ///
    label tex(frag) keep(`weather_var1') sortvar(`weather_var1' `weather_var2') ///
    adds(Mean of outcome, `mean_outcome') nocons ctitle(`ctitle_i') nonotes ///
    addnote("*** p<0.01, ** p<0.05, * p<0.1") addtext(`addtext')

  * 3 ======
  local outcome_i : word 3 of `outcome'
  local ctitle_i : word 3 of `ctitle'
  local control_lr_i : word 2 of `control_lr'

  qui: reghdfe `outcome_i' `weather_var2' `other_weather' `control_lr_i' ///
    `control', a(`fixed_effect') vce(`vce')
  matrix coef = e(b)
  matrix var_cov = e(V)
  mat2txt, matrix(coef) saving("$Output/txt/`outfile'_b3.txt") replace
  mat2txt, matrix(var_cov) saving("$Output/txt/`outfile'_v3.txt") replace
  qui: sum `outcome_i' 
  scalar mean_outcome = r(mean)
  local mean_outcome=scalar(mean_outcome)
  outreg2 using "$Output/tex/`outfile'", ///
    label tex(frag) keep(`weather_var2') sortvar(`weather_var1' `weather_var2') ///
    adds(Mean of outcome, `mean_outcome') nocons ctitle(`ctitle_i') nonotes ///
    addnote("*** p<0.01, ** p<0.05, * p<0.1") addtext(`addtext')

  * 4 ======
  local outcome_i : word 4 of `outcome'
  local ctitle_i : word 4 of `ctitle'
  local control_lr_i : word 2 of `control_lr'

  qui: reghdfe `outcome_i' `weather_var2' `other_weather' `control_lr_i' ///
    `control', a(`fixed_effect') vce(`vce')
  matrix coef = e(b)
  matrix var_cov = e(V)
  mat2txt, matrix(coef) saving("$Output/txt/`outfile'_b4.txt") replace
  mat2txt, matrix(var_cov) saving("$Output/txt/`outfile'_v4.txt") replace
  qui: sum `outcome_i' 
  scalar mean_outcome = r(mean)
  local mean_outcome=scalar(mean_outcome)
  outreg2 using "$Output/tex/`outfile'", ///
    label tex(frag) keep(`weather_var2') sortvar(`weather_var1' `weather_var2') ///
    adds(Mean of outcome, `mean_outcome') nocons ctitle(`ctitle_i') nonotes ///
    addnote("*** p<0.01, ** p<0.05, * p<0.1") addtext(`addtext')

end

program define fe_reg_series_nl_page
syntax, outfile(name) outcome(varlist ts fv) ctitle(string asis) weather_var1(varlist ts fv) ///
  weather_var2(varlist ts fv) other_weather(varlist ts fv) fixed_effect(varlist ts fv) ///
  control(varlist ts fv) control_lr(varlist ts fv) vce(namelist) addtext(string asis)

  * 1 ======
  local outcome_i : word 1 of `outcome'
  local ctitle_i : word 1 of `ctitle'
  local control_lr_i : word 1 of `control_lr'

  qui: reghdfe `outcome_i' `weather_var1' `other_weather' `control_lr_i' ///
    `control', a(`fixed_effect') vce(`vce')
  matrix coef = e(b)
  matrix var_cov = e(V)
  mat2txt, matrix(coef) saving("$Output/txt/`outfile'_b1.txt") replace
  mat2txt, matrix(var_cov) saving("$Output/txt/`outfile'_v1.txt") replace
  qui: sum `outcome_i' 
  scalar mean_outcome = r(mean)
  local mean_outcome=scalar(mean_outcome)
  outreg2 using "$Output/tex/`outfile'", ///
    label tex(frag) keep(`weather_var1') sortvar(`weather_var1' `weather_var2') ///
    adds(Mean of outcome, `mean_outcome') nocons ctitle(`ctitle_i') nonotes ///
    addnote("*** p<0.01, ** p<0.05, * p<0.1") addtext(`addtext')

  * 2 ======
  local outcome_i : word 2 of `outcome'
  local ctitle_i : word 2 of `ctitle'
  local control_lr_i : word 2 of `control_lr'

  qui: reghdfe `outcome_i' `weather_var2' `other_weather' `control_lr_i' ///
    `control', a(`fixed_effect') vce(`vce')
  matrix coef = e(b)
  matrix var_cov = e(V)
  mat2txt, matrix(coef) saving("$Output/txt/`outfile'_b2.txt") replace
  mat2txt, matrix(var_cov) saving("$Output/txt/`outfile'_v2.txt") replace
  qui: sum `outcome_i' 
  scalar mean_outcome = r(mean)
  local mean_outcome=scalar(mean_outcome)
  outreg2 using "$Output/tex/`outfile'", ///
    label tex(frag) keep(`weather_var2') sortvar(`weather_var1' `weather_var2') ///
    adds(Mean of outcome, `mean_outcome') nocons ctitle(`ctitle_i') nonotes ///
    addnote("*** p<0.01, ** p<0.05, * p<0.1") addtext(`addtext')

end

* define a program to run a series of FE regressions for falsification tests
program define fe_reg_series_pl
syntax, outfile(name) outcome(varlist ts fv) ctitle(string asis) weather_var(varlist ts fv) ///
  weather_l1_var(varlist ts fv) weather_f1_var(varlist ts fv) other_weather(varlist ts fv) ///
  fixed_effect(varlist ts fv) control(varlist ts fv) control_lr(varlist ts fv) ///
  vce(namelist) addtext(string asis)
  local n : word count `outcome'
  forvalues i = 1/`n' {
    local outcome_i : word `i' of `outcome'
    local ctitle_i : word `i' of `ctitle'
    local weather_i : word `i' of `weather_var'
    local weather_l1_i : word `i' of `weather_l1_var'
    local weather_f1_i : word `i' of `weather_f1_var'
    local control_lr_i : word `i' of `control_lr'

    qui: reghdfe `outcome_i' `weather_i' `weather_l1_i' `weather_f1_i' ///
      `other_weather' `control_lr_i' `control', ///
      a(`fixed_effect') vce(`vce')
    qui: sum `outcome_i' 
    scalar mean_outcome = r(mean)
    local mean_outcome=scalar(mean_outcome)
    outreg2 using "$Output/tex/`outfile'", ///
      label tex(frag) keep(`weather_i' `weather_l1_i' `weather_f1_i') sortvar(`weather_var' `weather_l1_var' `weather_f1_var') ///
      adds(Mean of outcome, `mean_outcome') nocons ctitle(`ctitle_i') nonotes ///
      addnote("*** p<0.01, ** p<0.05, * p<0.1") addtext(`addtext')
  }

end

* erase 
cap shell rm $Output/tex/_20200806_reg_*.tex
cap shell rm $Output/tex/_20200806_reg_*.txt
cap shell rm $Output/txt/_20200806_reg_*.txt

* Run regressions ------------------
* Brollo data (collapsed) ==================
use $data/main_data_br_col.dta, clear

gen after_election = (wave >= 10)
egen temp_fw_dt_nl = cut(temp_fw_dt), ///
  at(0, 22, 24, 26, 28, 30, 32, 40) icodes label
egen wb_fw_dt_nl = cut(wb_fw_dt), ///
  at(0, 18, 20, 22, 24, 26, 28, 40) icodes label
egen temp_lr_dt_nl = cut(temp_lr_dt), ///
  at(0, 22, 24, 26, 28, 30, 32, 40) icodes label
egen wb_lr_dt_nl = cut(wb_lr_dt), ///
  at(0, 18, 20, 22, 24, 26, 28, 40) icodes label

gen log_page = log(page_number)
gen ihs_image = asinh(num_image)
gen log_image = log(num_image)
gen pos_image = (num_image > 0)
gen ihs_table = asinh(num_table)
gen log_table = log(num_table)
gen pos_table = (num_table > 0)
gen log_num_token = log(num_token)

gen ratio_str_sub = pol_str_sub_pri / num_token
gen ratio_weak_sub = pol_weak_sub_pri / num_token
gen ratio_sub = (pol_str_sub_pri + pol_weak_sub_pri) / num_token
gen ratio_pos = pol_pos_pri / num_token
gen ratio_neg = pol_neg_pri / num_token

bysort municipality_ibge_code: gen audit_time = _n

gen broad_reverse = 0
replace broad_reverse = 1 if broad == 0
gen narrow_reverse = 0
replace narrow_reverse = 1 if narrow == 0
label var page_number "Number of pages"
label var num_image "Number of images"
label var num_table "Number of tables"

* Regression with corruption measures as outcomes -----
* Define local variable lists
local outcome broad narrow broad narrow
local ctitle `" "Broad" "Narrow" "Broad" "Narrow" "'
local weather_var temp_fw_dt temp_fw_dt wb_fw_dt wb_fw_dt 
local weather_nl_var ib3.temp_fw_dt_nl ib3.temp_fw_dt_nl ib3.wb_fw_dt_nl ///
  ib3.wb_fw_dt_nl
local control_lr temp_lr_dt temp_lr_dt wb_lr_dt wb_lr_dt 
local control_lr_nl i.temp_lr_dt_nl i.temp_lr_dt_nl i.wb_lr_dt_nl i.wb_lr_dt_nl
local weather_l1_var temp_fw_dt_l1 temp_fw_dt_l1 wb_fw_dt_l1 wb_fw_dt_l1 
local weather_f1_var temp_fw_dt_f1 temp_fw_dt_f1 wb_fw_dt_f1 wb_fw_dt_f1 

local other_weather prcp_fw
local control share_urban ln_pop percent_poor prcp_lr i.audit_time

fe_reg_series, outfile(_20200806_reg_br_col) outcome(`outcome') ctitle(`ctitle') ///
  weather_var(`weather_var') other_weather(`other_weather') fixed_effect(uf_code wave) ///
  control(`control') control_lr(`control_lr') vce(cluster municipality_ibge_code) ///
  addtext(State FE, Yes, Wave FE, Yes, Controls, Yes)
fe_reg_series_nl, outfile(_20200806_reg_br_col_nl) outcome(`outcome') ctitle(`ctitle') ///
  weather_var1(ib3.temp_fw_dt_nl) weather_var2(ib3.wb_fw_dt_nl) other_weather(`other_weather') ///
  fixed_effect(uf_code wave) control(`control') control_lr(`control_lr_nl') ///
  vce(cluster municipality_ibge_code) addtext(State FE, Yes, Wave FE, Yes, Controls, Yes)
fe_reg_series_pl, outfile(_20200806_reg_br_col_pl) outcome(`outcome') ctitle(`ctitle') ///
  weather_var(`weather_var') weather_l1_var(`weather_l1_var') weather_f1_var(`weather_f1_var') ///
  other_weather(`other_weather') fixed_effect(uf_code wave) control(`control') ///
  control_lr(`control_lr') vce(cluster municipality_ibge_code) addtext(State FE, Yes, Wave FE, Yes, Controls, Yes)

* Regression with page counts as outcome -----
* Define local variable lists
local outcome page_number log_page page_number log_page
local ctitle `" "Pages" "Log Pages" "Pages" "Log Pages" "'
local weather_var temp_fw_dt temp_fw_dt wb_fw_dt wb_fw_dt 
local weather_nl_var ib3.temp_fw_dt_nl ib3.temp_fw_dt_nl ib3.wb_fw_dt_nl ///
  ib3.wb_fw_dt_nl
local control_lr temp_lr_dt temp_lr_dt wb_lr_dt wb_lr_dt 
local control_lr_nl i.temp_lr_dt_nl i.temp_lr_dt_nl i.wb_lr_dt_nl i.wb_lr_dt_nl
local weather_l1_var temp_fw_dt_l1 temp_fw_dt_l1 wb_fw_dt_l1 wb_fw_dt_l1 
local weather_f1_var temp_fw_dt_f1 temp_fw_dt_f1 wb_fw_dt_f1 wb_fw_dt_f1 

local other_weather prcp_fw
local control share_urban ln_pop percent_poor prcp_lr i.audit_time

fe_reg_series, outfile(_20200806_reg_br_page) outcome(`outcome') ctitle(`ctitle') ///
  weather_var(`weather_var') other_weather(`other_weather') fixed_effect(uf_code wave) ///
  control(`control') control_lr(`control_lr') vce(cluster municipality_ibge_code) ///
  addtext(State FE, Yes, Wave FE, Yes, Controls, Yes)
fe_reg_series_nl, outfile(_20200806_reg_br_page_nl) outcome(`outcome') ///
  ctitle(`ctitle') weather_var1(ib3.temp_fw_dt_nl) weather_var2(ib3.wb_fw_dt_nl) ///
  other_weather(`other_weather') fixed_effect(uf_code wave) control(`control') ///
  control_lr(`control_lr_nl') vce(cluster municipality_ibge_code) addtext(State FE, Yes, Wave FE, Yes, Controls, Yes)
fe_reg_series_pl, outfile(_20200806_reg_br_page_pl) outcome(`outcome') ///
  ctitle(`ctitle') weather_var(`weather_var') weather_l1_var(`weather_l1_var') ///
  weather_f1_var(`weather_f1_var') other_weather(`other_weather') fixed_effect(uf_code wave) ///
  control(`control') control_lr(`control_lr') vce(cluster municipality_ibge_code) ///
  addtext(State FE, Yes, Wave FE, Yes, Controls, Yes)

fe_reg_series, outfile(_20200806_reg_br_page_br) outcome(`outcome') ctitle(`ctitle') ///
  weather_var(`weather_var') other_weather(broad `other_weather') fixed_effect(uf_code wave) ///
  control(`control') control_lr(`control_lr') vce(cluster municipality_ibge_code) ///
  addtext(State FE, Yes, Wave FE, Yes, Controls, Yes)
fe_reg_series_nl, outfile(_20200806_reg_br_page_nl_br) outcome(`outcome') ///
  ctitle(`ctitle') weather_var1(ib3.temp_fw_dt_nl) weather_var2(ib3.wb_fw_dt_nl) ///
  other_weather(broad `other_weather') fixed_effect(uf_code wave) control(`control') ///
  control_lr(`control_lr_nl') vce(cluster municipality_ibge_code) addtext(State FE, Yes, Wave FE, Yes, Controls, Yes)
fe_reg_series_pl, outfile(_20200806_reg_br_page_pl_br) outcome(`outcome') ///
  ctitle(`ctitle') weather_var(`weather_var') weather_l1_var(`weather_l1_var') ///
  weather_f1_var(`weather_f1_var') other_weather(broad `other_weather') ///
  fixed_effect(uf_code wave) control(`control') control_lr(`control_lr') ///
  vce(cluster municipality_ibge_code) addtext(State FE, Yes, Wave FE, Yes, Controls, Yes)

fe_reg_series, outfile(_20200806_reg_br_page_na) outcome(`outcome') ctitle(`ctitle') ///
  weather_var(`weather_var') other_weather(narrow `other_weather') fixed_effect(uf_code wave) ///
  control(`control') control_lr(`control_lr') vce(cluster municipality_ibge_code) ///
  addtext(State FE, Yes, Wave FE, Yes, Controls, Yes)
fe_reg_series_nl, outfile(_20200806_reg_br_page_nl_na) outcome(`outcome') ///
  ctitle(`ctitle') weather_var1(ib3.temp_fw_dt_nl) weather_var2(ib3.wb_fw_dt_nl) ///
  other_weather(narrow `other_weather') fixed_effect(uf_code wave) control(`control') ///
  control_lr(`control_lr_nl') vce(cluster municipality_ibge_code) addtext(State FE, Yes, Wave FE, Yes, Controls, Yes)
fe_reg_series_pl, outfile(_20200806_reg_br_page_pl_na) outcome(`outcome') ///
  ctitle(`ctitle') weather_var(`weather_var') weather_l1_var(`weather_l1_var') ///
  weather_f1_var(`weather_f1_var') other_weather(narrow `other_weather') ///
  fixed_effect(uf_code wave) control(`control') control_lr(`control_lr') ///
  vce(cluster municipality_ibge_code) addtext(State FE, Yes, Wave FE, Yes, Controls, Yes)

fe_reg_series, outfile(_20200806_reg_br_page_br_i) outcome(`outcome') ctitle(`ctitle') ///
  weather_var(`weather_var') other_weather(num_image broad `other_weather') ///
  fixed_effect(uf_code wave) control(`control') control_lr(`control_lr') ///
  vce(cluster municipality_ibge_code) addtext(State FE, Yes, Wave FE, Yes, Controls, Yes)
fe_reg_series_nl, outfile(_20200806_reg_br_page_nl_br_i) outcome(`outcome') ///
  ctitle(`ctitle') weather_var1(ib3.temp_fw_dt_nl) weather_var2(ib3.wb_fw_dt_nl) ///
  other_weather(num_image broad `other_weather') fixed_effect(uf_code wave) ///
  control(`control') control_lr(`control_lr_nl') vce(cluster municipality_ibge_code) ///
  addtext(State FE, Yes, Wave FE, Yes, Controls, Yes)
fe_reg_series_pl, outfile(_20200806_reg_br_page_pl_br_i) outcome(`outcome') ///
  ctitle(`ctitle') weather_var(`weather_var') weather_l1_var(`weather_l1_var') ///
  weather_f1_var(`weather_f1_var') other_weather(num_image broad `other_weather') ///
  fixed_effect(uf_code wave) control(`control') control_lr(`control_lr') ///
  vce(cluster municipality_ibge_code) addtext(State FE, Yes, Wave FE, Yes, Controls, Yes)

fe_reg_series, outfile(_20200806_reg_br_page_br_li) outcome(`outcome') ///
  ctitle(`ctitle') weather_var(`weather_var') other_weather(ihs_image broad `other_weather') ///
  fixed_effect(uf_code wave) control(`control') control_lr(`control_lr') ///
  vce(cluster municipality_ibge_code) addtext(State FE, Yes, Wave FE, Yes, Controls, Yes)
fe_reg_series_nl, outfile(_20200806_reg_br_page_nl_br_li) outcome(`outcome') ///
  ctitle(`ctitle') weather_var1(ib3.temp_fw_dt_nl) weather_var2(ib3.wb_fw_dt_nl) ///
  other_weather(ihs_image broad `other_weather') fixed_effect(uf_code wave) ///
  control(`control') control_lr(`control_lr_nl') vce(cluster municipality_ibge_code) ///
  addtext(State FE, Yes, Wave FE, Yes, Controls, Yes)
fe_reg_series_pl, outfile(_20200806_reg_br_page_pl_br_li) outcome(`outcome') ///
  ctitle(`ctitle') weather_var(`weather_var') weather_l1_var(`weather_l1_var') ///
  weather_f1_var(`weather_f1_var') other_weather(ihs_image broad `other_weather') ///
  fixed_effect(uf_code wave) control(`control') control_lr(`control_lr') ///
  vce(cluster municipality_ibge_code) addtext(State FE, Yes, Wave FE, Yes, Controls, Yes)

fe_reg_series, outfile(_20200806_reg_br_page_br_lit) outcome(`outcome') ///
  ctitle(`ctitle') weather_var(`weather_var') other_weather(ihs_image log_table broad `other_weather') ///
  fixed_effect(uf_code wave) control(`control') control_lr(`control_lr') ///
  vce(cluster municipality_ibge_code) addtext(State FE, Yes, Wave FE, Yes, Controls, Yes)
fe_reg_series_nl, outfile(_20200806_reg_br_page_nl_br_lit) outcome(`outcome') ///
  ctitle(`ctitle') weather_var1(ib3.temp_fw_dt_nl) weather_var2(ib3.wb_fw_dt_nl) ///
  other_weather(ihs_image log_table broad `other_weather') fixed_effect(uf_code wave) ///
  control(`control') control_lr(`control_lr_nl') vce(cluster municipality_ibge_code) ///
  addtext(State FE, Yes, Wave FE, Yes, Controls, Yes)
fe_reg_series_pl, outfile(_20200806_reg_br_page_pl_br_lit) outcome(`outcome') ///
  ctitle(`ctitle') weather_var(`weather_var') weather_l1_var(`weather_l1_var') ///
  weather_f1_var(`weather_f1_var') other_weather(ihs_image log_table broad `other_weather') ///
  fixed_effect(uf_code wave) control(`control') control_lr(`control_lr') ///
  vce(cluster municipality_ibge_code) addtext(State FE, Yes, Wave FE, Yes, Controls, Yes)

fe_reg_series, outfile(_20200806_reg_br_page_na_i) outcome(`outcome') ctitle(`ctitle') ///
  weather_var(`weather_var') other_weather(num_image narrow `other_weather') ///
  fixed_effect(uf_code wave) control(`control') control_lr(`control_lr') ///
  vce(cluster municipality_ibge_code) addtext(State FE, Yes, Wave FE, Yes, Controls, Yes)
fe_reg_series_nl, outfile(_20200806_reg_br_page_nl_na_i) outcome(`outcome') ///
  ctitle(`ctitle') weather_var1(ib3.temp_fw_dt_nl) weather_var2(ib3.wb_fw_dt_nl) ///
  other_weather(num_image narrow `other_weather') fixed_effect(uf_code wave) ///
  control(`control') control_lr(`control_lr_nl') vce(cluster municipality_ibge_code) ///
  addtext(State FE, Yes, Wave FE, Yes, Controls, Yes)
fe_reg_series_pl, outfile(_20200806_reg_br_page_pl_na_i) outcome(`outcome') ///
  ctitle(`ctitle') weather_var(`weather_var') weather_l1_var(`weather_l1_var') ///
  weather_f1_var(`weather_f1_var') other_weather(num_image narrow `other_weather') ///
  fixed_effect(uf_code wave) control(`control') control_lr(`control_lr') ///
  vce(cluster municipality_ibge_code) addtext(State FE, Yes, Wave FE, Yes, Controls, Yes)

fe_reg_series, outfile(_20200806_reg_br_page_na_li) outcome(`outcome') ///
  ctitle(`ctitle') weather_var(`weather_var') other_weather(ihs_image narrow `other_weather') ///
  fixed_effect(uf_code wave) control(`control') control_lr(`control_lr') ///
  vce(cluster municipality_ibge_code) addtext(State FE, Yes, Wave FE, Yes, Controls, Yes)
fe_reg_series_nl, outfile(_20200806_reg_br_page_nl_na_li) outcome(`outcome') ///
  ctitle(`ctitle') weather_var1(ib3.temp_fw_dt_nl) weather_var2(ib3.wb_fw_dt_nl) ///
  other_weather(ihs_image narrow `other_weather') fixed_effect(uf_code wave) ///
  control(`control') control_lr(`control_lr_nl') vce(cluster municipality_ibge_code) ///
  addtext(State FE, Yes, Wave FE, Yes, Controls, Yes)
fe_reg_series_pl, outfile(_20200806_reg_br_page_pl_na_li) outcome(`outcome') ///
  ctitle(`ctitle') weather_var(`weather_var') weather_l1_var(`weather_l1_var') ///
  weather_f1_var(`weather_f1_var') other_weather(ihs_image narrow `other_weather') ///
  fixed_effect(uf_code wave) control(`control') control_lr(`control_lr') ///
  vce(cluster municipality_ibge_code) addtext(State FE, Yes, Wave FE, Yes, Controls, Yes)

fe_reg_series, outfile(_20200806_reg_br_page_na_lit) outcome(`outcome') ///
  ctitle(`ctitle') weather_var(`weather_var') other_weather(ihs_image log_table narrow `other_weather') ///
  fixed_effect(uf_code wave) control(`control') control_lr(`control_lr') ///
  vce(cluster municipality_ibge_code) addtext(State FE, Yes, Wave FE, Yes, Controls, Yes)
fe_reg_series_nl, outfile(_20200806_reg_br_page_nl_na_lit) outcome(`outcome') ///
  ctitle(`ctitle') weather_var1(ib3.temp_fw_dt_nl) weather_var2(ib3.wb_fw_dt_nl) ///
  other_weather(ihs_image log_table narrow `other_weather') fixed_effect(uf_code wave) ///
  control(`control') control_lr(`control_lr_nl') vce(cluster municipality_ibge_code) ///
  addtext(State FE, Yes, Wave FE, Yes, Controls, Yes)
fe_reg_series_pl, outfile(_20200806_reg_br_page_pl_na_lit) outcome(`outcome') ///
  ctitle(`ctitle') weather_var(`weather_var') weather_l1_var(`weather_l1_var') ///
  weather_f1_var(`weather_f1_var') other_weather(ihs_image log_table narrow `other_weather') ///
  fixed_effect(uf_code wave) control(`control') control_lr(`control_lr') ///
  vce(cluster municipality_ibge_code) addtext(State FE, Yes, Wave FE, Yes, Controls, Yes)

fe_reg_series, outfile(_20200806_reg_br_page_lit) outcome(`outcome') ctitle(`ctitle') ///
  weather_var(`weather_var') other_weather(ihs_image log_table `other_weather') ///
  fixed_effect(uf_code wave) control(`control') control_lr(`control_lr') ///
  vce(cluster municipality_ibge_code) addtext(State FE, Yes, Wave FE, Yes, Controls, Yes)
fe_reg_series_nl, outfile(_20200806_reg_br_page_nl_lit) outcome(`outcome') ///
  ctitle(`ctitle') weather_var1(ib3.temp_fw_dt_nl) weather_var2(ib3.wb_fw_dt_nl) ///
  other_weather(ihs_image log_table `other_weather') fixed_effect(uf_code wave) ///
  control(`control') control_lr(`control_lr_nl') vce(cluster municipality_ibge_code) ///
  addtext(State FE, Yes, Wave FE, Yes, Controls, Yes)
fe_reg_series_pl, outfile(_20200806_reg_br_page_pl_lit) outcome(`outcome') ///
  ctitle(`ctitle') weather_var(`weather_var') weather_l1_var(`weather_l1_var') ///
  weather_f1_var(`weather_f1_var') other_weather(ihs_image log_table `other_weather') ///
  fixed_effect(uf_code wave) control(`control') control_lr(`control_lr') ///
  vce(cluster municipality_ibge_code) addtext(State FE, Yes, Wave FE, Yes, Controls, Yes)

eststo broad_1: qui estpost summarize page_number if broad == 1
eststo broad_0: qui estpost summarize page_number if broad == 0
eststo broad_diff: qui estpost ttest page_number, by(broad_reverse)
esttab broad_1 broad_0 broad_diff using "../../../Outputs/tex/page_broad.tex", ///
  cells("mean(pattern(1 1 0) fmt(2)) sd(pattern(1 1 0)) b(star pattern(0 0 1) fmt(2)) se(pattern(0 0 1) par fmt(2))") ///
  label replace  mlabels("Broad = 1" "Broad = 0" "Difference ((1) - (2))", span prefix(\multicolumn {@span} {c} {) suffix(}))

eststo narrow_1: qui estpost summarize page_number if narrow == 1
eststo narrow_0: qui estpost summarize page_number if narrow == 0
eststo narrow_diff: qui estpost ttest page_number, by(narrow_reverse)
esttab narrow_1 narrow_0 narrow_diff using "../../../Outputs/tex/page_narrow.tex", ///
  cells("mean(pattern(1 1 0) fmt(2)) sd(pattern(1 1 0)) b(star pattern(0 0 1) fmt(2)) se(pattern(0 0 1) par fmt(2))") ///
  label replace  mlabels("Narrow = 1" "Narrow = 0" "Difference ((1) - (2))", span prefix(\multicolumn {@span} {c} {) suffix(}))

* Regression with image counts as outcome -----
* Define local variable lists
local outcome num_image ihs_image num_image ihs_image
local ctitle `" "Images" "IHS Images" "Images" "IHS Images" "'
local weather_var temp_fw_dt temp_fw_dt wb_fw_dt wb_fw_dt 
local weather_nl_var ib3.temp_fw_dt_nl ib3.temp_fw_dt_nl ib3.wb_fw_dt_nl ///
  ib3.wb_fw_dt_nl
local control_lr temp_lr_dt temp_lr_dt wb_lr_dt wb_lr_dt 
local control_lr_nl i.temp_lr_dt_nl i.temp_lr_dt_nl i.wb_lr_dt_nl i.wb_lr_dt_nl
local weather_l1_var temp_fw_dt_l1 temp_fw_dt_l1 wb_fw_dt_l1 wb_fw_dt_l1 
local weather_f1_var temp_fw_dt_f1 temp_fw_dt_f1 wb_fw_dt_f1 wb_fw_dt_f1 

local other_weather prcp_fw
local control share_urban ln_pop percent_poor prcp_lr i.audit_time

fe_reg_series, outfile(_20200806_reg_br_image) outcome(`outcome') ctitle(`ctitle') ///
  weather_var(`weather_var') other_weather(`other_weather') fixed_effect(uf_code wave) ///
  control(`control') control_lr(`control_lr') vce(cluster municipality_ibge_code) ///
  addtext(State FE, Yes, Wave FE, Yes, Controls, Yes)
fe_reg_series_nl, outfile(_20200806_reg_br_image_nl) outcome(`outcome') ///
  ctitle(`ctitle') weather_var1(ib3.temp_fw_dt_nl) weather_var2(ib3.wb_fw_dt_nl) ///
  other_weather(`other_weather') fixed_effect(uf_code wave) control(`control') ///
  control_lr(`control_lr_nl') vce(cluster municipality_ibge_code) addtext(State FE, Yes, Wave FE, Yes, Controls, Yes)
fe_reg_series_pl, outfile(_20200806_reg_br_image_pl) outcome(`outcome') ///
  ctitle(`ctitle') weather_var(`weather_var') weather_l1_var(`weather_l1_var') ///
  weather_f1_var(`weather_f1_var') other_weather(`other_weather') fixed_effect(uf_code wave) ///
  control(`control') control_lr(`control_lr') vce(cluster municipality_ibge_code) ///
  addtext(State FE, Yes, Wave FE, Yes, Controls, Yes)

fe_reg_series, outfile(_20200806_reg_br_image_br) outcome(`outcome') ctitle(`ctitle') ///
  weather_var(`weather_var') other_weather(broad `other_weather') fixed_effect(uf_code wave) ///
  control(`control') control_lr(`control_lr') vce(cluster municipality_ibge_code) ///
  addtext(State FE, Yes, Wave FE, Yes, Controls, Yes)
fe_reg_series_nl, outfile(_20200806_reg_br_image_nl_br) outcome(`outcome') ///
  ctitle(`ctitle') weather_var1(ib3.temp_fw_dt_nl) weather_var2(ib3.wb_fw_dt_nl) ///
  other_weather(broad `other_weather') fixed_effect(uf_code wave) control(`control') ///
  control_lr(`control_lr_nl') vce(cluster municipality_ibge_code) addtext(State FE, Yes, Wave FE, Yes, Controls, Yes)
fe_reg_series_pl, outfile(_20200806_reg_br_image_pl_br) outcome(`outcome') ///
  ctitle(`ctitle') weather_var(`weather_var') weather_l1_var(`weather_l1_var') ///
  weather_f1_var(`weather_f1_var') other_weather(broad `other_weather') ///
  fixed_effect(uf_code wave) control(`control') control_lr(`control_lr') ///
  vce(cluster municipality_ibge_code) addtext(State FE, Yes, Wave FE, Yes, Controls, Yes)

fe_reg_series, outfile(_20200806_reg_br_image_na) outcome(`outcome') ctitle(`ctitle') ///
  weather_var(`weather_var') other_weather(narrow `other_weather') fixed_effect(uf_code wave) ///
  control(`control') control_lr(`control_lr') vce(cluster municipality_ibge_code) ///
  addtext(State FE, Yes, Wave FE, Yes, Controls, Yes)
fe_reg_series_nl, outfile(_20200806_reg_br_image_nl_na) outcome(`outcome') ///
  ctitle(`ctitle') weather_var1(ib3.temp_fw_dt_nl) weather_var2(ib3.wb_fw_dt_nl) ///
  other_weather(narrow `other_weather') fixed_effect(uf_code wave) control(`control') ///
  control_lr(`control_lr_nl') vce(cluster municipality_ibge_code) addtext(State FE, Yes, Wave FE, Yes, Controls, Yes)
fe_reg_series_pl, outfile(_20200806_reg_br_image_pl_na) outcome(`outcome') ///
  ctitle(`ctitle') weather_var(`weather_var') weather_l1_var(`weather_l1_var') ///
  weather_f1_var(`weather_f1_var') other_weather(narrow `other_weather') ///
  fixed_effect(uf_code wave) control(`control') control_lr(`control_lr') ///
  vce(cluster municipality_ibge_code) addtext(State FE, Yes, Wave FE, Yes, Controls, Yes)

eststo broad_1: qui estpost summarize num_image if broad == 1
eststo broad_0: qui estpost summarize num_image if broad == 0
eststo broad_diff: qui estpost ttest num_image, by(broad_reverse)
esttab broad_1 broad_0 broad_diff using "../../../Outputs/tex/image_broad.tex", ///
  cells("mean(pattern(1 1 0) fmt(2)) sd(pattern(1 1 0)) b(star pattern(0 0 1) fmt(2)) se(pattern(0 0 1) par fmt(2))") ///
  label replace  mlabels("Broad = 1" "Broad = 0" "Difference ((1) - (2))", span prefix(\multicolumn {@span} {c} {) suffix(}))

eststo narrow_1: qui estpost summarize num_image if narrow == 1
eststo narrow_0: qui estpost summarize num_image if narrow == 0
eststo narrow_diff: qui estpost ttest num_image, by(narrow_reverse)
esttab narrow_1 narrow_0 narrow_diff using "../../../Outputs/tex/image_narrow.tex", ///
  cells("mean(pattern(1 1 0) fmt(2)) sd(pattern(1 1 0)) b(star pattern(0 0 1) fmt(2)) se(pattern(0 0 1) par fmt(2))") ///
  label replace  mlabels("Narrow = 1" "Narrow = 0" "Difference ((1) - (2))", span prefix(\multicolumn {@span} {c} {) suffix(}))

* Regression with table counts as outcome -----
* Define local variable lists
local outcome num_table log_table num_table log_table
local ctitle `" "Tables" "Log Tables" "Tables" "Log Tables" "'
local weather_var temp_fw_dt temp_fw_dt wb_fw_dt wb_fw_dt 
local weather_nl_var ib3.temp_fw_dt_nl ib3.temp_fw_dt_nl ib3.wb_fw_dt_nl ///
  ib3.wb_fw_dt_nl
local control_lr temp_lr_dt temp_lr_dt wb_lr_dt wb_lr_dt 
local control_lr_nl i.temp_lr_dt_nl i.temp_lr_dt_nl i.wb_lr_dt_nl i.wb_lr_dt_nl
local weather_l1_var temp_fw_dt_l1 temp_fw_dt_l1 wb_fw_dt_l1 wb_fw_dt_l1 
local weather_f1_var temp_fw_dt_f1 temp_fw_dt_f1 wb_fw_dt_f1 wb_fw_dt_f1 

local other_weather prcp_fw
local control share_urban ln_pop percent_poor prcp_lr i.audit_time

fe_reg_series, outfile(_20200806_reg_br_table) outcome(`outcome') ctitle(`ctitle') ///
  weather_var(`weather_var') other_weather(`other_weather') fixed_effect(uf_code wave) ///
  control(`control') control_lr(`control_lr') vce(cluster municipality_ibge_code) ///
  addtext(State FE, Yes, Wave FE, Yes, Controls, Yes)
fe_reg_series_nl, outfile(_20200806_reg_br_table_nl) outcome(`outcome') ///
  ctitle(`ctitle') weather_var1(ib3.temp_fw_dt_nl) weather_var2(ib3.wb_fw_dt_nl) ///
  other_weather(`other_weather') fixed_effect(uf_code wave) control(`control') ///
  control_lr(`control_lr_nl') vce(cluster municipality_ibge_code) addtext(State FE, Yes, Wave FE, Yes, Controls, Yes)
fe_reg_series_pl, outfile(_20200806_reg_br_table_pl) outcome(`outcome') ///
  ctitle(`ctitle') weather_var(`weather_var') weather_l1_var(`weather_l1_var') ///
  weather_f1_var(`weather_f1_var') other_weather(`other_weather') fixed_effect(uf_code wave) ///
  control(`control') control_lr(`control_lr') vce(cluster municipality_ibge_code) ///
  addtext(State FE, Yes, Wave FE, Yes, Controls, Yes)

fe_reg_series, outfile(_20200806_reg_br_table_br) outcome(`outcome') ctitle(`ctitle') ///
  weather_var(`weather_var') other_weather(broad `other_weather') fixed_effect(uf_code wave) ///
  control(`control') control_lr(`control_lr') vce(cluster municipality_ibge_code) ///
  addtext(State FE, Yes, Wave FE, Yes, Controls, Yes)
fe_reg_series_nl, outfile(_20200806_reg_br_table_nl_br) outcome(`outcome') ///
  ctitle(`ctitle') weather_var1(ib3.temp_fw_dt_nl) weather_var2(ib3.wb_fw_dt_nl) ///
  other_weather(broad `other_weather') fixed_effect(uf_code wave) control(`control') ///
  control_lr(`control_lr_nl') vce(cluster municipality_ibge_code) addtext(State FE, Yes, Wave FE, Yes, Controls, Yes)
fe_reg_series_pl, outfile(_20200806_reg_br_table_pl_br) outcome(`outcome') ///
  ctitle(`ctitle') weather_var(`weather_var') weather_l1_var(`weather_l1_var') ///
  weather_f1_var(`weather_f1_var') other_weather(broad `other_weather') ///
  fixed_effect(uf_code wave) control(`control') control_lr(`control_lr') ///
  vce(cluster municipality_ibge_code) addtext(State FE, Yes, Wave FE, Yes, Controls, Yes)

fe_reg_series, outfile(_20200806_reg_br_table_na) outcome(`outcome') ctitle(`ctitle') ///
  weather_var(`weather_var') other_weather(narrow `other_weather') fixed_effect(uf_code wave) ///
  control(`control') control_lr(`control_lr') vce(cluster municipality_ibge_code) ///
  addtext(State FE, Yes, Wave FE, Yes, Controls, Yes)
fe_reg_series_nl, outfile(_20200806_reg_br_table_nl_na) outcome(`outcome') ///
  ctitle(`ctitle') weather_var1(ib3.temp_fw_dt_nl) weather_var2(ib3.wb_fw_dt_nl) ///
  other_weather(narrow `other_weather') fixed_effect(uf_code wave) control(`control') ///
  control_lr(`control_lr_nl') vce(cluster municipality_ibge_code) addtext(State FE, Yes, Wave FE, Yes, Controls, Yes)
fe_reg_series_pl, outfile(_20200806_reg_br_table_pl_na) outcome(`outcome') ///
  ctitle(`ctitle') weather_var(`weather_var') weather_l1_var(`weather_l1_var') ///
  weather_f1_var(`weather_f1_var') other_weather(narrow `other_weather') ///
  fixed_effect(uf_code wave) control(`control') control_lr(`control_lr') ///
  vce(cluster municipality_ibge_code) addtext(State FE, Yes, Wave FE, Yes, Controls, Yes)

eststo broad_1: qui estpost summarize num_table if broad == 1
eststo broad_0: qui estpost summarize num_table if broad == 0
eststo broad_diff: qui estpost ttest num_table, by(broad_reverse)
esttab broad_1 broad_0 broad_diff using "../../../Outputs/tex/table_broad.tex", ///
  cells("mean(pattern(1 1 0) fmt(2)) sd(pattern(1 1 0)) b(star pattern(0 0 1) fmt(2)) se(pattern(0 0 1) par fmt(2))") ///
  label replace  mlabels("Broad = 1" "Broad = 0" "Difference ((1) - (2))", span prefix(\multicolumn {@span} {c} {) suffix(}))

eststo narrow_1: qui estpost summarize num_table if narrow == 1
eststo narrow_0: qui estpost summarize num_table if narrow == 0
eststo narrow_diff: qui estpost ttest num_table, by(narrow_reverse)
esttab narrow_1 narrow_0 narrow_diff using "../../../Outputs/tex/table_narrow.tex", ///
  cells("mean(pattern(1 1 0) fmt(2)) sd(pattern(1 1 0)) b(star pattern(0 0 1) fmt(2)) se(pattern(0 0 1) par fmt(2))") ///
  label replace  mlabels("Narrow = 1" "Narrow = 0" "Difference ((1) - (2))", span prefix(\multicolumn {@span} {c} {) suffix(}))

* Regression with number of words as outcome -----
* Define local variable lists
local outcome num_token log_num_token num_token log_num_token
local ctitle `" "Words" "Log Words" "Words" "Log Words" "'
local weather_var temp_fw_dt temp_fw_dt wb_fw_dt wb_fw_dt 
local weather_nl_var ib3.temp_fw_dt_nl ib3.temp_fw_dt_nl ib3.wb_fw_dt_nl ///
  ib3.wb_fw_dt_nl
local control_lr temp_lr_dt temp_lr_dt wb_lr_dt wb_lr_dt 
local control_lr_nl i.temp_lr_dt_nl i.temp_lr_dt_nl i.wb_lr_dt_nl i.wb_lr_dt_nl
local weather_l1_var temp_fw_dt_l1 temp_fw_dt_l1 wb_fw_dt_l1 wb_fw_dt_l1 
local weather_f1_var temp_fw_dt_f1 temp_fw_dt_f1 wb_fw_dt_f1 wb_fw_dt_f1 

local other_weather prcp_fw
local control share_urban ln_pop percent_poor prcp_lr i.audit_time

fe_reg_series, outfile(_20200806_reg_br_word) outcome(`outcome') ctitle(`ctitle') ///
  weather_var(`weather_var') other_weather(`other_weather') fixed_effect(uf_code wave) ///
  control(`control') control_lr(`control_lr') vce(cluster municipality_ibge_code) ///
  addtext(State FE, Yes, Wave FE, Yes, Controls, Yes)
fe_reg_series_nl, outfile(_20200806_reg_br_word_nl) outcome(`outcome') ///
  ctitle(`ctitle') weather_var1(ib3.temp_fw_dt_nl) weather_var2(ib3.wb_fw_dt_nl) ///
  other_weather(`other_weather') fixed_effect(uf_code wave) control(`control') ///
  control_lr(`control_lr_nl') vce(cluster municipality_ibge_code) addtext(State FE, Yes, Wave FE, Yes, Controls, Yes)
fe_reg_series_pl, outfile(_20200806_reg_br_word_pl) outcome(`outcome') ///
  ctitle(`ctitle') weather_var(`weather_var') weather_l1_var(`weather_l1_var') ///
  weather_f1_var(`weather_f1_var') other_weather(`other_weather') fixed_effect(uf_code wave) ///
  control(`control') control_lr(`control_lr') vce(cluster municipality_ibge_code) ///
  addtext(State FE, Yes, Wave FE, Yes, Controls, Yes)

fe_reg_series, outfile(_20200806_reg_br_word_br) outcome(`outcome') ctitle(`ctitle') ///
  weather_var(`weather_var') other_weather(broad `other_weather') fixed_effect(uf_code wave) ///
  control(`control') control_lr(`control_lr') vce(cluster municipality_ibge_code) ///
  addtext(State FE, Yes, Wave FE, Yes, Controls, Yes)
fe_reg_series_nl, outfile(_20200806_reg_br_word_nl_br) outcome(`outcome') ///
  ctitle(`ctitle') weather_var1(ib3.temp_fw_dt_nl) weather_var2(ib3.wb_fw_dt_nl) ///
  other_weather(broad `other_weather') fixed_effect(uf_code wave) control(`control') ///
  control_lr(`control_lr_nl') vce(cluster municipality_ibge_code) addtext(State FE, Yes, Wave FE, Yes, Controls, Yes)
fe_reg_series_pl, outfile(_20200806_reg_br_word_pl_br) outcome(`outcome') ///
  ctitle(`ctitle') weather_var(`weather_var') weather_l1_var(`weather_l1_var') ///
  weather_f1_var(`weather_f1_var') other_weather(broad `other_weather') ///
  fixed_effect(uf_code wave) control(`control') control_lr(`control_lr') ///
  vce(cluster municipality_ibge_code) addtext(State FE, Yes, Wave FE, Yes, Controls, Yes)

fe_reg_series, outfile(_20200806_reg_br_word_na) outcome(`outcome') ctitle(`ctitle') ///
  weather_var(`weather_var') other_weather(narrow `other_weather') fixed_effect(uf_code wave) ///
  control(`control') control_lr(`control_lr') vce(cluster municipality_ibge_code) ///
  addtext(State FE, Yes, Wave FE, Yes, Controls, Yes)
fe_reg_series_nl, outfile(_20200806_reg_br_word_nl_na) outcome(`outcome') ///
  ctitle(`ctitle') weather_var1(ib3.temp_fw_dt_nl) weather_var2(ib3.wb_fw_dt_nl) ///
  other_weather(narrow `other_weather') fixed_effect(uf_code wave) control(`control') ///
  control_lr(`control_lr_nl') vce(cluster municipality_ibge_code) addtext(State FE, Yes, Wave FE, Yes, Controls, Yes)
fe_reg_series_pl, outfile(_20200806_reg_br_word_pl_na) outcome(`outcome') ///
  ctitle(`ctitle') weather_var(`weather_var') weather_l1_var(`weather_l1_var') ///
  weather_f1_var(`weather_f1_var') other_weather(narrow `other_weather') ///
  fixed_effect(uf_code wave) control(`control') control_lr(`control_lr') ///
  vce(cluster municipality_ibge_code) addtext(State FE, Yes, Wave FE, Yes, Controls, Yes)

eststo broad_1: qui estpost summarize num_token if broad == 1
eststo broad_0: qui estpost summarize num_token if broad == 0
eststo broad_diff: qui estpost ttest num_token, by(broad_reverse)
esttab broad_1 broad_0 broad_diff using "../../../Outputs/tex/word_broad.tex", ///
  cells("mean(pattern(1 1 0) fmt(2)) sd(pattern(1 1 0)) b(star pattern(0 0 1) fmt(2)) se(pattern(0 0 1) par fmt(2))") ///
  label replace  mlabels("Broad = 1" "Broad = 0" "Difference ((1) - (2))", span prefix(\multicolumn {@span} {c} {) suffix(}))

eststo narrow_1: qui estpost summarize num_token if narrow == 1
eststo narrow_0: qui estpost summarize num_token if narrow == 0
eststo narrow_diff: qui estpost ttest num_token, by(narrow_reverse)
esttab narrow_1 narrow_0 narrow_diff using "../../../Outputs/tex/word_narrow.tex", ///
  cells("mean(pattern(1 1 0) fmt(2)) sd(pattern(1 1 0)) b(star pattern(0 0 1) fmt(2)) se(pattern(0 0 1) par fmt(2))") ///
  label replace  mlabels("Narrow = 1" "Narrow = 0" "Difference ((1) - (2))", span prefix(\multicolumn {@span} {c} {) suffix(}))

* Regression with share of subjective words as outcome -----
* Define local variable lists
local outcome ratio_str_sub ratio_sub ratio_str_sub ratio_sub
local ctitle `" "Strong Subj." "Subj." "Strong Subj." "Subj." "'
local weather_var temp_fw_dt temp_fw_dt wb_fw_dt wb_fw_dt 
local weather_nl_var ib3.temp_fw_dt_nl ib3.temp_fw_dt_nl ib3.wb_fw_dt_nl ///
  ib3.wb_fw_dt_nl
local control_lr temp_lr_dt temp_lr_dt wb_lr_dt wb_lr_dt 
local control_lr_nl i.temp_lr_dt_nl i.temp_lr_dt_nl i.wb_lr_dt_nl i.wb_lr_dt_nl
local weather_l1_var temp_fw_dt_l1 temp_fw_dt_l1 wb_fw_dt_l1 wb_fw_dt_l1 
local weather_f1_var temp_fw_dt_f1 temp_fw_dt_f1 wb_fw_dt_f1 wb_fw_dt_f1 

local other_weather prcp_fw
local control share_urban ln_pop percent_poor prcp_lr i.audit_time

fe_reg_series, outfile(_20200806_reg_br_sub) outcome(`outcome') ctitle(`ctitle') ///
  weather_var(`weather_var') other_weather(`other_weather') fixed_effect(uf_code wave) ///
  control(`control') control_lr(`control_lr') vce(cluster municipality_ibge_code) ///
  addtext(State FE, Yes, Wave FE, Yes, Controls, Yes)
fe_reg_series_nl, outfile(_20200806_reg_br_sub_nl) outcome(`outcome') ctitle(`ctitle') ///
  weather_var1(ib3.temp_fw_dt_nl) weather_var2(ib3.wb_fw_dt_nl) other_weather(`other_weather') ///
  fixed_effect(uf_code wave) control(`control') control_lr(`control_lr_nl') ///
  vce(cluster municipality_ibge_code) addtext(State FE, Yes, Wave FE, Yes, Controls, Yes)
fe_reg_series_pl, outfile(_20200806_reg_br_sub_pl) outcome(`outcome') ctitle(`ctitle') ///
  weather_var(`weather_var') weather_l1_var(`weather_l1_var') weather_f1_var(`weather_f1_var') ///
  other_weather(`other_weather') fixed_effect(uf_code wave) control(`control') ///
  control_lr(`control_lr') vce(cluster municipality_ibge_code) addtext(State FE, Yes, Wave FE, Yes, Controls, Yes)

fe_reg_series, outfile(_20200806_reg_br_sub_br) outcome(`outcome') ctitle(`ctitle') ///
  weather_var(`weather_var') other_weather(broad `other_weather') fixed_effect(uf_code wave) ///
  control(`control') control_lr(`control_lr') vce(cluster municipality_ibge_code) ///
  addtext(State FE, Yes, Wave FE, Yes, Controls, Yes)
fe_reg_series_nl, outfile(_20200806_reg_br_sub_nl_br) outcome(`outcome') ///
  ctitle(`ctitle') weather_var1(ib3.temp_fw_dt_nl) weather_var2(ib3.wb_fw_dt_nl) ///
  other_weather(broad `other_weather') fixed_effect(uf_code wave) control(`control') ///
  control_lr(`control_lr_nl') vce(cluster municipality_ibge_code) addtext(State FE, Yes, Wave FE, Yes, Controls, Yes)
fe_reg_series_pl, outfile(_20200806_reg_br_sub_pl_br) outcome(`outcome') ///
  ctitle(`ctitle') weather_var(`weather_var') weather_l1_var(`weather_l1_var') ///
  weather_f1_var(`weather_f1_var') other_weather(broad `other_weather') ///
  fixed_effect(uf_code wave) control(`control') control_lr(`control_lr') ///
  vce(cluster municipality_ibge_code) addtext(State FE, Yes, Wave FE, Yes, Controls, Yes)

fe_reg_series, outfile(_20200806_reg_br_sub_na) outcome(`outcome') ctitle(`ctitle') ///
  weather_var(`weather_var') other_weather(narrow `other_weather') fixed_effect(uf_code wave) ///
  control(`control') control_lr(`control_lr') vce(cluster municipality_ibge_code) ///
  addtext(State FE, Yes, Wave FE, Yes, Controls, Yes)
fe_reg_series_nl, outfile(_20200806_reg_br_sub_nl_na) outcome(`outcome') ///
  ctitle(`ctitle') weather_var1(ib3.temp_fw_dt_nl) weather_var2(ib3.wb_fw_dt_nl) ///
  other_weather(narrow `other_weather') fixed_effect(uf_code wave) control(`control') ///
  control_lr(`control_lr_nl') vce(cluster municipality_ibge_code) addtext(State FE, Yes, Wave FE, Yes, Controls, Yes)
fe_reg_series_pl, outfile(_20200806_reg_br_sub_pl_na) outcome(`outcome') ///
  ctitle(`ctitle') weather_var(`weather_var') weather_l1_var(`weather_l1_var') ///
  weather_f1_var(`weather_f1_var') other_weather(narrow `other_weather') ///
  fixed_effect(uf_code wave) control(`control') control_lr(`control_lr') ///
  vce(cluster municipality_ibge_code) addtext(State FE, Yes, Wave FE, Yes, Controls, Yes)

eststo broad_1: qui estpost summarize ratio_str_sub if broad == 1
eststo broad_0: qui estpost summarize ratio_str_sub if broad == 0
eststo broad_diff: qui estpost ttest ratio_str_sub, by(broad_reverse)
esttab broad_1 broad_0 broad_diff using "../../../Outputs/tex/str_sub_broad.tex", ///
  cells("mean(pattern(1 1 0) fmt(2)) sd(pattern(1 1 0)) b(star pattern(0 0 1) fmt(2)) se(pattern(0 0 1) par fmt(2))") ///
  label replace  mlabels("Broad = 1" "Broad = 0" "Difference ((1) - (2))", span prefix(\multicolumn {@span} {c} {) suffix(}))

eststo broad_1: qui estpost summarize ratio_weak_sub if broad == 1
eststo broad_0: qui estpost summarize ratio_weak_sub if broad == 0
eststo broad_diff: qui estpost ttest ratio_weak_sub, by(broad_reverse)
esttab broad_1 broad_0 broad_diff using "../../../Outputs/tex/weak_sub_broad.tex", ///
  cells("mean(pattern(1 1 0) fmt(2)) sd(pattern(1 1 0)) b(star pattern(0 0 1) fmt(2)) se(pattern(0 0 1) par fmt(2))") ///
  label replace  mlabels("Broad = 1" "Broad = 0" "Difference ((1) - (2))", span prefix(\multicolumn {@span} {c} {) suffix(}))

eststo broad_1: qui estpost summarize ratio_sub if broad == 1
eststo broad_0: qui estpost summarize ratio_sub if broad == 0
eststo broad_diff: qui estpost ttest ratio_sub, by(broad_reverse)
esttab broad_1 broad_0 broad_diff using "../../../Outputs/tex/sub_broad.tex", ///
  cells("mean(pattern(1 1 0) fmt(2)) sd(pattern(1 1 0)) b(star pattern(0 0 1) fmt(2)) se(pattern(0 0 1) par fmt(2))") ///
  label replace  mlabels("Broad = 1" "Broad = 0" "Difference ((1) - (2))", span prefix(\multicolumn {@span} {c} {) suffix(}))

eststo narrow_1: qui estpost summarize ratio_str_sub if narrow == 1
eststo narrow_0: qui estpost summarize ratio_str_sub if narrow == 0
eststo narrow_diff: qui estpost ttest ratio_str_sub, by(narrow_reverse)
esttab narrow_1 narrow_0 narrow_diff using "../../../Outputs/tex/str_sub_narrow.tex", ///
  cells("mean(pattern(1 1 0) fmt(2)) sd(pattern(1 1 0)) b(star pattern(0 0 1) fmt(2)) se(pattern(0 0 1) par fmt(2))") ///
  label replace  mlabels("Narrow = 1" "Narrow = 0" "Difference ((1) - (2))", span prefix(\multicolumn {@span} {c} {) suffix(}))

eststo narrow_1: qui estpost summarize ratio_weak_sub if narrow == 1
eststo narrow_0: qui estpost summarize ratio_weak_sub if narrow == 0
eststo narrow_diff: qui estpost ttest ratio_weak_sub, by(narrow_reverse)
esttab narrow_1 narrow_0 narrow_diff using "../../../Outputs/tex/weak_sub_narrow.tex", ///
  cells("mean(pattern(1 1 0) fmt(2)) sd(pattern(1 1 0)) b(star pattern(0 0 1) fmt(2)) se(pattern(0 0 1) par fmt(2))") ///
  label replace  mlabels("Narrow = 1" "Narrow = 0" "Difference ((1) - (2))", span prefix(\multicolumn {@span} {c} {) suffix(}))

eststo narrow_1: qui estpost summarize ratio_sub if narrow == 1
eststo narrow_0: qui estpost summarize ratio_sub if narrow == 0
eststo narrow_diff: qui estpost ttest ratio_sub, by(narrow_reverse)
esttab narrow_1 narrow_0 narrow_diff using "../../../Outputs/tex/sub_narrow.tex", ///
  cells("mean(pattern(1 1 0) fmt(2)) sd(pattern(1 1 0)) b(star pattern(0 0 1) fmt(2)) se(pattern(0 0 1) par fmt(2))") ///
  label replace  mlabels("Narrow = 1" "Narrow = 0" "Difference ((1) - (2))", span prefix(\multicolumn {@span} {c} {) suffix(}))

* Regression with share of negative and positive words as outcome -----
* Define local variable lists
local outcome ratio_pos ratio_neg ratio_pos ratio_neg
local ctitle `" "Positive" "Negative" "Positive" "Negative" "'
local weather_var temp_fw_dt temp_fw_dt wb_fw_dt wb_fw_dt 
local weather_nl_var ib3.temp_fw_dt_nl ib3.temp_fw_dt_nl ib3.wb_fw_dt_nl ///
  ib3.wb_fw_dt_nl
local control_lr temp_lr_dt temp_lr_dt wb_lr_dt wb_lr_dt 
local control_lr_nl i.temp_lr_dt_nl i.temp_lr_dt_nl i.wb_lr_dt_nl i.wb_lr_dt_nl
local weather_l1_var temp_fw_dt_l1 temp_fw_dt_l1 wb_fw_dt_l1 wb_fw_dt_l1 
local weather_f1_var temp_fw_dt_f1 temp_fw_dt_f1 wb_fw_dt_f1 wb_fw_dt_f1 

local other_weather prcp_fw
local control share_urban ln_pop percent_poor prcp_lr i.audit_time

fe_reg_series, outfile(_20200806_reg_br_pn) outcome(`outcome') ctitle(`ctitle') ///
  weather_var(`weather_var') other_weather(`other_weather') fixed_effect(uf_code wave) ///
  control(`control') control_lr(`control_lr') vce(cluster municipality_ibge_code) ///
  addtext(State FE, Yes, Wave FE, Yes, Controls, Yes)
fe_reg_series_nl, outfile(_20200806_reg_br_pn_nl) outcome(`outcome') ctitle(`ctitle') ///
  weather_var1(ib3.temp_fw_dt_nl) weather_var2(ib3.wb_fw_dt_nl) other_weather(`other_weather') ///
  fixed_effect(uf_code wave) control(`control') control_lr(`control_lr_nl') ///
  vce(cluster municipality_ibge_code) addtext(State FE, Yes, Wave FE, Yes, Controls, Yes)
fe_reg_series_pl, outfile(_20200806_reg_br_pn_pl) outcome(`outcome') ctitle(`ctitle') ///
  weather_var(`weather_var') weather_l1_var(`weather_l1_var') weather_f1_var(`weather_f1_var') ///
  other_weather(`other_weather') fixed_effect(uf_code wave) control(`control') ///
  control_lr(`control_lr') vce(cluster municipality_ibge_code) addtext(State FE, Yes, Wave FE, Yes, Controls, Yes)

fe_reg_series, outfile(_20200806_reg_br_pn_br) outcome(`outcome') ctitle(`ctitle') ///
  weather_var(`weather_var') other_weather(broad `other_weather') fixed_effect(uf_code wave) ///
  control(`control') control_lr(`control_lr') vce(cluster municipality_ibge_code) ///
  addtext(State FE, Yes, Wave FE, Yes, Controls, Yes)
fe_reg_series_nl, outfile(_20200806_reg_br_pn_nl_br) outcome(`outcome') ///
  ctitle(`ctitle') weather_var1(ib3.temp_fw_dt_nl) weather_var2(ib3.wb_fw_dt_nl) ///
  other_weather(broad `other_weather') fixed_effect(uf_code wave) control(`control') ///
  control_lr(`control_lr_nl') vce(cluster municipality_ibge_code) addtext(State FE, Yes, Wave FE, Yes, Controls, Yes)
fe_reg_series_pl, outfile(_20200806_reg_br_pn_pl_br) outcome(`outcome') ///
  ctitle(`ctitle') weather_var(`weather_var') weather_l1_var(`weather_l1_var') ///
  weather_f1_var(`weather_f1_var') other_weather(broad `other_weather') ///
  fixed_effect(uf_code wave) control(`control') control_lr(`control_lr') ///
  vce(cluster municipality_ibge_code) addtext(State FE, Yes, Wave FE, Yes, Controls, Yes)

fe_reg_series, outfile(_20200806_reg_br_pn_na) outcome(`outcome') ctitle(`ctitle') ///
  weather_var(`weather_var') other_weather(narrow `other_weather') fixed_effect(uf_code wave) ///
  control(`control') control_lr(`control_lr') vce(cluster municipality_ibge_code) ///
  addtext(State FE, Yes, Wave FE, Yes, Controls, Yes)
fe_reg_series_nl, outfile(_20200806_reg_br_pn_nl_na) outcome(`outcome') ///
  ctitle(`ctitle') weather_var1(ib3.temp_fw_dt_nl) weather_var2(ib3.wb_fw_dt_nl) ///
  other_weather(narrow `other_weather') fixed_effect(uf_code wave) control(`control') ///
  control_lr(`control_lr_nl') vce(cluster municipality_ibge_code) addtext(State FE, Yes, Wave FE, Yes, Controls, Yes)
fe_reg_series_pl, outfile(_20200806_reg_br_pn_pl_na) outcome(`outcome') ///
  ctitle(`ctitle') weather_var(`weather_var') weather_l1_var(`weather_l1_var') ///
  weather_f1_var(`weather_f1_var') other_weather(narrow `other_weather') ///
  fixed_effect(uf_code wave) control(`control') control_lr(`control_lr') ///
  vce(cluster municipality_ibge_code) addtext(State FE, Yes, Wave FE, Yes, Controls, Yes)

eststo broad_1: qui estpost summarize ratio_pos if broad == 1
eststo broad_0: qui estpost summarize ratio_pos if broad == 0
eststo broad_diff: qui estpost ttest ratio_pos, by(broad_reverse)
esttab broad_1 broad_0 broad_diff using "../../../Outputs/tex/pos_broad.tex", ///
  cells("mean(pattern(1 1 0) fmt(2)) sd(pattern(1 1 0)) b(star pattern(0 0 1) fmt(2)) se(pattern(0 0 1) par fmt(2))") ///
  label replace  mlabels("Broad = 1" "Broad = 0" "Difference ((1) - (2))", span prefix(\multicolumn {@span} {c} {) suffix(}))

eststo broad_1: qui estpost summarize ratio_neg if broad == 1
eststo broad_0: qui estpost summarize ratio_neg if broad == 0
eststo broad_diff: qui estpost ttest ratio_neg, by(broad_reverse)
esttab broad_1 broad_0 broad_diff using "../../../Outputs/tex/neg_broad.tex", ///
  cells("mean(pattern(1 1 0) fmt(2)) sd(pattern(1 1 0)) b(star pattern(0 0 1) fmt(2)) se(pattern(0 0 1) par fmt(2))") ///
  label replace  mlabels("Broad = 1" "Broad = 0" "Difference ((1) - (2))", span prefix(\multicolumn {@span} {c} {) suffix(}))

eststo narrow_1: qui estpost summarize ratio_pos if narrow == 1
eststo narrow_0: qui estpost summarize ratio_pos if narrow == 0
eststo narrow_diff: qui estpost ttest ratio_pos, by(narrow_reverse)
esttab narrow_1 narrow_0 narrow_diff using "../../../Outputs/tex/pos_narrow.tex", ///
  cells("mean(pattern(1 1 0) fmt(2)) sd(pattern(1 1 0)) b(star pattern(0 0 1) fmt(2)) se(pattern(0 0 1) par fmt(2))") ///
  label replace  mlabels("Narrow = 1" "Narrow = 0" "Difference ((1) - (2))", span prefix(\multicolumn {@span} {c} {) suffix(}))

eststo narrow_1: qui estpost summarize ratio_neg if narrow == 1
eststo narrow_0: qui estpost summarize ratio_neg if narrow == 0
eststo narrow_diff: qui estpost ttest ratio_neg, by(narrow_reverse)
esttab narrow_1 narrow_0 narrow_diff using "../../../Outputs/tex/neg_narrow.tex", ///
  cells("mean(pattern(1 1 0) fmt(2)) sd(pattern(1 1 0)) b(star pattern(0 0 1) fmt(2)) se(pattern(0 0 1) par fmt(2))") ///
  label replace  mlabels("Narrow = 1" "Narrow = 0" "Difference ((1) - (2))", span prefix(\multicolumn {@span} {c} {) suffix(}))

exit

* Brollo data (non-collapsed) ==================
use $data/main_data_br_nocol.dta, clear

gen after_election = (wave >= 10)
egen temp_fw_dt_nl = cut(temp_fw_dt), ///
  at(0, 20, 22, 24, 26, 28, 30, 32, 40) icodes label
egen wb_fw_dt_nl = cut(wb_fw_dt), ///
  at(0, 18, 20, 22, 24, 26, 28, 40) icodes label
egen temp_lr_dt_nl = cut(temp_lr_dt), ///
  at(0, 20, 22, 24, 26, 28, 30, 32, 40) icodes label
egen wb_lr_dt_nl = cut(wb_lr_dt), ///
  at(0, 18, 20, 22, 24, 26, 28, 40) icodes label

egen temp_group = group(municipality_ibge_code wave)
bysort municipality_ibge_code: egen temp_group_max = max(temp_group)
bysort municipality_ibge_code: egen temp_group_min = min(temp_group)
gen audit_second_time = (temp_group_max != temp_group_min)

* Define local variable lists
local outcome broad narrow broad narrow fraction_broad fraction_narrow ///
  fraction_broad fraction_narrow
local ctitle `" "Broad" "Narrow" "Broad" "Narrow" "Broad ($%$)" "Narrow ///
  ($%$)" "Broad ($%$)" "Narrow ($%$)" "'
local weather_var temp_fw_dt temp_fw_dt wb_fw_dt wb_fw_dt temp_fw_dt temp_fw_dt ///
  wb_fw_dt wb_fw_dt
local weather_nl_var ib3.temp_fw_dt_nl ib3.temp_fw_dt_nl ib3.wb_fw_dt_nl ///
  ib3.wb_fw_dt_nl ib3.temp_fw_dt_nl ib3.temp_fw_dt_nl ib3.wb_fw_dt_nl ib3.wb_fw_dt_nl
local control_lr temp_lr_dt temp_lr_dt wb_lr_dt wb_lr_dt temp_lr_dt temp_lr_dt ///
  wb_lr_dt wb_lr_dt
local control_lr_nl i.temp_lr_dt_nl i.temp_lr_dt_nl i.wb_lr_dt_nl i.wb_lr_dt_nl
local weather_l1_var temp_fw_dt_l1 temp_fw_dt_l1 wb_fw_dt_l1 wb_fw_dt_l1 ///
  temp_fw_dt_l1 temp_fw_dt_l1 wb_fw_dt_l1 wb_fw_dt_l1
local weather_f1_var temp_fw_dt_f1 temp_fw_dt_f1 wb_fw_dt_f1 wb_fw_dt_f1 ///
  temp_fw_dt_f1 temp_fw_dt_f1 wb_fw_dt_f1 wb_fw_dt_f1

local other_weather prcp_fw
local control share_urban ln_pop percent_poor prcp_lr audit_second_time

fe_reg_series, outfile(_20200806_reg_br_nocol) outcome(`outcome') ctitle(`ctitle') ///
  weather_var(`weather_var') other_weather(`other_weather') fixed_effect(uf_code wave term) ///
  control(`control') control_lr(`control_lr') vce(cluster municipality_ibge_code) ///
  addtext(State FE, Yes, Wave FE, Yes, Term FE, Yes, Controls, Yes)
fe_reg_series_nl, outfile(_20200806_reg_br_nocol_nl) outcome(`outcome') ///
  ctitle(`ctitle') weather_var1(ib3.temp_fw_dt_nl) weather_var2(ib3.wb_fw_dt_nl) ///
  other_weather(`other_weather') fixed_effect(uf_code wave term) control(`control') ///
  control_lr(`control_lr_nl') vce(cluster municipality_ibge_code) addtext(State FE, Yes, Wave FE, Yes, Term FE, Yes, Controls, Yes)
fe_reg_series_pl, outfile(_20200806_reg_br_nocol_pl) outcome(`outcome') ///
  ctitle(`ctitle') weather_var(`weather_var') weather_l1_var(`weather_l1_var') ///
  weather_f1_var(`weather_f1_var') other_weather(`other_weather') fixed_effect(uf_code wave term) ///
  control(`control') control_lr(`control_lr') vce(cluster municipality_ibge_code) ///
  addtext(State FE, Yes, Wave FE, Yes, Term FE, Yes, Controls, Yes)

* FF data ==================
use $data/main_data_ff.dta, clear

gen after_election = (wave >= 10)
egen temp_fw_dt_nl = cut(temp_fw_dt), ///
  at(0, 20, 22, 24, 26, 28, 30, 32, 40) icodes label
egen wb_fw_dt_nl = cut(wb_fw_dt), ///
  at(0, 18, 20, 22, 24, 26, 28, 40) icodes label
egen temp_lr_dt_nl = cut(temp_lr_dt), ///
  at(0, 20, 22, 24, 26, 28, 30, 32, 40) icodes label
egen wb_lr_dt_nl = cut(wb_lr_dt), ///
  at(0, 18, 20, 22, 24, 26, 28, 40) icodes label
gen any_corrupt = (ncorrupt > 0)

* Define local variable lists
local outcome ncorrupt any_corrupt ncorrupt any_corrupt
local ctitle `" "Number" "Any" "Number" "Any" "'
local weather_var temp_fw_dt temp_fw_dt wb_fw_dt wb_fw_dt
local weather_nl_var ib3.temp_fw_dt_nl ib3.temp_fw_dt_nl ib3.wb_fw_dt_nl ///
  ib3.wb_fw_dt_nl
local control_lr temp_lr_dt temp_lr_dt wb_lr_dt wb_lr_dt
local control_lr_nl i.temp_lr_dt_nl i.temp_lr_dt_nl i.wb_lr_dt_nl i.wb_lr_dt_nl
local weather_l1_var temp_fw_dt_l1 temp_fw_dt_l1 wb_fw_dt_l1 wb_fw_dt_l1
local weather_f1_var temp_fw_dt_f1 temp_fw_dt_f1 wb_fw_dt_f1 wb_fw_dt_f1

local other_weather prcp_fw
local control share_urban ln_pop percent_poor prcp_lr

fe_reg_series, outfile(_20200806_reg_ff) outcome(`outcome') ctitle(`ctitle') ///
  weather_var(`weather_var') other_weather(`other_weather') fixed_effect(uf_code wave) ///
  control(`control') control_lr(`control_lr') vce(robust) addtext(State FE, Yes, Wave FE, Yes, Controls, Yes)
fe_reg_series_nl, outfile(_20200806_reg_ff_nl) outcome(`outcome') ctitle(`ctitle') ///
  weather_var1(ib3.temp_fw_dt_nl) weather_var2(ib3.wb_fw_dt_nl) other_weather(`other_weather') ///
  fixed_effect(uf_code wave) control(`control') control_lr(`control_lr_nl') ///
  vce(robust) addtext(State FE, Yes, Wave FE, Yes, Controls, Yes)
fe_reg_series_pl, outfile(_20200806_reg_ff_pl) outcome(`outcome') ctitle(`ctitle') ///
  weather_var(`weather_var') weather_l1_var(`weather_l1_var') weather_f1_var(`weather_f1_var') ///
  other_weather(`other_weather') fixed_effect(uf_code wave) control(`control') ///
  control_lr(`control_lr') vce(robust) addtext(State FE, Yes, Wave FE, Yes, Controls, Yes)

exit

reghdfe pos_image ib3.wb_fw_dt_nl i.wb_lr_dt_nl prcp_fw share_urban ln_pop ///
  percent_poor prcp_lr i.audit_time, ///
  a(uf_code wave) vce(cluster municipality_ibge_code)
reghdfe log_image ib3.wb_fw_dt_nl i.wb_lr_dt_nl prcp_fw share_urban ln_pop ///
  percent_poor prcp_lr i.audit_time, ///
  a(uf_code wave) vce(cluster municipality_ibge_code)

reghdfe pos_image ib3.temp_fw_dt_nl i.temp_lr_dt_nl prcp_fw share_urban ///
  ln_pop percent_poor prcp_lr i.audit_time, ///
  a(uf_code wave) vce(cluster municipality_ibge_code)
reghdfe log_image ib3.temp_fw_dt_nl i.temp_lr_dt_nl prcp_fw share_urban ///
  ln_pop percent_poor prcp_lr i.audit_time, ///
  a(uf_code wave) vce(cluster municipality_ibge_code)

gen num_pol_token = pol_pos + pol_neu + pol_neg
gen ratio_pos = pol_pos / num_token
gen ratio_neu = pol_neu / num_token
gen ratio_neg = pol_neg / num_token

reghdfe pol_pos num_token ib3.wb_fw_dt_nl i.wb_lr_dt_nl prcp_fw share_urban ///
  ln_pop percent_poor prcp_lr i.audit_time, ///
  a(uf_code wave) vce(cluster municipality_ibge_code)
reghdfe pol_neu num_token ib3.wb_fw_dt_nl i.wb_lr_dt_nl prcp_fw share_urban ///
  ln_pop percent_poor prcp_lr i.audit_time, ///
  a(uf_code wave) vce(cluster municipality_ibge_code)
reghdfe pol_neg num_token ib3.wb_fw_dt_nl i.wb_lr_dt_nl prcp_fw share_urban ///
  ln_pop percent_poor prcp_lr i.audit_time, ///
  a(uf_code wave) vce(cluster municipality_ibge_code)

reghdfe pol_pos num_pol_token ib3.wb_fw_dt_nl i.wb_lr_dt_nl prcp_fw share_urban ///
  ln_pop percent_poor prcp_lr i.audit_time, ///
  a(uf_code wave) vce(cluster municipality_ibge_code)
reghdfe pol_neu num_pol_token ib3.wb_fw_dt_nl i.wb_lr_dt_nl prcp_fw share_urban ///
  ln_pop percent_poor prcp_lr i.audit_time, ///
  a(uf_code wave) vce(cluster municipality_ibge_code)
reghdfe pol_neg num_pol_token ib3.wb_fw_dt_nl i.wb_lr_dt_nl prcp_fw share_urban ///
  ln_pop percent_poor prcp_lr i.audit_time, ///
  a(uf_code wave) vce(cluster municipality_ibge_code)

reghdfe ratio_pos ib3.wb_fw_dt_nl i.wb_lr_dt_nl prcp_fw share_urban ln_pop ///
  percent_poor prcp_lr i.audit_time, ///
  a(uf_code wave) vce(cluster municipality_ibge_code)
reghdfe ratio_neu ib3.wb_fw_dt_nl i.wb_lr_dt_nl prcp_fw share_urban ln_pop ///
  percent_poor prcp_lr i.audit_time, ///
  a(uf_code wave) vce(cluster municipality_ibge_code)
reghdfe ratio_neg ib3.wb_fw_dt_nl i.wb_lr_dt_nl prcp_fw share_urban ln_pop ///
  percent_poor prcp_lr i.audit_time, ///
  a(uf_code wave) vce(cluster municipality_ibge_code)

gen log_pol_pos = log(pol_pos)
gen log_pol_neu = log(pol_neu)
gen log_pol_neg = log(pol_neg)
gen log_num_pol_token = log(num_pol_token)
gen log_num_token = log(num_token)

reghdfe log_pol_pos log_num_token ib3.wb_fw_dt_nl i.wb_lr_dt_nl prcp_fw ///
  share_urban ln_pop percent_poor prcp_lr i.audit_time, ///
  a(uf_code wave) vce(cluster municipality_ibge_code)
reghdfe log_pol_neu log_num_token ib3.wb_fw_dt_nl i.wb_lr_dt_nl prcp_fw ///
  share_urban ln_pop percent_poor prcp_lr i.audit_time, ///
  a(uf_code wave) vce(cluster municipality_ibge_code)
reghdfe log_pol_neg log_num_token ib3.wb_fw_dt_nl i.wb_lr_dt_nl prcp_fw ///
  share_urban ln_pop percent_poor prcp_lr i.audit_time, ///
  a(uf_code wave) vce(cluster municipality_ibge_code)

reghdfe log_pol_pos log_num_pol_token ib3.wb_fw_dt_nl i.wb_lr_dt_nl prcp_fw ///
  share_urban ln_pop percent_poor prcp_lr i.audit_time, ///
  a(uf_code wave) vce(cluster municipality_ibge_code)
reghdfe log_pol_neu log_num_pol_token ib3.wb_fw_dt_nl i.wb_lr_dt_nl prcp_fw ///
  share_urban ln_pop percent_poor prcp_lr i.audit_time, ///
  a(uf_code wave) vce(cluster municipality_ibge_code)
reghdfe log_pol_neg log_num_pol_token ib3.wb_fw_dt_nl i.wb_lr_dt_nl prcp_fw ///
  share_urban ln_pop percent_poor prcp_lr i.audit_time, ///
  a(uf_code wave) vce(cluster municipality_ibge_code)

gen score_pol = (pol_pos - pol_neg)
gen mean_pol = (pol_pos - pol_neg) / (pol_pos + pol_neg)
gen mean_pol2 = (pol_pos - pol_neg) / (pol_pos + pol_neg + pol_neu)
gen mean_pol3 = (pol_pos - pol_neg) / num_token

reghdfe score_pol broad ib3.wb_fw_dt_nl i.wb_lr_dt_nl prcp_fw share_urban ///
  ln_pop percent_poor prcp_lr i.audit_time, ///
  a(uf_code wave) vce(cluster municipality_ibge_code)
reghdfe mean_pol ib3.wb_fw_dt_nl i.wb_lr_dt_nl prcp_fw share_urban ln_pop ///
  percent_poor prcp_lr i.audit_time, ///
  a(uf_code wave) vce(cluster municipality_ibge_code)
reghdfe mean_pol2 ib3.wb_fw_dt_nl i.wb_lr_dt_nl prcp_fw share_urban ln_pop ///
  percent_poor prcp_lr i.audit_time, ///
  a(uf_code wave) vce(cluster municipality_ibge_code)

gen total_pol = pol_pos + pol_neg
gen ratio_pol = total_pol / num_token
gen log_total_pol = log(total_pol)

reghdfe total_pol ib3.wb_fw_dt_nl i.wb_lr_dt_nl prcp_fw share_urban ln_pop ///
  percent_poor prcp_lr i.audit_time, ///
  a(uf_code wave) vce(cluster municipality_ibge_code)
reghdfe ratio_pol ib3.wb_fw_dt_nl i.wb_lr_dt_nl prcp_fw share_urban ln_pop ///
  percent_poor prcp_lr i.audit_time, ///
  a(uf_code wave) vce(cluster municipality_ibge_code)
reghdfe log_total_pol ib3.wb_fw_dt_nl i.wb_lr_dt_nl prcp_fw share_urban ///
  ln_pop percent_poor prcp_lr i.audit_time, ///
  a(uf_code wave) vce(cluster municipality_ibge_code)

reghdfe ratio_pos ib3.wb_fw_dt_nl i.wb_lr_dt_nl prcp_fw share_urban ln_pop ///
  percent_poor prcp_lr i.audit_time, ///
  a(uf_code wave) vce(cluster municipality_ibge_code)
reghdfe ratio_neg ib3.wb_fw_dt_nl i.wb_lr_dt_nl prcp_fw share_urban ln_pop ///
  percent_poor prcp_lr i.audit_time, ///
  a(uf_code wave) vce(cluster municipality_ibge_code)

reghdfe log_pol_pos log_num_token ib3.wb_fw_dt_nl i.wb_lr_dt_nl prcp_fw ///
  share_urban ln_pop percent_poor prcp_lr i.audit_time, ///
  a(uf_code wave) vce(cluster municipality_ibge_code)
reghdfe log_pol_neg log_num_token ib3.wb_fw_dt_nl i.wb_lr_dt_nl prcp_fw ///
  share_urban ln_pop percent_poor prcp_lr i.audit_time, ///
  a(uf_code wave) vce(cluster municipality_ibge_code)

reghdfe log_num_token ib3.wb_fw_dt_nl i.wb_lr_dt_nl prcp_fw share_urban ///
  ln_pop percent_poor prcp_lr i.audit_time, ///
  a(uf_code wave) vce(cluster municipality_ibge_code)
reghdfe log_num_pol_token ib3.wb_fw_dt_nl i.wb_lr_dt_nl prcp_fw share_urban ///
  ln_pop percent_poor prcp_lr i.audit_time, ///
  a(uf_code wave) vce(cluster municipality_ibge_code)

gen ratio_str_sub = pol_str_sub_pri / num_token
gen ratio_weak_sub = pol_weak_sub_pri / num_token
gen ratio_sub = (pol_str_sub_pri + pol_weak_sub_pri) / num_token

gen ratio_pos_sub = pol_pos_pri / num_token
gen ratio_neg_sub = pol_neg_pri / num_token
gen ratio_pos_neg_sub = (pol_pos_pri - pol_neg_pri) / num_token

gen log_str_sub = log(pol_str_sub_pri)
gen log_weak_sub = log(pol_weak_sub_pri)
gen log_sub = log(pol_str_sub_pri + pol_weak_sub_pri)

reghdfe ratio_str_sub ib3.wb_fw_dt_nl i.wb_lr_dt_nl prcp_fw share_urban ///
  ln_pop percent_poor prcp_lr i.audit_time, ///
  a(uf_code wave) vce(cluster municipality_ibge_code)
reghdfe ratio_weak_sub ib3.wb_fw_dt_nl i.wb_lr_dt_nl prcp_fw share_urban ///
  ln_pop percent_poor prcp_lr i.audit_time, ///
  a(uf_code wave) vce(cluster municipality_ibge_code)
reghdfe ratio_sub ib3.wb_fw_dt_nl i.wb_lr_dt_nl prcp_fw share_urban ln_pop ///
  percent_poor prcp_lr i.audit_time, ///
  a(uf_code wave) vce(cluster municipality_ibge_code)

reghdfe log_str_sub log_num_token ib3.wb_fw_dt_nl i.wb_lr_dt_nl prcp_fw ///
  share_urban ln_pop percent_poor prcp_lr i.audit_time, ///
  a(uf_code wave) vce(cluster municipality_ibge_code)
reghdfe log_weak_sub log_num_token ib3.wb_fw_dt_nl i.wb_lr_dt_nl prcp_fw ///
  share_urban ln_pop percent_poor prcp_lr i.audit_time, ///
  a(uf_code wave) vce(cluster municipality_ibge_code)
reghdfe log_sub log_num_token ib3.wb_fw_dt_nl i.wb_lr_dt_nl prcp_fw share_urban ///
  ln_pop percent_poor prcp_lr i.audit_time, ///
  a(uf_code wave) vce(cluster municipality_ibge_code)

reghdfe ratio_str_sub ib3.temp_fw_dt_nl i.temp_lr_dt_nl prcp_fw share_urban ///
  ln_pop percent_poor prcp_lr i.audit_time, ///
  a(uf_code wave) vce(cluster municipality_ibge_code)
reghdfe ratio_weak_sub ib3.temp_fw_dt_nl i.temp_lr_dt_nl prcp_fw share_urban ///
  ln_pop percent_poor prcp_lr i.audit_time, ///
  a(uf_code wave) vce(cluster municipality_ibge_code)
reghdfe ratio_sub ib3.temp_fw_dt_nl i.temp_lr_dt_nl prcp_fw share_urban ///
  ln_pop percent_poor prcp_lr i.audit_time, ///
  a(uf_code wave) vce(cluster municipality_ibge_code)

reghdfe ratio_pos_sub ib3.wb_fw_dt_nl i.wb_lr_dt_nl prcp_fw share_urban ///
  ln_pop percent_poor prcp_lr i.audit_time, ///
  a(uf_code wave) vce(cluster municipality_ibge_code)
reghdfe ratio_neg_sub ib3.wb_fw_dt_nl i.wb_lr_dt_nl prcp_fw share_urban ///
  ln_pop percent_poor prcp_lr i.audit_time, ///
  a(uf_code wave) vce(cluster municipality_ibge_code)
reghdfe ratio_pos_neg_sub ib3.wb_fw_dt_nl i.wb_lr_dt_nl prcp_fw share_urban ///
  ln_pop percent_poor prcp_lr i.audit_time, ///
  a(uf_code wave) vce(cluster municipality_ibge_code)

use $data/main_data_br_col.dta, clear
gen zero_image = (num_image == 0)

set seed 123
generate u = runiform()
sort u

bysort wave zero_image: keep if _n <= 2
order id num_image

