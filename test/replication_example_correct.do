****************************************************
**APPENDIX C. BIAS IN TRADITIONAL DECISION-MAKING **
****************************************************

*TABLE C1.*

use "${data}/HHdata_QJPS_labeled.dta", clear

preserve

    eststo clear
    keep if VH_treat==0
    
    by D37, sort: eststo: estpost summarize female ageHH finprim cattlewealth ///
        bornvillage VHethnicmatch VHfam diffview
    esttab using "${tables}/table_c1", ///
        tex replace cells("mean(fmt(a3))" sd(par fmt(a3))) label nodepvar ///
        noobs onecell nonotes
    esttab using "${tables}/table_c1_new.tex", ///
        replace cells("mean(fmt(a3))" sd(par fmt(a3))) ${stars1}
    eststo clear

restore

*TABLE C2.*

use "${data}/HHdata_QJPS_labeled.dta", clear

// Proposed changes
preserve
    keep if VH_treat==0
    
    local     vars        ///
            food_aid     ///
            mostfair     ///
            propcaseVH
            
    // Same View
    eststo clear 
    tvsc `vars' if VH_treat == 0, by(sameview) clus_id(male) strat_id(male)    
    esttab using "${tables}/table_c2a_new.tex", replace ${stars1}        ///
        cells("mu_1(fmt(%9.3fc)) mu_2(fmt(%9.3fc)) mu_3(fmt(%9.3fc))" "se_2(par) se_1(par) se_3(par)")

    // Born Village
    eststo clear 
    tvsc `vars' if VH_treat == 0, ///
        by(bornvillage) clus_id(male) strat_id(male)
    esttab using "${tables}/table_c2b_new.tex", replace ${stars1}        ///
        cells("mu_1(fmt(%9.3fc)) mu_2(fmt(%9.3fc)) mu_3(fmt(%9.3fc))" "se_2(par) se_1(par) se_3(par)")

    // VH Fam
    eststo clear 
    tvsc `vars' if VH_treat == 0, by(VHfam) clus_id(male) strat_id(male)    
    esttab using "${tables}/table_c2c_new.tex", replace ${stars1}        ///
        cells("mu_1(fmt(%9.3fc)) mu_2(fmt(%9.3fc)) mu_3(fmt(%9.3fc))" "se_2(par) se_1(par) se_3(par)")

    // Female vs Male
    eststo clear 
    tvsc `vars' if VH_treat == 0, by(male) clus_id(male) strat_id(male)    
    esttab using "${tables}/table_c2d_new.tex", replace ${stars1}        ///
        cells("mu_1(fmt(%9.3fc)) mu_2(fmt(%9.3fc)) mu_3(fmt(%9.3fc))" "se_2(par) se_1(par) se_3(par)")

restore 

***********************************************
**APPENDIX E. SELECTED CIVIL SOCIETY LEADERS **
***********************************************

**********
*TABLE E1*
**********

**Table E1, column 1 from administrative data (No replication data available)
**Table E1, rows 1-6: Output from tabulations below, not automated
**Only rows 1-8 in columns 2-4 are automated

use "${data}/CLdata_QJPS_labeled.dta", clear
tab X1 if dare!=1

eststo E1a: estpost sum female if dare!=1
sum relative if dare!=1
local pat_relative = r(mean)/2
estadd loc paternalrelative "`pat_relative'"

**Table E1, column 3:
tab X1 if dare==1

eststo E1b: estpost sum female if dare==1
sum relative if dare==1
local pat_relative = r(mean)/2
estadd loc paternalrelative "`pat_relative'"

**Table E1, column 4:

use "${data}/HHdata_QJPS_labeled.dta", clear

eststo E1c: estpost sum female if D37!=1
sum VHfam if D37!=1
local pat_relative = r(mean)/2
estadd loc paternalrelative "`pat_relative'"

esttab E1a E1b E1c using "${tables}/TableE1", ///
    tex replace cells("mean(fmt(a3))" sd(par fmt(a3))) stats(paternalrelative) ///
    label nodepvar noobs onecell

**********************************
**APPENDIX F. BALANCE STATISTICS**
**********************************

**********
*TABLE F1*
**********

use "${data}/VHdata_QJPS_labeled.dta", clear

eststo clear
loc indexlist communal numhouseholds numbergroups womenVH moreprimary age ///
    tenure VH_bornvillage logcattlewealth ZANUPF_para
loc n 0

foreach index of loc indexlist {
    loc ++n
    reg `index' VH_treat
    su `index' if VH_treat==1
    roundmeanonly, estadd(y1)
    su `index' if VH_treat==0
    roundmeanonly, estadd(y0)
    eststo TableF1a`n'
}        

label var VH_treat "Diff \& p-value"

esttab TableF1a1 TableF1a2 TableF1a3 TableF1a4 TableF1a5 TableF1a6 TableF1a7 TableF1a8 TableF1a9 TableF1a10 using "${tables}/TableF1a", tex replace keep(VH_treat) nostar nogaps noparentheses ///
        b("%9.3f") p("%9.3f") label nonotes stats(y1 y0, labels("Workshop" "No Workshop"))

use "${data}/HHdata_QJPS_labeled.dta", replace

