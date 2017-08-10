
********************************
* Before running,
* 1. run i1_empl_good.do
* 2. run tariff_assign.do

* After running,
* 1. run i1_sample.do
********************************

* date
local d "121031"
clear all
set more off
cd c:\mypaper\1203\ifls1


* Household Income in 1993

*******************
** Farm business
*******************
use C:\Mydata\IFLS\IFLS1\hh93dta\buk2ut1, clear
gen farm_own = ut02==1
recode farm_own (.=0)
replace farm_own = ut03/100 if farm_own==0 & ut03~=.	// partial owners
gen owners = ut05
gen nowner = length(ut05)
qui sum nowner
forval i=1/`r(max)' {
	gen farm_owner`i' = substr(ut05,`i',1)
	}
recode ut0?b1 (99999996/99999999=.)
gen farm_ginc = ut07b1
gen farm_exp = ut08b1
gen farm_ninc = ut09b1
replace farm_ninc = farm_ginc-farm_exp if farm_ninc==.
gen farm_inc = farm_ginc
replace farm_inc = farm_ninc if farm_inc==.
keep hhid93 farm_*
drop if hhid93=="2150700"	// not registered in roster
save c:\mypaper\1203\ifls1\i1_farm_business, replace


***********************
** Non-farm business
***********************
use C:\Mydata\IFLS\IFLS1\hh93dta\buk2nt1, clear
gen nfarm_own = nt02==1
recode nfarm_own (.=0)
replace nfarm_own = nt03/100 if nfarm_own==0 & nt03~=.	// partial owners
gen owners = nt05
gen nowner = length(nt05)
qui sum nowner
forval i=1/`r(max)' {
	gen nfarm_owner`i' = substr(nt05,`i',1)
	}
recode nt0?b1 (99999996/99999999=.)
gen nfarm_ginc = nt07b1
gen nfarm_exp = nt08b1
gen nfarm_ninc = nt09b1
gen nfarm_inc = nfarm_ginc
replace nfarm_inc = nfarm_ninc if nfarm_inc==.
keep hhid93 nfarm_*
drop if hhid93=="2150700"	// not registered in roster
save c:\mypaper\1203\ifls1\i1_non-farm_business, replace


*****************
** Employment
*****************
*** Non-respondent in Book2
cd c:\mypaper\1203\ifls1
use C:\Mydata\IFLS\IFLS1\hh93dta\buk2ph1, clear
rename ph02 pid93		// pid93 == person == ar001a 
gen j1duty  = ph03b 
gen j1wstat = ph04
recode j1wstat (96/99=.)
gen j1occ 	= string(ph05) if ph05<10 
replace j1occ = j1occ+"X" if j1occ~=""
gen j1ind   = ph06
gen j1inc   = ph07r1
replace j1inc = 0 if j1inc==. & j1wstat~=.
drop if j1inc==.
recode j1inc (99999996/99999999=.)
gen j1dutytr= ph03bt

	* English translation of occupation
	preserve
	replace j1dutytr = "RICE FIELD WORKING HELPER" if j1duty=="MEMBANTU DI SAWAH"
	contract j1duty*
	drop _f
	save j1duty, replace
	restore

**** some mis-coded observations
drop if hhid93=="2150700"	// not registered in roster
drop if hhid93=="0420400" & pid93==4 & j1wstat==.	// duplicated
drop if inlist(pid93,96,99) & j1wstat==.	// person(pid93) not identified & not working
drop hhid ph*
contract *
drop _f
save c:\mypaper\1203\ifls1\i1_employment_nr, replace


*** HH-member interviewed - Book3
cd c:\mypaper\1203\ifls1
use C:\Mydata\IFLS\IFLS1\hh93dta\buk3tk2, clear
renvars tk25r??? tk26r???, sub(r ar)
renvars t25br??? t26br???, sub(t tk)
recode tk25?r??? tk26?r??? (99995/99999=.) (999995/999999=.)
loc i=0
foreach x in "a" "b" {
	loc ++i
	gen j`i'duty = tk20`x'
	gen j`i'wstat = tk24`x'
	gen j`i'whpw = tk22`x'
	recode j`i'whpw (96/99=.)
	gen j`i'wwpy = tk23`x'
	recode j`i'wwpy (53/99=.)
	genl j`i'whpy = j`i'whpw*j`i'wwpy, label(Total work hours/year)
	gen j`i'occ = occ20`x' 
	gen j`i'mninc = tk25`x'r1_m*1000
	gen j`i'yninc = tk25`x'r1_y*1000
	egen j`i'bdinc = rowtotal(tk25`x'r2_y-tk25`x'r7_y)
	replace j`i'bdinc = j`i'bdinc*1000
	gen j`i'mprofit = tk26`x'r1_m*1000
	gen j`i'yprofit = tk26`x'r1_y*1000
	recode j`i'mninc-j`i'yprofit (.=0)
	* yearly total income
	gen j`i'inc = j`i'yninc
	replace j`i'inc = j`i'mninc*12 if j`i'inc==0 & j`i'mninc>0
	replace j`i'inc = j`i'bdinc if j`i'inc==0 & j`i'bdinc>0
	replace j`i'inc = j`i'inc + j`i'yprofit
	replace j`i'inc = j`i'inc + j`i'mprofit*12 if j`i'yprofit==0 & j`i'mprofit>0
	}
