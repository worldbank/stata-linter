

forvalues i=1/32{
use "/Users/itzel/Desktop/UW/Research/Censo 2000/Stata/data/PER_F`i'.dta", clear

decode ENT, gen(edo)

decode MUN, gen(mun)
 
gen inegi_mun=edo+mun

decode EDAD, gen(age)

destring age, replace

*************************
  *   POP BY GENDER   *
*************************

gen women=(SEXO==2)
gen men=(SEXO==1)


******************************
  *   POP BY AGE PROFILE   *
******************************


do "/Users/itzel/Desktop/UW/Labor/Female migration/Stata/Do files/age_profiles_census_factored"



contract inegi_mun total urban fem* male* pct*

save "/Users/itzel/Desktop/UW/Research/Censo 2000/Stata/bases/MUN_POP_F`i'.dta", replace

}


*************************
 *       APPEND        *
*************************

use "/Users/itzel/Desktop/UW/Research/Censo 2000/Stata/bases/MUN_POP_F1.dta", clear

forvalues i=2/32{

append using "/Users/itzel/Desktop/UW/Research/Censo 2000/Stata/bases/MUN_POP_F`i'.dta"

}

gen edo=substr(inegi_mun,1,2)
gen mun=substr(inegi_mun,3,3)

order inegi_mun edo mun, first

gen census=2000
gen survey=2002


save "/Users/itzel/Desktop/UW/Research/Censo 2000/Stata/bases/MUN_POP.dta", replace






