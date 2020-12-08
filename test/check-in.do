/*******************************************************************************
* 			Demand for "Safe Spaces": Avoiding Harassment and Stigma		   *
*   				   Clean baseline survey check-in task				  	   *
********************************************************************************

	** REQUIRES:	${dt_raw}\baseline_raw_deidentified.dta
					${doc_rider}/baseline-study/codebooks/check_in.xlsx
	** CREATES:	  	${dt_int}\baseline_ci.dta
							
	** WRITEN BY:  Astrid Zwager and Luiza Andrade
	
********************************************************************************
	Load data set and keep check-in variables
*******************************************************************************/

	use "${dt_raw}/baseline_raw_deidentified.dta", clear

	sort 	user_uuid session
	
	* only keep entries that refer to check-in task	
	keep if   entity_uuid 	 == "90326264-a9d6-4b69-9b86-1e4df2841957" /// PHASE 1
			| entity_uuid 	 == "977c6d5a-1196-4be4-bf09-814183c302a2" /// PHASE 2
			| entity_uuid 	 == "56ea3b3a-8287-41c6-bb89-42cd-72c827e2"  /// PHASE 3
			| spectranslated == "Checkin"
		
/*******************************************************************************
	Encode variables
*******************************************************************************/

	* Rides phase 
	gen 	phase = .
	replace phase = 1 		if (entity_uuid == "90326264-a9d6-4b69-9b86-1e4df2841957")
	replace phase = 2 		if (entity_uuid == "977c6d5a-1196-4be4-bf09-814183c302a2")
	replace phase = 3 		if (entity_uuid == "56ea3b3a-8287-41c6-bb89-42cd-72c827e2") 
	
	* Premium offered 
	split campaign_id, p("_")
	
	gen 	premium = 0
	replace premium = 5  	if (campaign_id3 == "5ctPremium")
	replace premium = 10 	if (campaign_id3 == "10ctPremium")
	replace premium = 20 	if (campaign_id3 == "Premium")
	replace premium = 40 	if (campaign_id3 == "SuperPremium")
	
	* dummy for women only car
	encode car, gen(CI_women_car)
					
	* Dummy for coming from/going to or looking for work
	* (the raw data uses different names for the same question in different rides)
	gen 	CI_work = inlist("Sim", sv_looking_for_work, work_or_looking) if (!missing(work_or_looking) | !missing(sv_looking_for_work))
	
		
/*******************************************************************************
	Clean up and save
*******************************************************************************/
	
	isid 	session
	order 	user_uuid session phase user_line user_station user_feeling ///
			premium CI_women_car CI_work
	
	iecodebook apply using "${doc_rider}/baseline-study/codebooks/check_in.xlsx", drop
	
	compress
	dropmiss, force
	
	save 				"${dt_int}/baseline_ci.dta", replace
	iemetasave using 	"${dt_int}/baseline_ci.txt", replace

****************************** End of do-file **********************************
