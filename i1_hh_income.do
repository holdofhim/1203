
********************************
* Before running,
* 1. run i1_empl_good.do
* 2. run tariff_assign.do

* After running,
* 1. run i1_sample.do
********************************

clear all
set more off
cd D:\Onedrive\1203\IFLS1


* Household Income in 1993

*******************
** Farm business **
*******************
use hh93dta\buk2ut1, clear
gen farm_own = ut02==1
recode farm_own (.=0)
replace farm_own = ut03/100 if farm_own==0 & ut03~=.	// partial owners
label var farm_own "Percentage of Ownership"
recode ut0?b1 (99999996/99999999=.)
rename (ut07b1 ut08b1 ut09b1) (farm_ginc farm_exp farm_ninc)
gen n_owner = length(ut05)
qui sum n_owner
forval i=1/`r(max)' {
	gen farm_owner`i' = substr(ut05,`i',1)
	}
replace farm_ninc = farm_ginc-farm_exp if farm_ninc==.
gen farm_inc = farm_ginc
replace farm_inc = farm_ninc if farm_inc==.
label var farm_inc "Income from Farm Business"
keep hhid93 farm_own* farm_inc
drop if hhid93=="2150700"	// not registered in roster
save i1_farm_business_income, replace


***********************
** Non-farm business **
***********************
use hh93dta\buk2nt1, clear
gen nfarm_own = nt02==1
recode nfarm_own (.=0)
replace nfarm_own = nt03/100 if nfarm_own==0 & nt03~=.	// partial owners
label var nfarm_own "Percentage of Ownership"
recode nt0?b1 (99999996/99999999=.)
rename (nt07b1 nt08b1 nt09b1) (nfarm_ginc nfarm_exp nfarm_ninc)
gen n_owner = length(nt05)
qui sum n_owner
forval i=1/`r(max)' {
	gen nfarm_owner`i' = substr(nt05,`i',1)
	}
gen nfarm_inc = nfarm_ginc
replace nfarm_inc = nfarm_ninc if nfarm_inc==.
label var nfarm_inc "Income from Non-farm Business"
keep hhid93 nfarm_own* nfarm_inc
drop if hhid93=="2150700"	// not registered in roster
save i1_non-farm_business_income, replace


****************
** Employment **
****************
*** Non-respondent in Book2
use hh93dta\buk2ph1, clear
rename (ph02 ph03b ph03bt ph04 ph07r1) (pid93 j1duty j1duty_eng j1wstat j1inc)	// pid93==person==ar001a 
recode j1wstat (96/99=.)
gen j1occ 	= string(ph05) if ph05<10 	// Occupation Classification: 1-10
replace j1occ = j1occ+"X" if j1occ~=""
gen j1ind   = ph06						// Industry Classification: 1-10
replace j1inc=0 if j1inc==. & j1wstat~=.
drop if j1inc==.
recode j1inc (99999996/99999999=.)

	* English translation of occupation
	preserve
	replace j1duty_eng = "RICE FIELD WORKING HELPER" if j1duty=="MEMBANTU DI SAWAH"
	contract j1duty*
	drop _f
	save j1duty, replace
	restore

**** some mis-coded observations
drop if hhid93=="2150700"							// not registered in roster
drop if hhid93=="0420400" & pid93==4 & j1wstat==.	// duplicated
drop if inlist(pid93,96,99) & j1wstat==.			// person(pid93) not identified & not working
drop hhid ph*
contract *
drop _f
save i1_employment_non-respondent, replace


*** HH-member interviewed - Book3
use hh93dta\buk3tk2, clear
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
save i1_employment_respondent, replace


*** Merge all employment files and assign industry and occupation classification
use i1_employment_nr, clear
merge 1:1 hhid93 pid93 using i1_employment_r, update nogen
merge 1:1 hhid93 pid93 using i1_employment_r, keepusing(j1inc) update replace nogen
merge m:1 j1duty using j1duty, update 	// English translation of occupation
drop if _merge==2
drop _merge


* Update job information from IFLS2
merge m:1 pidlink using D:\Onedrive\1203\ifls2\i2_whistory
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
use i3_employment, clear
keep if j1nwy>=7
keep pidlink j1ind j1occ
save `j1ind'
use i3_employment, clear
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
save i1_employment, replace

