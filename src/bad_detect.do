* Style rules =====================
* Hard tabs should not be used
* Indices in for loop should be concrete (shouldn't be like "ii")
* Use "!missing(var)" instead of "var != ."
* "delimit" should not be used
* In brackets after "for" or "if", indentation should be used
* Don't use "cd": use absolute and dynamic file paths
* Too long lines should not be used
* Use explicit condition for if statement (use "if var == 1" instead of "if var")
* For global macro, use brackets ("${global}" instead of "$global")

* Style check =====================
* If "a != 0" is used, warn that this includes cases where a is missing
* Backslash in a file path should be avoided
* Bang "!" should be used instead of tilde "~" for negation

* Stata codes to be checked =================

* Hard tabs are used

	* Abstract index is used in for loop
	foreach ii in potato cassava maize { 
		do something
	} 

	* "var != ." is used
	if something != 1 & something != . { 
		do something
	} 

	* "delimit" is used
	#delimit ;
	if something something something something something something { ;
		do something ;
	} ;
	#delimit cr

	* Not proper indentation in brackets after "for" or "if"
	if something != 1 & something != . {
	do something
	foreach crop in potato maize cassava {
	do that
	} 
	}
	
	* "cd" is used
	cd "/path/to/myproject/"

	* Line is too long
	local a = asodfas as[odifgaj sdkjf  asodif asl;kdjf a;sdigfuas ;dlfkjasda;sldiufasodfas as[odifgaj sdkjf  asodif asl;kdjf a;sdigfuas ;dlfkjasda;sldiuf 

	* Condition is not explicit
	if something {
		do something
	}

	* No curly brackets for global macro
	global folder "/path/to/myproject"
	cd $folder


	* "a ~= 0" is used
	if something ~= 1{
		do something
	} 

  * Backslash may be used in a file path
	global folder "\path\to\myproject"



/*


	if something ~= 1 & something != .{
	do something
	} 


*/


