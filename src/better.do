****************************************
*Brazilian Audits Project

*DO FILE: Create figures and run regressions of corruption reports on climate
****************************************

*HIRO COMPUTER:
  global data "/Users/mizuhirosuzuki/Dropbox/Brazil_Audit/Data"
  global dofiles "/Users/mizuhirosuzuki/Dropbox/Brazil_Audit/Codes/Stata"
  
**ANA COMPUTER:
*  global data "/Users/anamelo/Dropbox/Brazil_Audit/Data"
*  global dofiles "/Users/anamelo/Dropbox/Brazil_Audit/Codes/Stata"
  
clear all

cd $data

* Create figures -----------------------------

* Ferraz and Finan --------------------

* Brollo (collapsed) -------------------

* Brollo (non-collapsed) -------------------

* Regression analysis -------------------------------
* define a program to run regression (on temperature and precipitation) and create a tex file
program define regress_basic
syntax, outfile(name) outcome(varname) temperature_list(varlist ts fv) ///
  precipitation_list(varlist ts fv) wb_list(varlist ts fv) control(varlist ts fv) ///
  ctitle(string) lr(string asis)
  qui: reg `outcome' `temperature_list' `precipitation_list' `control', robust
  qui: testparm `temperature_list'
  scalar temp1 = r(p)
  local temp1=scalar(temp1)
  qui: testparm `precipitation_list'
  scalar temp2 = r(p)
  local temp2=scalar(temp2)
  qui: sum `outcome' 
  scalar mean_outcome = r(mean)
  local mean_outcome=scalar(mean_outcome)
  outreg2 using "../Outputs/tex/`outfile'.tex", ///
    label tex(frag) keep(`temperature_list' `precipitation_list') sortvar(`temperature_list' `wb_list' `precipitation_list') ///
    adds(Mean of outcome, `mean_outcome', \$ p \$-value of \$ F \$-test (Temperature), `temp1', \$ p \$-value of \$ F \$-test (Precipitation), `temp2') ///
    addtext(LR Weather, `lr', State FE, Yes, Wave FE, Yes) nocons ctitle("`ctitle'")
end

* define a program to run regression (on wet bulb temperature) and create a tex file
program define regress_wb
syntax, outfile(name) outcome(varname) temperature_list(varlist ts fv) ///
  precipitation_list(varlist ts fv) wb_list(varlist ts fv) control(varlist ts fv) ///
  ctitle(string) lr(string asis)
  qui: reg `outcome' `wb_list' `precipitation_list' `control', robust
  qui: testparm `wb_list'
  scalar temp1 = r(p)
  local temp1=scalar(temp1)
  qui: testparm `precipitation_list'
  scalar temp2 = r(p)
  local temp2=scalar(temp2)
  qui: sum `outcome' 
  scalar mean_outcome = r(mean)
  local mean_outcome=scalar(mean_outcome)
  outreg2 using "../Outputs/tex/`outfile'.tex", ///
    label tex(frag) keep(`wb_list' `precipitation_list') sortvar(`temperature_list' `wb_list' `precipitation_list') ///
    adds(Mean of outcome, `mean_outcome', \$ p \$-value of \$ F \$-test (Wet bulb temperature), `temp1', \$ p \$-value of \$ F \$-test (Precipitation), `temp2') ///
    addtext(LR Weather, `lr', State FE, Yes, Wave FE, Yes) nocons ctitle("`ctitle'")
end

* define a program to run regression (on precipitation only) and create a tex file
program define regress_precip
syntax, outfile(name) outcome(varname) temperature_list(varlist ts fv) ///
  precipitation_list(varlist ts fv) wb_list(varlist ts fv) control(varlist ts fv) ///
  ctitle(string) lr(string asis)
  qui: reg `outcome' `precipitation_list' `control', robust
  qui: testparm `precipitation_list'
  scalar temp2 = r(p)
  local temp2=scalar(temp2)
  qui: sum `outcome' 
  scalar mean_outcome = r(mean)
  local mean_outcome=scalar(mean_outcome)
  outreg2 using "../Outputs/tex/`outfile'.tex", ///
    label tex(frag) keep(`wb_list' `precipitation_list') sortvar(`temperature_list' `wb_list' `precipitation_list') ///
    adds(Mean of outcome, `mean_outcome', \$ p \$-value of \$ F \$-test (Precipitation), `temp2') ///
    addtext(LR Weather, `lr', State FE, Yes, Wave FE, Yes) nocons ctitle("`ctitle'")
end

* define a program to run a series of regressions (quartile)
program define regress_basic_series
syntax, outfile(name) outcome(varname) temperature(varname) precipitation(varname) ///
  wb(varname) control_noLR(varlist ts fv) control_LR_basic(varlist ts fv) ///
  control_LR_wb(varlist ts fv) control_LR_precip(varlist ts fv) ctitle(string)
  cap shell rm ../Outputs/tex/`outfile'.tex
  cap shell rm ../Outputs/tex/`outfile'.txt

  preserve

  * generate bins for climate variables
  xtile quart_tem = `temperature', nq(4)
  xtile quart_pre = `precipitation', nq(4)
  xtile quart_wb = `wb', nq(4)
  xi i.quart_tem i.quart_pre i.quart_wb
  
  label var _Iquart_tem_2 "Temperature (2nd quartile)"
  label var _Iquart_tem_3 "Temperature (3rd quartile)"
  label var _Iquart_tem_4 "Temperature (4th quartile)"
  label var _Iquart_pre_2 "Precipitation (2nd quartile)"
  label var _Iquart_pre_3 "Precipitation (3rd quartile)"
  label var _Iquart_pre_4 "Precipitation (4th quartile)"
  label var _Iquart_wb_2 "Wet bulb temperature (2nd quartile)"
  label var _Iquart_wb_3 "Wet bulb temperature (3rd quartile)"
  label var _Iquart_wb_4 "Wet bulb temperature (4th quartile)"

  regress_basic,  outfile(`outfile') outcome(`outcome') temperature_list(_Iquart_tem*) ///
    precipitation_list(_Iquart_pre*) wb_list(_Iquart_wb*) control(`control_noLR') ///
    ctitle(`ctitle') lr("No")
  regress_wb,     outfile(`outfile') outcome(`outcome') temperature_list(_Iquart_tem*) ///
    precipitation_list(_Iquart_pre*) wb_list(_Iquart_wb*) control(`control_noLR') ///
    ctitle(`ctitle') lr("No")
  regress_precip, outfile(`outfile') outcome(`outcome') temperature_list(_Iquart_tem*) ///
    precipitation_list(_Iquart_pre*) wb_list(_Iquart_wb*) control(`control_noLR') ///
    ctitle(`ctitle') lr("No")
  regress_basic,  outfile(`outfile') outcome(`outcome') temperature_list(_Iquart_tem*) ///
    precipitation_list(_Iquart_pre*) wb_list(_Iquart_wb*) control(`control_LR_basic') ///
    ctitle(`ctitle') lr("Yes")
  regress_wb,     outfile(`outfile') outcome(`outcome') temperature_list(_Iquart_tem*) ///
    precipitation_list(_Iquart_pre*) wb_list(_Iquart_wb*) control(`control_LR_wb') ///
    ctitle(`ctitle') lr("Yes")
  regress_precip, outfile(`outfile') outcome(`outcome') temperature_list(_Iquart_tem*) ///
    precipitation_list(_Iquart_pre*) wb_list(_Iquart_wb*) control(`control_LR_precip') ///
    ctitle(`ctitle') lr("No")
  restore
end

* define a program to run a series of regressions (tertile)
program define regress_basic_series_tertile
syntax, outfile(name) outcome(varname) temperature(varname) precipitation(varname) ///
  wb(varname) control_noLR(varlist ts fv) control_LR_basic(varlist ts fv) ///
  control_LR_wb(varlist ts fv) control_LR_precip(varlist ts fv) ctitle(string)
  cap shell rm ../Outputs/tex/`outfile'.tex
  cap shell rm ../Outputs/tex/`outfile'.txt

  preserve

  * generate bins for climate variables
  xtile tert_tem = `temperature', nq(3)
  xtile tert_pre = `precipitation', nq(3)
  xtile tert_wb = `wb', nq(3)
  xi i.tert_tem i.tert_pre i.tert_wb
  
  label var _Itert_tem_2 "Temperature (2nd tertile)"
  label var _Itert_tem_3 "Temperature (3rd tertile)"
  label var _Itert_pre_2 "Precipitation (2nd tertile)"
  label var _Itert_pre_3 "Precipitation (3rd tertile)"
  label var _Itert_wb_2 "Wet bulb temperature (2nd tertile)"
  label var _Itert_wb_3 "Wet bulb temperature (3rd tertile)"

  regress_basic,  outfile(`outfile') outcome(`outcome') temperature_list(_Itert_tem*) ///
    precipitation_list(_Itert_pre*) wb_list(_Itert_wb*) control(`control_noLR') ///
    ctitle(`ctitle') lr("No")
  regress_wb,     outfile(`outfile') outcome(`outcome') temperature_list(_Itert_tem*) ///
    precipitation_list(_Itert_pre*) wb_list(_Itert_wb*) control(`control_noLR') ///
    ctitle(`ctitle') lr("No")
  regress_precip, outfile(`outfile') outcome(`outcome') temperature_list(_Itert_tem*) ///
    precipitation_list(_Itert_pre*) wb_list(_Itert_wb*) control(`control_noLR') ///
    ctitle(`ctitle') lr("No")
  regress_basic,  outfile(`outfile') outcome(`outcome') temperature_list(_Itert_tem*) ///
    precipitation_list(_Itert_pre*) wb_list(_Itert_wb*) control(`control_LR_basic') ///
    ctitle(`ctitle') lr("Yes")
  regress_wb,     outfile(`outfile') outcome(`outcome') temperature_list(_Itert_tem*) ///
    precipitation_list(_Itert_pre*) wb_list(_Itert_wb*) control(`control_LR_wb') ///
    ctitle(`ctitle') lr("Yes")
  regress_precip, outfile(`outfile') outcome(`outcome') temperature_list(_Itert_tem*) ///
    precipitation_list(_Itert_pre*) wb_list(_Itert_wb*) control(`control_LR_precip') ///
    ctitle(`ctitle') lr("Yes")
  restore
end

* define a program to run a series of regressions (quintile)
program define regress_basic_series_quintile
syntax, outfile(name) outcome(varname) temperature(varname) precipitation(varname) ///
  wb(varname) control_noLR(varlist ts fv) control_LR_basic(varlist ts fv) ///
  control_LR_wb(varlist ts fv) control_LR_precip(varlist ts fv) ctitle(string)
  cap shell rm ../Outputs/tex/`outfile'.tex
  cap shell rm ../Outputs/tex/`outfile'.txt

  preserve

  * generate bins for climate variables
  xtile quint_tem = `temperature', nq(5)
  xtile quint_pre = `precipitation', nq(4)
  xtile quint_wb = `wb', nq(5)
  xi i.quint_tem i.quint_pre i.quint_wb
  
  label var _Iquint_tem_2 "Temperature (2nd quintile)"
  label var _Iquint_tem_3 "Temperature (3rd quintile)"
  label var _Iquint_tem_4 "Temperature (4th quintile)"
  label var _Iquint_tem_5 "Temperature (5th quintile)"
  label var _Iquint_pre_2 "Precipitation (2nd quartile)"
  label var _Iquint_pre_3 "Precipitation (3rd quartile)"
  label var _Iquint_pre_4 "Precipitation (4th quartile)"
  label var _Iquint_wb_2 "Wet bulb temperature (2nd quintile)"
  label var _Iquint_wb_3 "Wet bulb temperature (3rd quintile)"
  label var _Iquint_wb_4 "Wet bulb temperature (4th quintile)"
  label var _Iquint_wb_5 "Wet bulb temperature (5th quintile)"

  regress_basic,  outfile(`outfile') outcome(`outcome') temperature_list(_Iquint_tem*) ///
    precipitation_list(_Iquint_pre*) wb_list(_Iquint_wb*) control(`control_noLR') ///
    ctitle(`ctitle') lr("No")
  regress_wb,     outfile(`outfile') outcome(`outcome') temperature_list(_Iquint_tem*) ///
    precipitation_list(_Iquint_pre*) wb_list(_Iquint_wb*) control(`control_noLR') ///
    ctitle(`ctitle') lr("No")
  regress_precip, outfile(`outfile') outcome(`outcome') temperature_list(_Iquint_tem*) ///
    precipitation_list(_Iquint_pre*) wb_list(_Iquint_wb*) control(`control_noLR') ///
    ctitle(`ctitle') lr("No")
  regress_basic,  outfile(`outfile') outcome(`outcome') temperature_list(_Iquint_tem*) ///
    precipitation_list(_Iquint_pre*) wb_list(_Iquint_wb*) control(`control_LR_basic') ///
    ctitle(`ctitle') lr("Yes")
  regress_wb,     outfile(`outfile') outcome(`outcome') temperature_list(_Iquint_tem*) ///
    precipitation_list(_Iquint_pre*) wb_list(_Iquint_wb*) control(`control_LR_wb') ///
    ctitle(`ctitle') lr("Yes")
  regress_precip, outfile(`outfile') outcome(`outcome') temperature_list(_Iquint_tem*) ///
    precipitation_list(_Iquint_pre*) wb_list(_Iquint_wb*) control(`control_LR_precip') ///
    ctitle(`ctitle') lr("Yes")
  restore
end

* define a program to run a series of regressions (arbitrary cutoffs)
program define regress_basic_series_cutoff
syntax, outfile(name) outcome(varname) temperature(varname) precipitation(varname) ///
  wb(varname) control_noLR(varlist ts fv) control_LR_basic(varlist ts fv) ///
  control_LR_wb(varlist ts fv) control_LR_precip(varlist ts fv) ctitle(string)
  cap shell rm ../Outputs/tex/`outfile'.tex
  cap shell rm ../Outputs/tex/`outfile'.txt

  preserve

  * generate arbitrary four bins for climate variables
  gen temp_bin2 = (`temperature' >= 20 & `temperature' < 25)
  gen temp_bin3 = (`temperature' >= 25 & `temperature' < 30)
  gen temp_bin4 = (`temperature' >= 30)
  gen precip_bin2 = (`precipitation' > 0 & `precipitation' < 5)
  gen precip_bin3 = (`precipitation' >= 5 & `precipitation' < 10)
  gen precip_bin4 = (`precipitation' >= 10)
  gen wb_bin2 = (`wb' >= 15 & `wb' < 20)
  gen wb_bin3 = (`wb' >= 20 & `wb' < 25)
  gen wb_bin4 = (`wb' >= 25)

  label var temp_bin2 "Temperature ($\ge$ 20 and $<$ 25)
  label var temp_bin3 "Temperature ($\ge$ 25 and $<$ 30)
  label var temp_bin4 "Temperature ($\ge$ 30)
  label var precip_bin2 "Precipitation ($>$ 0 and $<$ 5)
  label var precip_bin3 "Precipitation ($\ge$ 5 and $<$ 10)
  label var precip_bin4 "Precipitation ($\ge$ 10)
  label var wb_bin2 "Wet bulb temperature ($\ge$ 15 and $<$ 20)
  label var wb_bin3 "Wet bulb temperature ($\ge$ 20 and $<$ 25)
  label var wb_bin4 "Wet bulb temperature ($\ge$ 25)

  regress_basic,  outfile(`outfile') outcome(`outcome') temperature_list(temp_bin*) ///
    precipitation_list(precip_bin*) wb_list(wb_bin*) control(`control_noLR') ///
    ctitle(`ctitle') lr("No")
  regress_wb,     outfile(`outfile') outcome(`outcome') temperature_list(temp_bin*) ///
    precipitation_list(precip_bin*) wb_list(wb_bin*) control(`control_noLR') ///
    ctitle(`ctitle') lr("No")
  regress_precip, outfile(`outfile') outcome(`outcome') temperature_list(temp_bin*) ///
    precipitation_list(precip_bin*) wb_list(wb_bin*) control(`control_noLR') ///
    ctitle(`ctitle') lr("No")
  regress_basic,  outfile(`outfile') outcome(`outcome') temperature_list(temp_bin*) ///
    precipitation_list(precip_bin*) wb_list(wb_bin*) control(`control_LR_basic') ///
    ctitle(`ctitle') lr("Yes")
  regress_wb,     outfile(`outfile') outcome(`outcome') temperature_list(temp_bin*) ///
    precipitation_list(precip_bin*) wb_list(wb_bin*) control(`control_LR_wb') ///
    ctitle(`ctitle') lr("Yes")
  regress_precip, outfile(`outfile') outcome(`outcome') temperature_list(temp_bin*) ///
    precipitation_list(precip_bin*) wb_list(wb_bin*) control(`control_LR_precip') ///
    ctitle(`ctitle') lr("Yes")
  restore
end

* Define local variable lists
local control_noLR       share_urban gini ln_pop percent_childpoor income_percap ///
  illiteracy_25plus share_worker_public tot_airport share_voter i.dominant_party ///
  i.wave i.uf_code
*local control_LR_basic   share_urban gini ln_pop percent_childpoor income_percap illiteracy_25plus share_worker_public tot_airport share_voter i.dominant_party i.wave i.uf_code lr_tas_annual_daytime lr_average_precipitation
*local control_LR_wb      share_urban gini ln_pop percent_childpoor income_percap illiteracy_25plus share_worker_public tot_airport share_voter i.dominant_party i.wave i.uf_code lr_wb_annual_daytime lr_average_precipitation
*local control_LR_precip  share_urban gini ln_pop percent_childpoor income_percap illiteracy_25plus share_worker_public tot_airport share_voter i.dominant_party i.wave i.uf_code lr_average_precipitation
local control_LR_basic   share_urban gini ln_pop percent_childpoor income_percap ///
  illiteracy_25plus share_worker_public tot_airport share_voter i.dominant_party ///
  i.wave i.uf_code i.lr_quart_tem i.lr_quart_pre
local control_LR_wb      share_urban gini ln_pop percent_childpoor income_percap ///
  illiteracy_25plus share_worker_public tot_airport share_voter i.dominant_party ///
  i.wave i.uf_code i.lr_quart_wb i.lr_quart_pre
local control_LR_precip  share_urban gini ln_pop percent_childpoor income_percap ///
  illiteracy_25plus share_worker_public tot_airport share_voter i.dominant_party ///
  i.wave i.uf_code i.lr_quart_pre

* quartile -------------------
* Ferraz and Finan --------------------
use "${data}/Temp/main_data_ff.dta", clear
keep if ff_data == 1
regress_basic_series, outfile(reg_ncorrupt_ff_beamer) outcome(ncorrupt) ///
  temperature(tas_daytime) precipitation(precipitation) wb(wb_daytime) control_noLR(`control_noLR') ///
  control_LR_basic(`control_LR_basic') control_LR_wb(`control_LR_wb') control_LR_precip(`control_LR_precip') ///
  ctitle("Number")
regress_basic_series, outfile(reg_any_corrupt_ff_beamer) outcome(corrupt_dummy) ///
  temperature(tas_daytime) precipitation(precipitation) wb(wb_daytime) control_noLR(`control_noLR') ///
  control_LR_basic(`control_LR_basic') control_LR_wb(`control_LR_wb') control_LR_precip(`control_LR_precip') ///
  ctitle("Dummy")
regress_basic_series, outfile(reg_day_fw_ff_beamer) outcome(days_fieldwork) ///
  temperature(tas_daytime) precipitation(precipitation) wb(wb_daytime) control_noLR(`control_noLR') ///
  control_LR_basic(`control_LR_basic') control_LR_wb(`control_LR_wb') control_LR_precip(`control_LR_precip') ///
  ctitle("Days_FW")
regress_basic_series, outfile(reg_page_ff_beamer) outcome(page_number) ///
  temperature(tas_daytime) precipitation(precipitation) wb(wb_daytime) control_noLR(`control_noLR') ///
  control_LR_basic(`control_LR_basic') control_LR_wb(`control_LR_wb') control_LR_precip(`control_LR_precip') ///
  ctitle("Pages")
regress_basic_series, outfile(reg_zero_ff_beamer) outcome(count_zero) temperature(tas_daytime) ///
  precipitation(precipitation) wb(wb_daytime) control_noLR(`control_noLR') ///
  control_LR_basic(`control_LR_basic') control_LR_wb(`control_LR_wb') control_LR_precip(`control_LR_precip') ///
  ctitle("Zeros")

* Brollo (collapsed) --------------------
use "${data}/Temp/main_data_br.dta", clear
regress_basic_series, outfile(reg_broad_br_beamer) outcome(broad) temperature(tas_daytime) ///
  precipitation(precipitation) wb(wb_daytime) control_noLR(`control_noLR') ///
  control_LR_basic(`control_LR_basic') control_LR_wb(`control_LR_wb') control_LR_precip(`control_LR_precip') ///
  ctitle("Broad")
regress_basic_series, outfile(reg_narrow_br_beamer) outcome(narrow) temperature(tas_daytime) ///
  precipitation(precipitation) wb(wb_daytime) control_noLR(`control_noLR') ///
  control_LR_basic(`control_LR_basic') control_LR_wb(`control_LR_wb') control_LR_precip(`control_LR_precip') ///
  ctitle("Narrow")
regress_basic_series, outfile(reg_day_fw_br_beamer) outcome(days_fieldwork) ///
  temperature(tas_daytime) precipitation(precipitation) wb(wb_daytime) control_noLR(`control_noLR') ///
  control_LR_basic(`control_LR_basic') control_LR_wb(`control_LR_wb') control_LR_precip(`control_LR_precip') ///
  ctitle("Days_FW")
regress_basic_series, outfile(reg_page_br_beamer) outcome(page_number) ///
  temperature(tas_daytime) precipitation(precipitation) wb(wb_daytime) control_noLR(`control_noLR') ///
  control_LR_basic(`control_LR_basic') control_LR_wb(`control_LR_wb') control_LR_precip(`control_LR_precip') ///
  ctitle("Pages")
regress_basic_series, outfile(reg_zero_br_beamer) outcome(count_zero) temperature(tas_daytime) ///
  precipitation(precipitation) wb(wb_daytime) control_noLR(`control_noLR') ///
  control_LR_basic(`control_LR_basic') control_LR_wb(`control_LR_wb') control_LR_precip(`control_LR_precip') ///
  ctitle("Zeros")

* Brollo (non-collapsed) --------------------
use "${data}/Temp/main_data_br_nocol.dta", clear
regress_basic_series, outfile(reg_broad_br_nocol_beamer) outcome(broad) ///
  temperature(tas_daytime) precipitation(precipitation) wb(wb_daytime) control_noLR(`control_noLR') ///
  control_LR_basic(`control_LR_basic') control_LR_wb(`control_LR_wb') control_LR_precip(`control_LR_precip') ///
  ctitle("Broad")
regress_basic_series, outfile(reg_narrow_br_nocol_beamer) outcome(narrow) ///
  temperature(tas_daytime) precipitation(precipitation) wb(wb_daytime) control_noLR(`control_noLR') ///
  control_LR_basic(`control_LR_basic') control_LR_wb(`control_LR_wb') control_LR_precip(`control_LR_precip') ///
  ctitle("Narrow")
regress_basic_series, outfile(reg_fbroad_br_nocol_beamer) outcome(fbroad) ///
  temperature(tas_daytime) precipitation(precipitation) wb(wb_daytime) control_noLR(`control_noLR') ///
  control_LR_basic(`control_LR_basic') control_LR_wb(`control_LR_wb') control_LR_precip(`control_LR_precip') ///
  ctitle("Broad (%)")
regress_basic_series, outfile(reg_fnarrow_br_nocol_beamer) outcome(fnarrow) ///
  temperature(tas_daytime) precipitation(precipitation) wb(wb_daytime) control_noLR(`control_noLR') ///
  control_LR_basic(`control_LR_basic') control_LR_wb(`control_LR_wb') control_LR_precip(`control_LR_precip') ///
  ctitle("Narrow (%)")

* quartile (first 5 days) -------------------
* Ferraz and Finan --------------------
use "${data}/Temp/main_data_ff.dta", clear
keep if ff_data == 1
keep if days_fieldwork >= 5
regress_basic_series, outfile(reg_ncorrupt_ff_5_beamer) outcome(ncorrupt) ///
  temperature(tas_first5_daytime) precipitation(precipitation_first5) wb(wb_first5_daytime) ///
  control_noLR(`control_noLR') control_LR_basic(`control_LR_basic') control_LR_wb(`control_LR_wb') ///
  control_LR_precip(`control_LR_precip') ctitle("Number")
regress_basic_series, outfile(reg_any_corrupt_ff_5_beamer) outcome(corrupt_dummy) ///
  temperature(tas_first5_daytime) precipitation(precipitation_first5) wb(wb_first5_daytime) ///
  control_noLR(`control_noLR') control_LR_basic(`control_LR_basic') control_LR_wb(`control_LR_wb') ///
  control_LR_precip(`control_LR_precip') ctitle("Dummy")
regress_basic_series, outfile(reg_day_fw_ff_5_beamer) outcome(days_fieldwork) ///
  temperature(tas_first5_daytime) precipitation(precipitation_first5) wb(wb_first5_daytime) ///
  control_noLR(`control_noLR') control_LR_basic(`control_LR_basic') control_LR_wb(`control_LR_wb') ///
  control_LR_precip(`control_LR_precip') ctitle("Days_FW")
regress_basic_series, outfile(reg_page_ff_5_beamer) outcome(page_number) ///
  temperature(tas_first5_daytime) precipitation(precipitation_first5) wb(wb_first5_daytime) ///
  control_noLR(`control_noLR') control_LR_basic(`control_LR_basic') control_LR_wb(`control_LR_wb') ///
  control_LR_precip(`control_LR_precip') ctitle("Pages")

* Brollo (collapsed) --------------------
use "${data}/Temp/main_data_br.dta", clear
keep if days_fieldwork >= 5
regress_basic_series, outfile(reg_broad_br_5_beamer) outcome(broad) temperature(tas_first5_daytime) ///
  precipitation(precipitation_first5) wb(wb_first5_daytime) control_noLR(`control_noLR') ///
  control_LR_basic(`control_LR_basic') control_LR_wb(`control_LR_wb') control_LR_precip(`control_LR_precip') ///
  ctitle("Broad")
regress_basic_series, outfile(reg_narrow_br_5_beamer) outcome(narrow) temperature(tas_first5_daytime) ///
  precipitation(precipitation_first5) wb(wb_first5_daytime) control_noLR(`control_noLR') ///
  control_LR_basic(`control_LR_basic') control_LR_wb(`control_LR_wb') control_LR_precip(`control_LR_precip') ///
  ctitle("Narrow")
regress_basic_series, outfile(reg_day_fw_br_5_beamer) outcome(days_fieldwork) ///
  temperature(tas_first5_daytime) precipitation(precipitation_first5) wb(wb_first5_daytime) ///
  control_noLR(`control_noLR') control_LR_basic(`control_LR_basic') control_LR_wb(`control_LR_wb') ///
  control_LR_precip(`control_LR_precip') ctitle("Days_FW")
regress_basic_series, outfile(reg_page_br_5_beamer) outcome(page_number) ///
  temperature(tas_first5_daytime) precipitation(precipitation_first5) wb(wb_first5_daytime) ///
  control_noLR(`control_noLR') control_LR_basic(`control_LR_basic') control_LR_wb(`control_LR_wb') ///
  control_LR_precip(`control_LR_precip') ctitle("Pages")

* Brollo (non-collapsed) --------------------
use "${data}/Temp/main_data_br_nocol.dta", clear
keep if days_fieldwork >= 5
regress_basic_series, outfile(reg_broad_br_nocol_5_beamer) outcome(broad) ///
  temperature(tas_first5_daytime) precipitation(precipitation_first5) wb(wb_first5_daytime) ///
  control_noLR(`control_noLR') control_LR_basic(`control_LR_basic') control_LR_wb(`control_LR_wb') ///
  control_LR_precip(`control_LR_precip') ctitle("Broad")
regress_basic_series, outfile(reg_narrow_br_nocol_5_beamer) outcome(narrow) ///
  temperature(tas_first5_daytime) precipitation(precipitation_first5) wb(wb_first5_daytime) ///
  control_noLR(`control_noLR') control_LR_basic(`control_LR_basic') control_LR_wb(`control_LR_wb') ///
  control_LR_precip(`control_LR_precip') ctitle("Narrow")
regress_basic_series, outfile(reg_fbroad_br_nocol_5_beamer) outcome(fbroad) ///
  temperature(tas_first5_daytime) precipitation(precipitation_first5) wb(wb_first5_daytime) ///
  control_noLR(`control_noLR') control_LR_basic(`control_LR_basic') control_LR_wb(`control_LR_wb') ///
  control_LR_precip(`control_LR_precip') ctitle("Broad (%)")
regress_basic_series, outfile(reg_fnarrow_br_nocol_5_beamer) outcome(fnarrow) ///
  temperature(tas_first5_daytime) precipitation(precipitation_first5) wb(wb_first5_daytime) ///
  control_noLR(`control_noLR') control_LR_basic(`control_LR_basic') control_LR_wb(`control_LR_wb') ///
  control_LR_precip(`control_LR_precip') ctitle("Narrow (%)")

* quintile -------------------
* Ferraz and Finan --------------------
use "${data}/Temp/main_data_ff.dta", clear
keep if ff_data == 1
regress_basic_series_quintile, outfile(reg_ncorrupt_ff_quin_beamer) outcome(ncorrupt) ///
  temperature(tas_daytime) precipitation(precipitation) wb(wb_daytime) control_noLR(`control_noLR') ///
  control_LR_basic(`control_LR_basic') control_LR_wb(`control_LR_wb') control_LR_precip(`control_LR_precip') ///
  ctitle("Number")
regress_basic_series_quintile, outfile(reg_any_corrupt_ff_quin_beamer) ///
  outcome(corrupt_dummy) temperature(tas_daytime) precipitation(precipitation) ///
  wb(wb_daytime) control_noLR(`control_noLR') control_LR_basic(`control_LR_basic') ///
  control_LR_wb(`control_LR_wb') control_LR_precip(`control_LR_precip') ///
  ctitle("Dummy")
regress_basic_series_quintile, outfile(reg_day_fw_ff_quin_beamer) outcome(days_fieldwork) ///
  temperature(tas_daytime) precipitation(precipitation) wb(wb_daytime) control_noLR(`control_noLR') ///
  control_LR_basic(`control_LR_basic') control_LR_wb(`control_LR_wb') control_LR_precip(`control_LR_precip') ///
  ctitle("Days_FW")
regress_basic_series_quintile, outfile(reg_page_ff_quin_beamer) outcome(page_number) ///
  temperature(tas_daytime) precipitation(precipitation) wb(wb_daytime) control_noLR(`control_noLR') ///
  control_LR_basic(`control_LR_basic') control_LR_wb(`control_LR_wb') control_LR_precip(`control_LR_precip') ///
  ctitle("Pages")

* Brollo (collapsed) --------------------
use "${data}/Temp/main_data_br.dta", clear
regress_basic_series_quintile, outfile(reg_broad_br_quin_beamer) outcome(broad) ///
  temperature(tas_daytime) precipitation(precipitation) wb(wb_daytime) control_noLR(`control_noLR') ///
  control_LR_basic(`control_LR_basic') control_LR_wb(`control_LR_wb') control_LR_precip(`control_LR_precip') ///
  ctitle("Broad")
regress_basic_series_quintile, outfile(reg_narrow_br_quin_beamer) outcome(narrow) ///
  temperature(tas_daytime) precipitation(precipitation) wb(wb_daytime) control_noLR(`control_noLR') ///
  control_LR_basic(`control_LR_basic') control_LR_wb(`control_LR_wb') control_LR_precip(`control_LR_precip') ///
  ctitle("Narrow")
regress_basic_series_quintile, outfile(reg_day_fw_br_quin_beamer) outcome(days_fieldwork) ///
  temperature(tas_daytime) precipitation(precipitation) wb(wb_daytime) control_noLR(`control_noLR') ///
  control_LR_basic(`control_LR_basic') control_LR_wb(`control_LR_wb') control_LR_precip(`control_LR_precip') ///
  ctitle("Days_FW")
regress_basic_series_quintile, outfile(reg_page_br_quin_beamer) outcome(page_number) ///
  temperature(tas_daytime) precipitation(precipitation) wb(wb_daytime) control_noLR(`control_noLR') ///
  control_LR_basic(`control_LR_basic') control_LR_wb(`control_LR_wb') control_LR_precip(`control_LR_precip') ///
  ctitle("Pages")

* Brollo (non-collapsed) --------------------
use "${data}/Temp/main_data_br_nocol.dta", clear
regress_basic_series_quintile, outfile(reg_broad_br_nocol_quin_beamer) ///
  outcome(broad) temperature(tas_daytime) precipitation(precipitation) wb(wb_daytime) ///
  control_noLR(`control_noLR') control_LR_basic(`control_LR_basic') control_LR_wb(`control_LR_wb') ///
  control_LR_precip(`control_LR_precip') ctitle("Broad")
regress_basic_series_quintile, outfile(reg_narrow_br_nocol_quin_beamer) ///
  outcome(narrow) temperature(tas_daytime) precipitation(precipitation) ///
  wb(wb_daytime) control_noLR(`control_noLR') control_LR_basic(`control_LR_basic') ///
  control_LR_wb(`control_LR_wb') control_LR_precip(`control_LR_precip') ///
  ctitle("Narrow")
regress_basic_series_quintile, outfile(reg_fbroad_br_nocol_quin_beamer) ///
  outcome(fbroad) temperature(tas_daytime) precipitation(precipitation) ///
  wb(wb_daytime) control_noLR(`control_noLR') control_LR_basic(`control_LR_basic') ///
  control_LR_wb(`control_LR_wb') control_LR_precip(`control_LR_precip') ///
  ctitle("Broad (%)")
regress_basic_series_quintile, outfile(reg_fnarrow_br_nocol_quin_beamer) ///
  outcome(fnarrow) temperature(tas_daytime) precipitation(precipitation) ///
  wb(wb_daytime) control_noLR(`control_noLR') control_LR_basic(`control_LR_basic') ///
  control_LR_wb(`control_LR_wb') control_LR_precip(`control_LR_precip') ///
  ctitle("Narrow (%)")

* tertile -------------------
* Ferraz and Finan --------------------
use "${data}/Temp/main_data_ff.dta", clear
keep if ff_data == 1
regress_basic_series_tertile, outfile(reg_ncorrupt_ff_tert_beamer) outcome(ncorrupt) ///
  temperature(tas_daytime) precipitation(precipitation) wb(wb_daytime) control_noLR(`control_noLR') ///
  control_LR_basic(`control_LR_basic') control_LR_wb(`control_LR_wb') control_LR_precip(`control_LR_precip') ///
  ctitle("Number")
regress_basic_series_tertile, outfile(reg_any_corrupt_ff_tert_beamer) outcome(corrupt_dummy) ///
  temperature(tas_daytime) precipitation(precipitation) wb(wb_daytime) control_noLR(`control_noLR') ///
  control_LR_basic(`control_LR_basic') control_LR_wb(`control_LR_wb') control_LR_precip(`control_LR_precip') ///
  ctitle("Dummy")
regress_basic_series_tertile, outfile(reg_day_fw_ff_tert_beamer) outcome(days_fieldwork) ///
  temperature(tas_daytime) precipitation(precipitation) wb(wb_daytime) control_noLR(`control_noLR') ///
  control_LR_basic(`control_LR_basic') control_LR_wb(`control_LR_wb') control_LR_precip(`control_LR_precip') ///
  ctitle("Days_FW")
regress_basic_series_tertile, outfile(reg_page_ff_tert_beamer) outcome(page_number) ///
  temperature(tas_daytime) precipitation(precipitation) wb(wb_daytime) control_noLR(`control_noLR') ///
  control_LR_basic(`control_LR_basic') control_LR_wb(`control_LR_wb') control_LR_precip(`control_LR_precip') ///
  ctitle("Pages")

* Brollo (collapsed) --------------------
use "${data}/Temp/main_data_br.dta", clear
regress_basic_series_tertile, outfile(reg_broad_br_tert_beamer) outcome(broad) ///
  temperature(tas_daytime) precipitation(precipitation) wb(wb_daytime) control_noLR(`control_noLR') ///
  control_LR_basic(`control_LR_basic') control_LR_wb(`control_LR_wb') control_LR_precip(`control_LR_precip') ///
  ctitle("Broad")
regress_basic_series_tertile, outfile(reg_narrow_br_tert_beamer) outcome(narrow) ///
  temperature(tas_daytime) precipitation(precipitation) wb(wb_daytime) control_noLR(`control_noLR') ///
  control_LR_basic(`control_LR_basic') control_LR_wb(`control_LR_wb') control_LR_precip(`control_LR_precip') ///
  ctitle("Narrow")
regress_basic_series_tertile, outfile(reg_day_fw_br_tert_beamer) outcome(days_fieldwork) ///
  temperature(tas_daytime) precipitation(precipitation) wb(wb_daytime) control_noLR(`control_noLR') ///
  control_LR_basic(`control_LR_basic') control_LR_wb(`control_LR_wb') control_LR_precip(`control_LR_precip') ///
  ctitle("Days_FW")
regress_basic_series_tertile, outfile(reg_page_br_tert_beamer) outcome(page_number) ///
  temperature(tas_daytime) precipitation(precipitation) wb(wb_daytime) control_noLR(`control_noLR') ///
  control_LR_basic(`control_LR_basic') control_LR_wb(`control_LR_wb') control_LR_precip(`control_LR_precip') ///
  ctitle("Pages")

* Brollo (non-collapsed) --------------------
use "${data}/Temp/main_data_br_nocol.dta", clear
regress_basic_series_tertile, outfile(reg_broad_br_nocol_tert_beamer) outcome(broad) ///
  temperature(tas_daytime) precipitation(precipitation) wb(wb_daytime) control_noLR(`control_noLR') ///
  control_LR_basic(`control_LR_basic') control_LR_wb(`control_LR_wb') control_LR_precip(`control_LR_precip') ///
  ctitle("Broad")
regress_basic_series_tertile, outfile(reg_narrow_br_nocol_tert_beamer) ///
  outcome(narrow) temperature(tas_daytime) precipitation(precipitation) ///
  wb(wb_daytime) control_noLR(`control_noLR') control_LR_basic(`control_LR_basic') ///
  control_LR_wb(`control_LR_wb') control_LR_precip(`control_LR_precip') ///
  ctitle("Narrow")
regress_basic_series_tertile, outfile(reg_fbroad_br_nocol_tert_beamer) ///
  outcome(fbroad) temperature(tas_daytime) precipitation(precipitation) ///
  wb(wb_daytime) control_noLR(`control_noLR') control_LR_basic(`control_LR_basic') ///
  control_LR_wb(`control_LR_wb') control_LR_precip(`control_LR_precip') ///
  ctitle("Broad (%)")
regress_basic_series_tertile, outfile(reg_fnarrow_br_nocol_tert_beamer) ///
  outcome(fnarrow) temperature(tas_daytime) precipitation(precipitation) ///
  wb(wb_daytime) control_noLR(`control_noLR') control_LR_basic(`control_LR_basic') ///
  control_LR_wb(`control_LR_wb') control_LR_precip(`control_LR_precip') ///
  ctitle("Narrow (%)")

* arbitrary cutoffs -------------------
* Ferraz and Finan --------------------
use "${data}/Temp/main_data_ff.dta", clear
keep if ff_data == 1
regress_basic_series_cutoff, outfile(reg_ncorrupt_ff_co_beamer) outcome(ncorrupt) ///
  temperature(tas_daytime) precipitation(precipitation) wb(wb_daytime) control_noLR(`control_noLR') ///
  control_LR_basic(`control_LR_basic') control_LR_wb(`control_LR_wb') control_LR_precip(`control_LR_precip') ///
  ctitle("Number")
regress_basic_series_cutoff, outfile(reg_any_corrupt_ff_co_beamer) outcome(corrupt_dummy) ///
  temperature(tas_daytime) precipitation(precipitation) wb(wb_daytime) control_noLR(`control_noLR') ///
  control_LR_basic(`control_LR_basic') control_LR_wb(`control_LR_wb') control_LR_precip(`control_LR_precip') ///
  ctitle("Dummy")
regress_basic_series_cutoff, outfile(reg_day_fw_ff_co_beamer) outcome(days_fieldwork) ///
  temperature(tas_daytime) precipitation(precipitation) wb(wb_daytime) control_noLR(`control_noLR') ///
  control_LR_basic(`control_LR_basic') control_LR_wb(`control_LR_wb') control_LR_precip(`control_LR_precip') ///
  ctitle("Days_FW")
regress_basic_series_cutoff, outfile(reg_page_ff_co_beamer) outcome(page_number) ///
  temperature(tas_daytime) precipitation(precipitation) wb(wb_daytime) control_noLR(`control_noLR') ///
  control_LR_basic(`control_LR_basic') control_LR_wb(`control_LR_wb') control_LR_precip(`control_LR_precip') ///
  ctitle("Pages")

* Brollo (collapsed) --------------------
use "${data}/Temp/main_data_br.dta", clear
regress_basic_series_cutoff, outfile(reg_broad_br_co_beamer) outcome(broad) ///
  temperature(tas_daytime) precipitation(precipitation) wb(wb_daytime) control_noLR(`control_noLR') ///
  control_LR_basic(`control_LR_basic') control_LR_wb(`control_LR_wb') control_LR_precip(`control_LR_precip') ///
  ctitle("Broad")
regress_basic_series_cutoff, outfile(reg_narrow_br_co_beamer) outcome(narrow) ///
  temperature(tas_daytime) precipitation(precipitation) wb(wb_daytime) control_noLR(`control_noLR') ///
  control_LR_basic(`control_LR_basic') control_LR_wb(`control_LR_wb') control_LR_precip(`control_LR_precip') ///
  ctitle("Narrow")
regress_basic_series_cutoff, outfile(reg_day_fw_br_co_beamer) outcome(days_fieldwork) ///
  temperature(tas_daytime) precipitation(precipitation) wb(wb_daytime) control_noLR(`control_noLR') ///
  control_LR_basic(`control_LR_basic') control_LR_wb(`control_LR_wb') control_LR_precip(`control_LR_precip') ///
  ctitle("Days_FW")
regress_basic_series_cutoff, outfile(reg_page_br_co_beamer) outcome(page_number) ///
  temperature(tas_daytime) precipitation(precipitation) wb(wb_daytime) control_noLR(`control_noLR') ///
  control_LR_basic(`control_LR_basic') control_LR_wb(`control_LR_wb') control_LR_precip(`control_LR_precip') ///
  ctitle("Pages")

* Brollo (non-collapsed) --------------------
use "${data}/Temp/main_data_br_nocol.dta", clear
regress_basic_series_cutoff, outfile(reg_broad_br_nocol_co_beamer) outcome(broad) ///
  temperature(tas_daytime) precipitation(precipitation) wb(wb_daytime) control_noLR(`control_noLR') ///
  control_LR_basic(`control_LR_basic') control_LR_wb(`control_LR_wb') control_LR_precip(`control_LR_precip') ///
  ctitle("Broad")
regress_basic_series_cutoff, outfile(reg_narrow_br_nocol_co_beamer) outcome(narrow) ///
  temperature(tas_daytime) precipitation(precipitation) wb(wb_daytime) control_noLR(`control_noLR') ///
  control_LR_basic(`control_LR_basic') control_LR_wb(`control_LR_wb') control_LR_precip(`control_LR_precip') ///
  ctitle("Narrow")
regress_basic_series_cutoff, outfile(reg_fbroad_br_nocol_co_beamer) outcome(fbroad) ///
  temperature(tas_daytime) precipitation(precipitation) wb(wb_daytime) control_noLR(`control_noLR') ///
  control_LR_basic(`control_LR_basic') control_LR_wb(`control_LR_wb') control_LR_precip(`control_LR_precip') ///
  ctitle("Broad (%)")
regress_basic_series_cutoff, outfile(reg_fnarrow_br_nocol_co_beamer) outcome(fnarrow) ///
  temperature(tas_daytime) precipitation(precipitation) wb(wb_daytime) control_noLR(`control_noLR') ///
  control_LR_basic(`control_LR_basic') control_LR_wb(`control_LR_wb') control_LR_precip(`control_LR_precip') ///
  ctitle("Narrow (%)")