eststo clear
loc indexlist2 female finprim ageHH bornvillage wagelabor VHfam VHethnicmatch ///
    logcattlewealth diffview
loc n 0

foreach index of loc indexlist2 {
    loc ++n
    reg `index' VH_treat, cluster(cc)
    su `index' if VH_treat==1
    roundmeanonly, estadd(y1)
    su `index' if VH_treat==0
    roundmeanonly, estadd(y0)
    eststo TableF1b`n'
}        

label var VH_treat "Diff \& p-value"

esttab TableF1b1 TableF1b2 TableF1b3 TableF1b4 TableF1b5 TableF1b6 TableF1b7 TableF1b8 TableF1b9 using "${tables}/TableF1b", tex replace keep(VH_treat) nostar nogaps noparentheses ///
        b("%9.3f") p("%9.3f") label nonotes stats(y1 y0, labels("Workshop" "No Workshop"))

use "${data}/VHdata_QJPS_labeled.dta", clear

eststo clear

loc indexlist communal numhouseholds numbergroups womenVH moreprimary age ///
    tenure VH_bornvillage logcattlewealth ZANUPF_para
loc n 0

foreach index of loc indexlist {
    loc ++n
    reg `index' cl if VH_treat==1
    su `index' if VH_treat==1 & cl==1
    roundmeanonly, estadd(y1)
    su `index' if VH_treat==1 & cl==0
    roundmeanonly, estadd(y0)
    eststo TableF1c`n'
}        

label var cl "Diff \& p-value"

esttab TableF1c1 TableF1c2 TableF1c3 TableF1c4 TableF1c5 TableF1c6 TableF1c7 TableF1c8 TableF1c9 TableF1c10 using "${tables}/TableF1c", tex replace keep(cl) nostar nogaps noparentheses ///
        b("%9.3f") p("%9.3f") label nonotes stats(y1 y0, labels("VC \& CL" "VC Only"))

use "${data}/HHdata_QJPS_labeled.dta", clear

eststo clear
loc indexlist2 female finprim ageHH bornvillage wagelabor VHfam VHethnicmatch ///
    logcattlewealth diffview
loc n 0

foreach index of loc indexlist2 {
    loc ++n
    reg `index' cl if VH_treat==1, cluster(cc)
    su `index' if VH_treat==1 & cl==1
    roundmeanonly, estadd(y1)
    su `index' if VH_treat==1 & cl==0
    roundmeanonly, estadd(y0)
    eststo TableF1d`n'
}        

label var cl "Diff \& p-value"

esttab TableF1d1 TableF1d2 TableF1d3 TableF1d4 TableF1d5 TableF1d6 TableF1d7 TableF1d8 TableF1d9 using "${tables}/TableF1d", tex replace keep(cl) nostar nogaps noparentheses ///
        b("%9.3f") p("%9.3f") label nonotes stats(y1 y0, labels("VC \& CL" "VC Only"))

******************************
*MAIN RESULTS IN TABULAR FORM*
******************************

**********
*TABLE H1*
**********

use "${data}/VHdata_QJPS_labeled.dta", clear

eststo clear
loc indexlist st_proceduresindex
loc n 0

foreach index of loc indexlist {
    loc ++n
    reg `index' VH_treat cl i.block
    su `index' if VH_treat == 0
    roundmean, estadd(y1)
    estadd loc ob1 = e(N)
    rounding VH_treat, estadd(bse1)
    rounding cl, estadd(bse2)
    lincom _b[VH_treat] + _b[cl]
    roundlincom, estadd(bse3)

    eststo TableH1`n'
}        

esttab using "${tables}/TableH1", tex replace keep(VH_treat) nostar nogaps drop(VH_treat) ///
        b("%9.3f") se("%9.3f") label onecell nonotes stats(y1 bse1 bse3 bse2 ob1, labels("Control Mean" "Effect of Workshop for VC" "Effect of Workshop for VC \& CL" "CL Effect" "N"))

// Proposed changes
eststo clear

evccl st_proceduresindex, by(VH_treat)
esttab using "${tables}/TableH1_new.tex", replace ${stars1}        ///
    cells("mu_0(fmt(%9.3fc)) mu_1(fmt(%9.3fc)) mu_3(fmt(%9.3fc)) mu_2(fmt(%9.3fc)) N_S(fmt(%9.0fc))" "se_0(par) se_1(par) se_3(par) se_2(par)")

************
**TABLE H2**
************

use "${data}/HHdata_QJPS_labeled.dta", clear

// Proposed changes
eststo clear
eststo e1: evccl_diff biasindex if diffview == 1, ///
    by(VH_treat) clus_id(cc) diff(diffview)
esttab e1 using "${tables}/TableH2a_new.tex",  replace ${stars1}        ///
    cells("mu_0(fmt(%9.3fc)) mu_1(fmt(%9.3fc)) mu_3(fmt(%9.3fc)) mu_2(fmt(%9.3fc)) N_S(fmt(%9.0fc))" "se_0(par) se_1(par) se_3(par) se_2(par)")

esttab ,  ${stars1}        ///
    cells("mu_0(fmt(%9.3fc)) mu_1(fmt(%9.3fc)) mu_3(fmt(%9.3fc)) mu_2(fmt(%9.3fc)) N_S(fmt(%9.0fc))" "se_0(par) se_1(par) se_3(par) se_2(par)")

eststo e2: evccl resolvedindex st_legitimacyindex, by(VH_treat) clus_id(cc)
esttab e2 using "${tables}/TableH2b_new.tex",  replace ${stars1}        ///
    cells("mu_0(fmt(%9.3fc)) mu_1(fmt(%9.3fc)) mu_3(fmt(%9.3fc)) mu_2(fmt(%9.3fc)) N_S(fmt(%9.0fc))" "se_0(par) se_1(par) se_3(par) se_2(par)")

// Original
eststo clear

local indexlist biasindex
local n 0

foreach index of loc indexlist {
    loc ++n
    reg `index' VH_treat cl i.block if diffview==1, cluster(cc)
    su `index' if VH_treat == 0 & diffview==1
    roundmean, estadd(y1)
    estadd loc ob1 = e(N)
    rounding VH_treat, estadd(bse1)
    rounding cl, estadd(bse2)
    lincom _b[VH_treat] + _b[cl]
    roundlincom, estadd(bse3)

    eststo TableH2`n'
}    

