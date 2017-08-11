
clear all
set more off
cd D:\Onedrive\1203\IFLS1


****************
** Farm asset **
****************
use hh93dta\buk2ut2, clear
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
save i1_farm_asset, replace


**************
** HH asset **
**************
use hh93dta\buk2hr1, clear
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
save i1_hh_asset, replace


**********************
** Individual asset **
**********************
*** HH-member not-interviewed in Book2
use hh93dta\buk3hi1, clear
sort hhid93 pid93 assettyp
recode hi*r1 (99999996/99999999=.) (0=.)
bysort hhid93 pid93: egen ind_asset = total(hi03r1)
bysort hhid93 pid93: egen ind_rent = total(hi06r1)
contract hhid93 pid93 case person ind_*
drop _freq
*** individual asset should be added
drop if hhid93=="2150700"	// not registered in roster
save i1_ind_asset, replace


*******************
** Other sources **
*******************
*** OTHERINC is the sum of pension, scholarship, insurance claim, winnings, gift, and others.
use hh93dta\buk2ph2, clear
recode ph09r1 (999999996/999999999=.)
bysort hhid93: egen otherinc = total(ph09r1)
contract hhid93 case otherinc
drop _freq
drop if hhid93=="2150700"	// not registered in roster
save i1_others, replace
