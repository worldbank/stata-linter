/*******************************************************************************
* 			Demand for "Safe Spaces": Avoiding Harassment and Stigma		   *
*   				       Clean baseline exit survey				  	   	   *
********************************************************************************

	* REQUIRES:	  ${dt_raw}/baseline_raw_deidentified.dta
				  ${doc_rider}/baseline-study/codebooks/exit.xlsx
	* CREATES:	  ${dt_int}/baseline_exit.dta
	
	* WRITEN BY:  Astrid Zwager [azwager@worldbank.org]	

********************************************************************************
	Load data set and keep exit variables
*******************************************************************************/

  use "${dt_raw}/baseline_raw_deidentified.dta", clear

  * Only keep entries that refer to check-in task    
  keep if entity_uuid == "8d8db685-c7f6-4d32-a6ca-8f46b8ac5c2c" 
  
  * Keep only questions answered during this task  
  keep   user_uuid sv_preference option* assured_male_free ///
      price_option* advantages_sv_open disadvantages_sv_open percent* *_cons*
  
/*******************************************************************************
	Encode variables
*******************************************************************************/

  * Hypotetical take-up
  encode sv_preference,     gen(pref_nocompl)
  encode assured_male_free, gen(pref_fullcompl)
  
  * Stated WTP
  forvalues choice = 1/4 {
      encode option_`choice',     g(nocomp_pref`choice') // preference under current situation
      encode price_option_`choice', ///
          g(fullcomp_pref`choice') //stated under perfect compliance
  } 

  * harassment in mixed car
  encode percent_assault_mixed, gen(comments_mixed)
  encode percent_touched_mixed, gen(grope_mixed)
  
  * Harassment in pink car
  encode percent_comments_fem, gen(comments_pink)
  encode percent_touched_fem, gen(grope_pink)
  
  * Harassment in mixed car -- at central station
  encode percent_comment_centralmixed, gen(comments_mixed_central)
  encode percent_touched_centralmixed, gen(grope_mixed_central)
  
  * Harassment in female car -- at central station
  encode percent_femcentral_comments, gen(comments_pink_central)
  encode percent_femcentral_touched, gen(grope_pink_central)
  
  * Create consent variables
  foreach var of varlist *_con* {
    
      local    newname  = subinstr("`var'", "percent_", "", .)    
      gen    `newname' = (`var' == "Sim") if !missing(`var')
  }  
  
/*******************************************************************************
	Clean up and save
*******************************************************************************/

  iecodebook apply using "${doc_rider}/baseline-study/codebooks/exit.xlsx", ///
      drop

   order   user_uuid advantage_pink disadvantage_pink ///
      pref_nocompl nocomp_pref0 nocomp_pref5 nocomp_pref10 nocomp_pref20 ///
      pref_fullcompl fullcomp_pref0 fullcomp_pref5 fullcomp_pref10 ///
      fullcomp_pref20 ///
      comments_mixed_consent comments_pink_consent comments_mixed_central_consent ///
      comments_pink_central_consent comments_mixed comments_pink ///
      comments_mixed_central comments_pink_central grope_mixed_consent ///
      grope_pink_consent grope_mixed_central_consent grope_pink_central_consent ///
      grope_mixed grope_pink grope_mixed_central grope_pink_central
   
  save         "${dt_int}/baseline_exit.dta", replace
  iemetasave using   "${dt_int}/baseline_exit.txt", replace

****************************** End of do-file **********************************