loc indexlist2 resolvedindex st_legitimacyindex

foreach index of loc indexlist2 {
    loc ++n
    reg `index' VH_treat cl i.block, cluster(cc)
    su `index' if VH_treat == 0
    roundmean, estadd(y1)
    estadd loc ob1 = e(N)
    rounding VH_treat, estadd(bse1)
    rounding cl, estadd(bse2)
    lincom _b[VH_treat] + _b[cl]
    roundlincom, estadd(bse3)

    eststo TableH2`n'
}        

esttab TableH21 TableH22 TableH23 using "${tables}/TableH2", tex replace keep(VH_treat) nostar nogaps drop(VH_treat) ///
         b("%9.3f") se("%9.3f") label onecell nonotes stats(y1 bse1 bse3 bse2 ob1, labels("Control Mean" "Effect of Workshop for VC" "Effect of Workshop for VC \& CL" "CL Effect" "N"))

************
**TABLE H3**
************

use "${data}/HHdata_QJPS_labeled.dta", clear

// Proposed changes
eststo clear
eststo e1: evccl_diff biasindex food_aid mostfair if diffview == 1, ///
    by(VH_treat) clus_id(cc) diff(diffview)
esttab e1 using "${tables}/TableH3a_new.tex",  replace ${stars1}        ///
    cells("mu_0(fmt(%9.3fc)) mu_1(fmt(%9.3fc)) mu_3(fmt(%9.3fc)) mu_2(fmt(%9.3fc)) N_S(fmt(%9.0fc))" "se_0(par) se_1(par) se_3(par) se_2(par)")

eststo e2: evccl resolvedindex nofoodaidneed noconflicts, ///
    by(VH_treat) clus_id(cc)
esttab e2 using "${tables}/TableH3b_new.tex",  replace ${stars1}        ///
    cells("mu_0(fmt(%9.3fc)) mu_1(fmt(%9.3fc)) mu_3(fmt(%9.3fc)) mu_2(fmt(%9.3fc)) N_S(fmt(%9.0fc))" "se_0(par) se_1(par) se_3(par) se_2(par)")

// Original

eststo clear

loc indexlist biasindex food_aid mostfair
loc n 0

foreach index of loc indexlist {
    loc ++n
    reg `index' VH_treat cl i.block if diffview==1, cluster(cc)
    su `index' if VH_treat == 0 & diffview==1
    roundmean, estadd(y1)
    estadd loc ob1 = e(N)
    rounding VH_treat, estadd(bse1)
    rounding cl, estadd(bse2)
    lincom _b[VH_treat] + _b[cl]
    roundlincom, estadd(bse3)

    eststo TableH3`n'
}        

loc indexlist2 resolvedindex nofoodaidneed noconflicts

foreach index of loc indexlist2 {
    loc ++n
    reg `index' VH_treat cl i.block, cluster(cc)
    su `index' if VH_treat == 0
    roundmean, estadd(y1)
    estadd loc ob1 = e(N)
    rounding VH_treat, estadd(bse1)
    rounding cl, estadd(bse2)
    lincom _b[VH_treat] + _b[cl]
    roundlincom, estadd(bse3)

    eststo TableH3`n'
}        

esttab TableH31 TableH32 TableH33 TableH34 TableH35 TableH36 using "${tables}/TableH3", tex replace keep(VH_treat) nostar nogaps drop(VH_treat) ///
         b("%9.3f") se("%9.3f") label onecell nonotes stats(y1 bse1 bse3 bse2 ob1, labels("Control Mean" "Effect of Workshop for VC" "Effect of Workshop for VC \& CL" "CL Effect" "N"))

************
**TABLE H4**
************

use "${data}/VHdata_QJPS_labeled.dta", clear

loc indexlist testknowledge testattitudes st_proceduresindex
loc n 0

// Proposed changes
eststo clear
evccl_diff testknowledge testattitudes st_proceduresindex if closehat_di ///
    == 0, by(VH_treat)
esttab using "${tables}/TableH4a_new", replace ${stars1}        ///
    cells("mu_0(fmt(%9.3fc)) mu_1(fmt(%9.3fc)) mu_3(fmt(%9.3fc)) mu_2(fmt(%9.3fc)) N_S(fmt(%9.0fc))" "se_0(par) se_1(par) se_3(par) se_2(par)")

// Original
foreach index of loc indexlist {
    loc ++n
    reg `index' VH_treat cl i.block if closehat_di==0
    su `index' if VH_treat == 0 & closehat_di==0
    roundmean, estadd(y1)
    estadd loc ob1 = e(N)
    rounding VH_treat, estadd(bse1)
    rounding cl, estadd(bse2)
    lincom _b[VH_treat] + _b[cl]
    roundlincom, estadd(bse3)

    eststo TableH4a`n'
}        