keep *id93 pidlink case person j* tk19*
bysort hhid93: replace tk19a = tk19a[1] if tk19a=="" & j1wstat==6
recode j?wstat (7/99=.)
la def wstat 1 "Self/alone" 2 "Self/family" 3 "Self/employee" 4 "Govt official" 5 "Employee" 6 "Family worker"
la val j?wstat wstat
save c:\mypaper\1203\ifls1\i1_employment_r, replace

*** Merge all employment files and assign industry and occupation classification
cd c:\mypaper\1203\ifls1
use i1_employment_nr, clear
merge 1:1 hhid93 pid93 using i1_employment_r, update nogen
merge 1:1 hhid93 pid93 using i1_employment_r, keepusing(j1inc) update replace nogen
merge m:1 j1duty using j1duty, update 	// English translation of occupation
drop if _merge==2
drop _merge

* Update job information from IFLS2
merge m:1 pidlink using c:\mypaper\1203\ifls2\i2_whistory
drop if _merge==2
drop _merge
replace j1ind = tk32ind if inrange(tk32ind,1,9)		// reassign job1 industry class
gen j2ind = tk42ind
forval i=1/2 {
	replace j`i'ind = 1 if regexm(j`i'occ,"6[0-9X]")==1
	replace j`i'ind = 3 if inlist(j`i'occ,"7X","70","71","72","73","74","75","76","77")
	replace j`i'ind = 3 if inlist(j`i'occ,"8X","80","81","82","83","84","88","89")
	replace j`i'ind = 3 if inlist(j`i'occ,"9X","90","91","94","99","78")
	}
replace j1occ = tk32occ if j1occ==""
replace j1occ = regexr(j1occ, "[0-9]X", tk32occ) if tk32occ~=""
replace j2occ = tk42occ if j2occ==""
replace j2occ = regexr(j2occ, "[0-9]X", tk42occ) if tk42occ~=""
drop tk*ind tk*occ

* Update job information from IFLS3
preserve
tempfile j1ind j2ind
use c:\mypaper\1203\ifls3\i3_employment, clear
keep if j1nwy>=7
keep pidlink j1ind j1occ
save `j1ind'
use c:\mypaper\1203\ifls3\i3_employment, clear
keep if j2nwy>=7
keep pidlink j2ind j2occ
save `j2ind'
restore
merge m:1 pidlink using `j1ind', update replace
drop if _merge==2
drop _merge
merge m:1 pidlink using `j2ind', update replace 
drop if _merge==2
drop _merge

* Assign ind-level tariff exposure
merge m:1 tk19a using j1tariff, nogen
merge m:1 tk19a using j1tariff89, nogen
merge m:1 tk19b using j2tariff, nogen
merge m:1 tk19b using j2tariff89, nogen
sort hhid93 pid93
save c:\mypaper\1203\ifls1\i1_employment, replace


***************
** Farm asset
***************
use C:\Mydata\IFLS\IFLS1\hh93dta\buk2ut2, clear
recode ut*r1 (99999996/99999999=.) (0=.)
bysort hhid93: egen farm_asset = total(ut11r1)
bysort hhid93: egen farm_invest = total(ut12r1)
bysort hhid93: egen farm_rent = total(ut14r1)
keep hhid93 case farm* ut13r1
keep if inlist(farmasst,2,4)	// farm asset 2 is hard stem plants, 4 is livestock
reshape wide ut*r1, i(case) j(farmasst)
*gen plant_inc = ut13r12	
*gen lives_inc = ut13r14
drop if hhid93=="2150700"	// not registered in roster
drop ut*
save c:\mypaper\1203\ifls1\i1_farm_asset, replace


*************
** HH asset
*************
use C:\Mydata\IFLS\IFLS1\hh93dta\buk2hr1, clear
sort hhid93 assettyp
recode hr*r1 hr07 (99999996/99999999=.) (996/999=.) (0=.)
gen asset_sh = hr06==1
replace asset_sh = hr07/100 if asset_sh==0
gen asset = hr02r1*asset_sh
gen rent =  hr05r1*asset_sh
bysort hhid93: egen hh_asset = total(asset)
bysort hhid93: egen hh_rent = total(rent)
contract hhid93 case hh_*
drop _freq
drop if hhid93=="2150700"	// not registered in roster
save c:\mypaper\1203\ifls1\i1_hh_asset, replace


*********************
** Individual asset
*********************
*** HH-member not-interviewed in Book2
use C:\Mydata\IFLS\IFLS1\hh93dta\buk3hi1, clear
sort hhid93 pid93 assettyp
recode hi*r1 (99999996/99999999=.) (0=.)
bysort hhid93 pid93: egen ind_asset = total(hi03r1)
bysort hhid93 pid93: egen ind_rent = total(hi06r1)
contract hhid93 pid93 case person ind_*
drop _freq
*** individual asset should be added
drop if hhid93=="2150700"	// not registered in roster
save c:\mypaper\1203\ifls1\i1_ind_asset, replace


*******************
** Other sources
*******************
*** OTHERINC is the sum of pension, scholarship, insurance claim, winnings, gift, and others.
use C:\Mydata\IFLS\IFLS1\hh93dta\buk2ph2, clear
recode ph09r1 (999999996/999999999=.)
bysort hhid93: egen otherinc = total(ph09r1)
contract hhid93 case otherinc
drop _freq
drop if hhid93=="2150700"	// not registered in roster
save c:\mypaper\1203\ifls1\i1_others, replace
