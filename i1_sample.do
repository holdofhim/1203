
clear all
set more off
cd C:\Onedrive\1203\IFLS1
gl dopath "C:\Onedrive\1203\Code"

/* Before running,
run $dopath\i1_empl_good.do
run $dopath\tariff_assign.do
run $dopath\i1_hh_income.do
run $dopath\i1_hh_asset.do
*/

* Household Roster based on IFLS1
use hh93dta\bukkar2, clear
rename ar02 relation
gen sex = ar07==3
rename ar08yr birthyear
rename ar09yr age
rename ar13 marital
rename ar15 religion
rename ar16 education
rename ar17 grade
gen student = ar18==1
rename ar22 activity
recode relation age religion education grade student activity (96/99=.)
recode birthyear (93/99=.)
recode marital (6/9=.)
drop ar* faccode hhid pid case person
order commid93 hhid93 pid93 pidlink 
sort hhid93 pidlink
run $dopath\i1_label_values.do
foreach x of varlist relation sex marital religion education student activity {
	label value `x' `x'
	}
save i1_sample_roster, replace

* Household Characteristics
use hh93dta\buk1kr1, clear
rename kr03 ownhouse
recode ownhouse (2/5=0) (6/9=.)			// 1 if own house
rename kr2b trash	
recode trash (3=0) (6/9=.)				// 1 if there is trash pile around HH
rename kr06 room
recode room (96/99=.)
rename kr13 tabwater
recode tabwater (2/9=0) (96/99=.)		// 1 if tabwater
keep hhid93 commid93 ownhouse trash room tabwater
merge 1:1 hhid93 using hh93dta\bukkar1, keepusing(hhldsize) nogen
rename hhldsize hhsize
order commid93 hhid93
sort commid93 hhid93
save i1_hh_character, replace

/* Sub-sample: HH where the head of HH is in between 18-50 olds and has own children under 8
sort hhid93 pid93
drop if relation==10
loc child_age=8
gen child = age<=`child_age'
bysort hhid93: egen children = total(child)
bysort hhid93: gen headage = age if relation==1
bysort hhid93: replace headage = sum(headage)
keep if children>0 & inrange(headage,18,50)
bysort hhid93: egen married = count(marital) if marital==2
bysort hhid93: replace married = married[_n-1] if married==.
save i1_sample_wchild_under`child_age', replace
*/

* Identify respondent in book 2
use hh93dta\buk2ut1, clear
rename resp2_2 resp_b2	// The number can be matched by pid93
recode resp_b2 (96/99 .=1)
keep *id93 resp_b2
order commid93 hhid93
sort commid93 hhid93
save i1_b2_respondent, replace

* Identify respondent in book 3
use hh93dta\buk3s3a, clear
rename resp3_2 resp_b3
recode resp_b3 (96/99=.)
keep *id93 resp_b3
order commid93 *id93
sort commid93 hhid93 pid93
save i1_b3_respondent, replace


* Merge datasets
use i1_sample_roster, clear
merge m:1 hhid93 using i1_hh_character, nogen
merge m:1 hhid93 using i1_b2_respondent, nogen
merge 1:m hhid93 pid93 using i1_b3_respondent, nogen
merge m:1 hhid93 using i1_farm_business_income, nogen
merge m:1 hhid93 using i1_non-farm_business_income, nogen
merge 1:1 hhid93 pid93 using i1_employment, nogen keepusing(j* tk*)
*merge m:1 hhid93 using i1_farm_asset, nogen keepusing(farm_rent)
*merge m:1 hhid93 using i1_hh_asset, nogen keepusing(hh_rent)
*merge 1:m hhid93 pid93 using i1_ind_asset 
*merge m:1 hhid93 using i1_others, nogen keepusing(otherinc)

drop if hhid93=="2150700"	// not registered in roster
sort hhid93 pid93

* Calculate Household-level Income, Tariff exposure and their IVs
recode j?wstat (6=0)
foreach x in "inc" "wstat" {
	bysort hhid93: egen j1 = total(j1`x')
	bysort hhid93: egen j2 = total(j2`x')
	egen hh`x' = rowtotal(j1 j2)
	drop j1 j2
	recode hh`x' (0=1)
	}
gen wtj1 = j1inc/hhinc*j1tariff
gen wtj2 = j2inc/hhinc*j2tariff
bysort hhid93: egen jtar1 = total(wtj1)
bysort hhid93: egen jtar2 = total(wtj2)
egen hhdtar = rowtotal(jtar1 jtar2)	
drop wtj1 wtj2 jtar1 jtar2

foreach y in "tariff89" "tar_sd89" "tar_line89" {
	gen wtj1 = j1wstat/hhwstat*j1`y'
	gen wtj2 = j2wstat/hhwstat*j2`y'
	bysort hhid93: egen j1 = total(wtj1)
	bysort hhid93: egen j2 = total(wtj2)
	egen hh`y' = rowmean(j1 j2)	
	drop wtj1 wtj2 j1 j2
	}
rename hhtariff89 hhtar89

* Rice-only Producers
bysort hhid93: egen temp = count(pid93) if inlist(j1good,"PADDY","RICE") & inlist(j2good,"","PADDY","RICE")
bysort hhid93: gen temp2 = 1 if j1good~=""
bysort hhid93: egen temp3 = count(temp2)
gen temp4 = 1 if temp==temp3
bysort hhid93: egen rice = total(temp4)
replace rice=1 if rice>1
drop temp*
order j?inc hhinc hhdtar farm_rent hh_rent otherinc, after(nfarm_inc)
sort hhid93 relation
save i1_sample, replace

*order *farm_owner*, after(resp_b2)
*gsort -resp_b2 hhid93 pid93
*replace farm_owner1 = resp_b2 if 