use "${data}/HHdata_QJPS_labeled.dta", clear

local indexlist2 biasindex

foreach index of loc indexlist2 {
    loc ++n
    reg `index' VH_treat cl i.block if closehat_di==0 & diffview==1, ///
        cluster(cc)
    su `index' if VH_treat == 0 & closehat_di==0 & diffview==1
    roundmean, estadd(y1)
    estadd loc ob1 = e(N)
    rounding VH_treat, estadd(bse1)
    rounding cl, estadd(bse2)
    lincom _b[VH_treat] + _b[cl]
    roundlincom, estadd(bse3)

    eststo TableH4a`n'
}        

local indexlist3 st_legitimacyindex

foreach index of loc indexlist3 {
    loc ++n
    reg `index' VH_treat cl i.block if closehat_di==0, cluster(cc)
    su `index' if VH_treat == 0 & closehat_di==0
    roundmean, estadd(y1)
    estadd loc ob1 = e(N)
    rounding VH_treat, estadd(bse1)
    rounding cl, estadd(bse2)
    lincom _b[VH_treat] + _b[cl]
    roundlincom, estadd(bse3)

    eststo TableH4a`n'
}        

// Proposed changes
eststo clear
evccl_diff biasindex if closehat_di == 0 & diffview == 1, ///
    by(VH_treat) clus_id(cc)
esttab using "${tables}/TableH4b_new", replace ${stars1}        ///
    cells("mu_0(fmt(%9.3fc)) mu_1(fmt(%9.3fc)) mu_3(fmt(%9.3fc)) mu_2(fmt(%9.3fc)) N_S(fmt(%9.0fc))" "se_0(par) se_1(par) se_3(par) se_2(par)")

eststo clear
evccl_diff st_legitimacyindex if closehat_di == 0, by(VH_treat)    clus_id(cc) 
esttab using "${tables}/TableH4c_new", replace ${stars1}        ///
    cells("mu_0(fmt(%9.3fc)) mu_1(fmt(%9.3fc)) mu_3(fmt(%9.3fc)) mu_2(fmt(%9.3fc)) N_S(fmt(%9.0fc))" "se_0(par) se_1(par) se_3(par) se_2(par)")

// Original
esttab TableH4a1 TableH4a2 TableH4a3 TableH4a4 TableH4a5 using "${tables}/TableH4a", tex replace keep(VH_treat) nostar nogaps drop(VH_treat) ///
         b("%9.3f") se("%9.3f") onecell nonotes stats(y1 bse1 bse3 bse2 ob1, labels("Control Mean" "Effect of Workshop for VC" "Effect of Workshop for VC \& CL" "CL Effect" "N"))

use "${data}/VHdata_QJPS_labeled.dta", clear         
         
loc indexlist testknowledge testattitudes st_proceduresindex
loc n 0

foreach index of loc indexlist {
    loc ++n
    reg `index' VH_treat cl i.block if closehat_di==1
    su `index' if VH_treat == 0 & closehat_di==1
    roundmean, estadd(y1)
    estadd loc ob1 = e(N)
    rounding VH_treat, estadd(bse1)
    rounding cl, estadd(bse2)
    lincom _b[VH_treat] + _b[cl]
    roundlincom, estadd(bse3)

    eststo TableH4b`n'
}        

// Proposed changes
eststo clear
evccl_diff testknowledge testattitudes st_proceduresindex if closehat_di ///
    == 1, by(VH_treat)
esttab using "${tables}/TableH4a2_new", replace ${stars1}        ///
    cells("mu_0(fmt(%9.3fc)) mu_1(fmt(%9.3fc)) mu_3(fmt(%9.3fc)) mu_2(fmt(%9.3fc)) N_S(fmt(%9.0fc))" "se_0(par) se_1(par) se_3(par) se_2(par)")

use "${data}/HHdata_QJPS_labeled.dta", clear

local indexlist2 biasindex

foreach index of loc indexlist2 {
    loc ++n
    reg `index' VH_treat cl i.block if closehat_di==1 & diffview==1, ///
        cluster(cc)
    su `index' if VH_treat == 0 & closehat_di==1 & diffview==1
    roundmean, estadd(y1)
    estadd loc ob1 = e(N)
    rounding VH_treat, estadd(bse1)
    rounding cl, estadd(bse2)
    lincom _b[VH_treat] + _b[cl]
    roundlincom, estadd(bse3)

    eststo TableH4b`n'
}        

// Proposed changes
eststo clear
evccl_diff biasindex if closehat_di == 1 & diffview == 1, ///
    by(VH_treat) clus_id(cc)
