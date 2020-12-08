//Graph about SISU adoption:

*Municipalities:
use SISU_adoption_univ, clear
  
drop if type_univ == 3
gen in_SISU = univ_year_start_SISU<=year

collapse (max) in_SISU, by(year code_municipality_major)
unique code_municipality_major, by(in_SISU)
collapse (sum) in_SISU, by(year)

mkmat in_SISU, mat(mun_SISU)

*Universities:
use SISU_adoption_univ, clear
drop if type_univ==3
unique code_univ, by(type_univ)
unique code_univ
collapse (min) univ_year_start_SISU, by(code_univ)
gen in_SISU = univ_year_start_SISU >0

collapse (count) never = in_SISU, by(univ_year_start_SISU)

mkmat never, mat(univ_SISU)

*Merging both:
mat mun_SISU = [.,mun_SISU']
mat R = mun_SISU', univ_SISU
mat y = [0,2009,2010,2011,2012,2013,2014,2015,2016]'
mat R = R,y
clear
svmat R
keep R1 R2 R3
rename R1 mun_SISU
rename R2 univ_SISU
rename R3 year

egen total = total(univ_SISU)

gen cum_adopt = univ_SISU if year==2009
replace cum_adopt = cum_adopt[_n-1] + univ_SISU[_n] if _n>2
gen share_adopt = cum_adopt/total
drop if year==0

use "/Users/anamelo/Dropbox/Brazil_Exam/Data/SISU/adoption_graph.dta", clear

*Generating graph:
    twoway (bar univ_sisu year, barwidth(0.75) yaxis(1) color(ebblue%60)) ///
        (scatter mun_sisu year, connect(l) yaxis(2) mcolor(navy) lcolor(navy%50)), ///
            ylabel(0(10)130, axis(1)) ///
            ylabel(0(100)600, axis(2)) ///
            xlabel(2010(1)2018) ///
            ytitle("# Universities", axis(1)) ///
            ytitle("# Municipalities", axis(2)) ///
            xtitle("") ///
            legend(label(1 "Universities") label(2 "Municipalities")) ///
            graphregion(color(white)) plotregion(fcolor(white)) ///
 
graph export "/Users/anamelo/Dropbox/Brazil_Exam/Images/SISU_Adoption.pdf", ///
    replace