esttab using "${tables}/TableH4b2_new", replace ${stars1}        ///
    cells("mu_0(fmt(%9.3fc)) mu_1(fmt(%9.3fc)) mu_3(fmt(%9.3fc)) mu_2(fmt(%9.3fc)) N_S(fmt(%9.0fc))" "se_0(par) se_1(par) se_3(par) se_2(par)")

local indexlist3 st_legitimacyindex

foreach index of loc indexlist3 {
    loc ++n
    reg `index' VH_treat cl i.block if closehat_di==1, cluster(cc)
    su `index' if VH_treat == 0 & closehat_di==1
    roundmean, estadd(y1)
    estadd loc ob1 = e(N)
    rounding VH_treat, estadd(bse1)
    rounding cl, estadd(bse2)
    lincom _b[VH_treat] + _b[cl]
    roundlincom, estadd(bse3)

    eststo TableH4b`n'
}        

// Proposed changes
eststo clear
evccl_diff st_legitimacyindex if closehat_di == 1, by(VH_treat) clus_id(cc)
esttab using "${tables}/TableH4c2_new", replace ${stars1}        ///
    cells("mu_0(fmt(%9.3fc)) mu_1(fmt(%9.3fc)) mu_3(fmt(%9.3fc)) mu_2(fmt(%9.3fc)) N_S(fmt(%9.0fc))" "se_0(par) se_1(par) se_3(par) se_2(par)")

esttab TableH4b1 TableH4b2 TableH4b3 TableH4b4 TableH4b5 using "${tables}/TableH4b", tex replace keep(VH_treat) nostar nogaps drop(VH_treat) ///
         b("%9.3f") se("%9.3f") onecell nonotes stats(y1 bse1 bse3 bse2 ob1, labels("Control Mean" "Effect of Workshop for VC" "Effect of Workshop for VC \& CL" "CL Effect" "N"))

***************
**APPENDIX I.1*
***************

use "${data}/VHdata_QJPS_labeled.dta", clear

eststo clear

loc indexlist st_proceduresindex percwomendare consult_women consult_RMC ///
    transparency nofee
loc n 0

foreach index of loc indexlist {
    loc ++n
    reg `index' VH_treat cl i.block
    su `index' if VH_treat == 0
    roundmean, estadd(y1)
    estadd loc ob1 = e(N)
    rounding VH_treat, estadd(bse1)
    rounding cl, estadd(bse2)
    lincom _b[VH_treat] + _b[cl]
    roundlincom, estadd(bse3)

    eststo TableI1`n'
}        

esttab TableI11 TableI12 TableI13 TableI14 TableI15 TableI16 using "${tables}/TableI1", tex replace keep(VH_treat) nostar nogaps drop(VH_treat) ///
         b("%9.3f") se("%9.3f") label onecell nonotes stats(y1 bse1 bse3 bse2 ob1, labels("Control Mean" "Effect of Workshop for VC" "Effect of Workshop for VC \& CL" "CL Effect" "N"))

// Proposed changes
eststo clear
evccl st_proceduresindex percwomendare consult_women consult_RMC transparency ///
    nofee, by(VH_treat)
esttab using "${tables}/TableI1_new", replace ${stars1}        ///
    cells("mu_0(fmt(%9.3fc)) mu_1(fmt(%9.3fc)) mu_3(fmt(%9.3fc)) mu_2(fmt(%9.3fc)) N_S(fmt(%9.0fc))" "se_0(par) se_1(par) se_3(par) se_2(par)")

***************
**APPENDIX I.2*
***************

use "${data}/CLdata_QJPS_labeled.dta", clear

sum st_procedures_indexCL if VH_treat==0
reg st_procedures_indexCL VH_treat cl i.block
lincom _b[VH_treat] + _b[cl]

eststo clear

loc indexlist st_procedures_indexCL
loc n 0

foreach index of loc indexlist {
    loc ++n
    reg `index' VH_treat cl i.block
    su `index' if VH_treat == 0
    roundmean, estadd(y1)
    estadd loc ob1 = e(N)
    rounding VH_treat, estadd(bse1)
    rounding cl, estadd(bse2)
    lincom _b[VH_treat] + _b[cl]
    roundlincom, estadd(bse3)

    eststo TableI2`n'
}        

// Proposed changes
eststo clear
evccl st_procedures_indexCL, by(VH_treat) 
esttab using "${tables}/TableI2a_new", replace ${stars1}        ///
    cells("mu_0(fmt(%9.3fc)) mu_1(fmt(%9.3fc)) mu_3(fmt(%9.3fc)) mu_2(fmt(%9.3fc)) N_S(fmt(%9.0fc))" "se_0(par) se_1(par) se_3(par) se_2(par)")

use "${data}/VHdata_QJPS_labeled.dta", clear

sum st_diversity_index if VH_treat==0
reg st_diversity_index VH_treat cl i.block
lincom _b[VH_treat] + _b[cl]

local indexlist2 st_diversity_index 

foreach index of loc indexlist2 {
    loc ++n
    reg `index' VH_treat cl i.block
    su `index' if VH_treat == 0
    roundmean, estadd(y1)
    estadd loc ob1 = e(N)
    rounding VH_treat, estadd(bse1)
    rounding cl, estadd(bse2)
    lincom _b[VH_treat] + _b[cl]
    roundlincom, estadd(bse3)

    eststo TableI2`n'
}        

 // Proposed changes
eststo clear
evccl st_diversity_index, by(VH_treat) 
esttab using "${tables}/TableI2b_new", replace ${stars1}        ///
    cells("mu_0(fmt(%9.3fc)) mu_1(fmt(%9.3fc)) mu_3(fmt(%9.3fc)) mu_2(fmt(%9.3fc)) N_S(fmt(%9.0fc))" "se_0(par) se_1(par) se_3(par) se_2(par)")

esttab TableI21 TableI22 using "${tables}/TableI2", tex replace keep(VH_treat) nostar nogaps drop(VH_treat) ///
         b("%9.3f") se("%9.3f") label onecell nonotes stats(y1 bse1 bse3 bse2 ob1, labels("Control Mean" "Effect of Workshop for VC" "Effect of Workshop for VC \& CL" "CL Effect" "N"))

**************
*APPENDIX I.3*
**************

use "${data}/HHdata_QJPS_labeled.dta", clear

eststo clear

local indexlist st_legitimacyindex trust relationship compliance livestocktoVH
local n 0

foreach index of loc indexlist {
    loc ++n
    reg `index' VH_treat cl i.block, cluster(cc)
    su `index' if VH_treat == 0
    roundmean, estadd(y1)
    estadd loc ob1 = e(N)
    rounding VH_treat, estadd(bse1)
    rounding cl, estadd(bse2)
    lincom _b[VH_treat] + _b[cl]
    roundlincom, estadd(bse3)

    eststo TableI3`n'
}        

 // Proposed changes
eststo clear
evccl st_legitimacyindex trust relationship compliance livestocktoVH, ///
    by(VH_treat)
esttab using "${tables}/TableI3_new", replace ${stars1}        ///
    cells("mu_0(fmt(%9.3fc)) mu_1(fmt(%9.3fc)) mu_3(fmt(%9.3fc)) mu_2(fmt(%9.3fc)) N_S(fmt(%9.0fc))" "se_0(par) se_1(par) se_3(par) se_2(par)")

esttab TableI31 TableI32 TableI33 TableI34 TableI35 using "${tables}/TableI3", tex replace keep(VH_treat) nostar nogaps drop(VH_treat) ///
         b("%9.3f") se("%9.3f") label onecell nonotes stats(y1 bse1 bse3 bse2 ob1, labels("Control Mean" "Effect of Workshop for VC" "Effect of Workshop for VC \& CL" "CL Effect" "N"))

*****************
**APPENDIX I.4 **
*****************

use "${data}/HHdata_QJPS_labeled.dta", replace

// 1st column
eststo clear
eststo reg1: reg diffview VH_treat cl, cluster(cc)
estadd scalar p_diff = e(F)
outreg2 using "${tables}/tableI4", ///
    replace tex(frag) se label nonotes noaster nor2 nocons

// 2nd column
local balance female finprim bornvillage wagelabor VHfam VHethnicmatch ///
    ageHH logcattlewealth

foreach var in `balance' {
    gen `var'XVH = `var'*VH_treat
    gen `var'XCL = `var'*cl
    loc vlist `vlist' `var'XVH `var'XCL
}

eststo reg2: reg diffview VH_treat cl `vlist' `balance', cluster(cc)
outreg2 using "${tables}/tableI4", ///
    append tex(frag) drop(`balance') se label nonotes noaster nor2 nocons

test VH_treat cl `vlist'
estadd scalar p_diff = r(p)

// Fix labels for the table
local balance female finprim bornvillage wagelabor VHfam VHethnicmatch ///
    ageHH logcattlewealth
foreach var in `balance' {
    local label : variable label `var'
    display "`label'"
    label variable `var'XVH "`label' $\times$ VC"
    label variable `var'XCL "`label' $\times$ CL"
}

label var VH_treat    "Effect of Workshop on VC"
label var cl         "Effect of CL"

esttab reg1 reg2 using "${tables}/tableI4_new.tex", ///
    replace keep(VH_treat cl `vlist') ${stars3} scalars("p_diff P-value from T-test")

*************
**APPENDIX J*
*************

**********
*TABLE J1*
**********

use "${data}/VHdata_QJPS_labeled.dta", clear

// Fix labels
label var parentsherewhenborn"VC Born in Village"

// Regression
eststo clear 
eststo reg1: logit close vehicles notfarminginc moreprimary parentsherewhenborn ///
    if cl==1
estat classification, cutoff(0.35)
estadd scalar corr = r(P_corr)

// Export
esttab using "${tables}/tableJ1_new.tex", ///
    replace ${stars3} scalars("corr PCC (0.35 cutoff)")
outreg2 using "${tables]/tableJ1", replace tex(frag) auto(2) se label noaster nor2 nonote

******************************
*APPENDIX K: MECHANISMS TABLE*
******************************

**********
*TABLE K1*
**********

use "${data}/VHdata_QJPS_labeled.dta", clear

sum indepgovt2 if VH_treat==0
reg indepgovt2 VH_treat cl i.block 
lincom _b[VH_treat] + _b[cl]

eststo clear

loc indexlist indepgovt2
loc n 0

foreach index of loc indexlist {
    loc ++n
    reg `index' VH_treat cl i.block
    su `index' if VH_treat == 0
    roundmean, estadd(y1)
    estadd loc ob1 = e(N)
    rounding VH_treat, estadd(bse1)
    rounding cl, estadd(bse2)
    lincom _b[VH_treat] + _b[cl]
    roundlincom, estadd(bse3)

    eststo TableK1`n'
}        

use "${data}/HHdata_QJPS_labeled.dta", replace

local indexlist2 testknowledgeHH raisedissue

foreach index of loc indexlist2 {
    loc ++n
    reg `index' VH_treat cl i.block, cluster(cc)
    su `index' if VH_treat == 0
    roundmean, estadd(y1)
    estadd loc ob1 = e(N)
    rounding VH_treat, estadd(bse1)
    rounding cl, estadd(bse2)
    lincom _b[VH_treat] + _b[cl]
    roundlincom, estadd(bse3)

    eststo TableK1`n'
}        

use "${data}/CLdata_QJPS_labeled.dta", clear

local indexlist3 testknowledgeCL logexchangeinfo

foreach index of loc indexlist3 {
    loc ++n
    reg `index' VH_treat cl i.block if dare!=1
    su `index' if VH_treat == 0 & dare!=1
    roundmean, estadd(y1)
    estadd loc ob1 = e(N)
    rounding VH_treat, estadd(bse1)
    rounding cl, estadd(bse2)
    lincom _b[VH_treat] + _b[cl]
    roundlincom, estadd(bse3)

    eststo TableK1`n'
}        

esttab TableK11 TableK12 TableK13 TableK14 TableK15 using "${tables}/TableK1", tex replace keep(VH_treat) label nostar nogaps drop(VH_treat) ///
         b("%9.3f") se("%9.3f") onecell nonotes stats(y1 bse1 bse3 bse2 ob1, labels("Control Mean" "Effect of Workshop for VC" "Effect of Workshop for VC \& CL" "CL Effect" "N"))

**********
*TABLE K2*
**********

use "${data}/VHdata_QJPS_labeled.dta", clear

eststo clear
by moreprimary, sort: eststo: regress testknowledge VH_treat cl i.block
esttab using "${tables}/TableK2a", ///
    tex replace keep(cl) label nostar nogaps nonotes b("%9.3f") se("%9.3f")

eststo clear
by moreprimary, sort: eststo: regress st_proceduresindex VH_treat cl i.block
esttab using "${tables}/TableK2b", ///
    tex replace keep(cl) label nostar nogaps nonotes b("%9.3f") se("%9.3f")

use "${data}/HHdata_QJPS_labeled.dta", clear

eststo clear
by moreprimary, sort: eststo: regress biasindex VH_treat cl i.block if ///
    diffview==1, cluster(cc)
esttab using "${tables}/TableK2c", ///
    tex replace keep(cl) nostar label nogaps nonotes b("%9.3f") se("%9.3f")

eststo clear
by moreprimary, sort: eststo: regress st_legitimacyindex VH_treat cl i.block, ///
    cluster(cc)
esttab using "${tables}/TableK2d", ///
    tex replace keep(cl) nostar label nogaps nonotes b("%9.3f") se("%9.3f")

**********
*TABLE K3*
**********

use "${data}/VHdata_QJPS_labeled.dta", clear

eststo clear
by ccount, sort: eststo: regress testknowledge VH_treat cl i.block
esttab using "${tables}/TableK3a", ///
    tex replace keep(cl) nostar label nogaps nonotes b("%9.3f") se("%9.3f")

eststo clear
by ccount, sort: eststo: regress st_proceduresindex VH_treat cl i.block
esttab using "${tables}/TableK3b", ///
    tex replace keep(cl) nostar label nogaps nonotes b("%9.3f") se("%9.3f")

use "${data}/HHdata_QJPS_labeled.dta", clear

eststo clear
by ccount, sort: eststo: regress biasindex VH_treat cl i.block if diffview==1, ///
    cluster(cc)
esttab using "${tables}/TableK3c", ///
    tex replace keep(cl) nostar label nogaps nonotes b("%9.3f") se("%9.3f")

eststo clear
by ccount, sort: eststo: regress st_legitimacyindex VH_treat cl i.block, ///
    cluster(cc)
esttab using "${tables}/TableK3d", ///
    tex replace keep(cl) nostar label nogaps nonotes b("%9.3f") se("%9.3f")

**********
*TABLE K4*
**********

use "${data}/HHdata_QJPS_labeled.dta", clear

eststo clear
by diffview, sort: eststo: regress biasindex VH_treat cl i.block
esttab using "${tables}/TableK4a", ///
    tex replace keep(cl) nostar nogaps label nonotes b("%9.3f") se("%9.3f")

eststo clear
by diffview, sort: eststo: regress st_legitimacyindex VH_treat cl i.block
esttab using "${tables}/TableK4b", ///
    tex replace keep(cl) nostar nogaps label nonotes b("%9.3f") se("%9.3f")

***********************************************
*APPENDIX L: COMPARISON WITH PRE-ANALYSIS PLAN*
***********************************************

***********
*TABLE L.2*
***********

use "${data}/VHdata_QJPS_labeled.dta", clear

eststo clear

local n 0
local indexlist st_knowledge_index st_attitude_index st_legitimacyVH_index

foreach index of loc indexlist {
    loc ++n
    reg `index' VH_treat cl
    su `index' if VH_treat == 0
    roundmean, estadd(y1)
    estadd loc ob1 = e(N)
    rounding VH_treat, estadd(bse1)
    rounding cl, estadd(bse2)
    lincom _b[VH_treat] + _b[cl]
    roundlincom, estadd(bse3)

    eststo TableL2`n'
}        

esttab TableL21 TableL22 TableL23 using "${tables}/TableL2", tex replace keep(VH_treat) label nostar nogaps drop(VH_treat) ///
     b("%9.3f") se("%9.3f") onecell nonotes stats(y1 bse1 bse3 bse2 ob1, labels("Control Mean" "Effect of Workshop for VC" "Effect of Workshop for VC \& CL" "CL Effect" "N"))

**********
*TABLE L3*
**********

*Village Head's Impartiality*
*% of respondents who know of people being excluded from food aid lists (as calculated from list experiment)

use "${data}/HHdata_QJPS_labeled.dta", clear

preserve

    keep F2_est VH_treat cl cc

    collapse F2_est VH_treat cl, by(cc)

    reg F2_est if VH_treat==0
    reg F2_est VH_treat cl
    lincom _b[VH_treat] + _b[cl]

    eststo clear

    local n 0

    local indexlist F2_est

    foreach index of loc indexlist {
        loc ++n
        reg `index' VH_treat cl
        su `index' if VH_treat == 0
        roundmean, estadd(y1)
        estadd loc ob1 = e(N)
        rounding VH_treat, estadd(bse1)
        rounding cl, estadd(bse2)
        lincom _b[VH_treat] + _b[cl]
        roundlincom, estadd(bse3)

        eststo TableL3`n'
    }    

restore

*% of respondents who say most of outcomes from taking disputes to the village head are fair

use "${data}/HHdata_QJPS_labeled.dta", clear

local indexlist2 mostfair st_legitimacyindex

foreach index of loc indexlist2 {
    loc ++n
    reg `index' VH_treat cl, cluster(cc)
    su `index' if VH_treat == 0
    roundmean, estadd(y1)
    estadd loc ob1 = e(N)
    rounding VH_treat, estadd(bse1)
    rounding cl, estadd(bse2)
    lincom _b[VH_treat] + _b[cl]
    roundlincom, estadd(bse3)

    eststo TableL3`n'
}        

local indexlist3 food_aid assistance

foreach index of loc indexlist3 {
    loc ++n
    reg `index' VH_treat cl if diffview==1, cluster(cc)
    su `index' if VH_treat == 0 & diffview==1
    roundmean, estadd(y1)
    estadd loc ob1 = e(N)
    rounding VH_treat, estadd(bse1)
    rounding cl, estadd(bse2)
    lincom _b[VH_treat] + _b[cl]
    roundlincom, estadd(bse3)

    eststo TableL3`n'
}        

foreach index of loc indexlist3 {
    loc ++n
    reg `index' VH_treat cl if VHfam==0, cluster(cc)
    su `index' if VH_treat == 0 & VHfam==0
    roundmean, estadd(y1)
    estadd loc ob1 = e(N)
    rounding VH_treat, estadd(bse1)
    rounding cl, estadd(bse2)
    lincom _b[VH_treat] + _b[cl]
    roundlincom, estadd(bse3)

    eststo TableL3`n'
}        

esttab TableL31 TableL32 TableL34 TableL35 TableL36 TableL37 TableL33 using "${tables}/TableL3", tex replace keep(VH_treat) nostar nogaps drop(VH_treat) ///
     b("%9.3f") se("%9.3f") onecell label nonotes stats(y1 bse1 bse3 bse2 ob1, labels("Control Mean" "Effect of Workshop for VC" "Effect of Workshop for VC \& CL" "CL Effect" "N"))

**********
*TABLE L4*
**********

*Effect of wealth on likelihood of receiving food aid, maize seed or grain loans

gen VHXwealth = VH_treat*logcattlewealth
gen CLXwealth = cl*logcattlewealth

reg assistance VH_treat cl logcattlewealth VHXwealth CLXwealth, cluster(cc)
lincom _b[VHXwealth] + _b[CLXwealth]

eststo clear

loc indexlist assistance
loc n 0

foreach index of loc indexlist {
    loc ++n
    reg `index' VH_treat cl logcattlewealth VHXwealth CLXwealth, cluster(cc)
    rounding logcattlewealth, estadd(bse0)
    estadd loc ob1 = e(N)
    rounding VHXwealth, estadd(bse1)
    rounding CLXwealth, estadd(bse2)
    lincom _b[VHXwealth] + _b[CLXwealth]
    roundlincom, estadd(bse3)

    eststo TableL4`n'
}        

esttab using "${tables}/TableL4", tex replace keep(VH_treat) nostar nogaps drop(VH_treat) ///
        b("%9.3f") se("%9.3f") onecell label nonotes stats(bse0 bse1 bse3 bse2 ob1, labels("Effect of Wealth" "Additional Effect of Wealth by VC Workshop" "Additional Effect of Wealth by VC \& CL Workshop" "Additional Effect of Wealth by CL" "N"))

