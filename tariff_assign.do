
********************************
* Before running,
* 1. run i1_empl_good.do

* After running,
* 1. run i1_hh_income.do
* 2. run i1_sample.do
********************************

loc date "130611"
gl path "c:\chung\1203"
gl hh93dta "C:\Mydata\IFLS\IFLS1\hh93dta"

clear all
set more off

* Tariff level according to Product name
cd $path\tariff
foreach j in 2 4 6 {
	insheet using hs92-cpc2_product_`date'.csv, names clear
	* apply only agricultural product
	* keep if cpc2d5<10000
	contract hs92d6 product`j'd
	drop if product`j'd==""
	replace product`j'd = upper(product`j'd)
	joinby hs92d6 using tariff_hs92d6
	bysort product`j'd: egen totline = total(hs92d6line)
	gen tline = hs92d6line/totline
	gen dtar = dhs92d6tar*tline
	gen sd = hs92d6sd*tline
	bysort product`j'd: egen dtariff = total(dtar)
	bysort product`j'd: egen tar_sd = total(sd)
	keep hs92d6 dtariff totline tar_sd product`j'd
	gen words = wordcount(product`j'd)
	gen wordlong = length(product`j'd)
	gsort -words -wordlong hs92d6
	drop word*
	save hs92_product`j'd, replace
	}
	
* Assign tariff
cd "C:\mypaper\1203\IFLS1"
foreach x in "tk19a" "tk19b" {
	if "`x'"=="tk19a" | "`x'"=="tk20a" loc i=1
	if "`x'"=="tk19b" | "`x'"=="tk20b" loc i=2
	use j`i'good_`x', clear
	replace j`i'good = upper(j`i'good)
	save j`i'good_`x', replace	
	gen j`i'good_tar = j`i'good
	gen j`i'good_sd = j`i'good
	gen j`i'good_line = j`i'good
	foreach k in 6 4 2 {
		merge 1:1 _n using C:\mypaper\1203\tariff\hs92_product`k'd, nogen
		qui tab product`k'd
		qui forval j=1/`r(N)' {
			loc name = product`k'd[`j']
			loc dtar = dtariff[`j']
			loc sd = tar_sd[`j']
			loc line = totline[`j']
			replace j`i'good_tar = subinword(j`i'good_tar, "`name'", "`dtar'", .)
			replace j`i'good_sd = subinword(j`i'good_sd, "`name'", "`sd'", .)
			replace j`i'good_line = subinword(j`i'good_line, "`name'", "`line'", .)
			}
		drop hs92d6 product`k'd
		}
	split j`i'good_tar, parse(,) destring force
	egen j`i'tariff = rowmean(j`i'good_tar1-j`i'good_tar`r(nvars)')
	split j`i'good_sd, parse(,) destring force
	egen j`i'tar_sd = rowmean(j`i'good_sd1-j`i'good_sd`r(nvars)')
	split j`i'good_line, parse(,) destring force
	egen j`i'tar_line = rowmean(j`i'good_line1-j`i'good_line`r(nvars)')
	keep `x' j`i'tariff j`i'tar_*
	save j`i'tariff, replace
	}



********************************************
* IV for tariff change: tariff rate in 1989
********************************************
* Tariff level according to Product name
cd "C:\mypaper\1203\tariff"
loc date "121022"
foreach j in 2 4 6 {
	insheet using hs92-cpc2_product_`date'.csv, names clear
	* apply only agricultural product
	*keep if cpc2d5<10000
	contract hs92d6 product`j'd
	drop if product`j'd==""
	replace product`j'd = upper(product`j'd)
	joinby hs92d6 using tariff_hs92d6_1989
	bysort product`j'd: egen totline = total(hs92d6line)
	gen tline = hs92d6line/totline
	gen tar = hs92d6tar*tline
	gen sd = hs92d6sd*tline
	bysort product`j'd: egen tariff = total(tar)
	bysort product`j'd: egen tar_sd = total(sd)
	keep hs92d6 tariff totline tar_sd product`j'd
	gen words = wordcount(product`j'd)
	gen wordlong = length(product`j'd)
	gsort -words -wordlong hs92d6
	drop word*
	save hs92_product`j'd_1989, replace
	}
	

* Assign tariff
cd "C:\mypaper\1203\IFLS1"
foreach x in "tk19a" "tk19b" {
	if "`x'"=="tk19a" | "`x'"=="tk20a" loc i=1
	if "`x'"=="tk19b" | "`x'"=="tk20b" loc i=2
	use j`i'good_`x', clear	
	gen j`i'good_tar = j`i'good
	gen j`i'good_sd = j`i'good
	gen j`i'good_line = j`i'good
	foreach k in 6 4 2 {
		merge 1:1 _n using C:\mypaper\1203\tariff\hs92_product`k'd_1989, nogen
		qui tab product`k'd
		qui forval j=1/`r(N)' {
			loc name = product`k'd[`j']
			loc tar = tariff[`j']
			loc sd = tar_sd[`j']
			loc line = totline[`j']
			replace j`i'good_tar = subinword(j`i'good_tar, "`name'", "`tar'", .)
			replace j`i'good_sd = subinword(j`i'good_sd, "`name'", "`sd'", .)
			replace j`i'good_line = subinword(j`i'good_line, "`name'", "`line'", .)
			}
		drop hs92d6 product`k'd
		}
	split j`i'good_tar, parse(,) destring force
	egen j`i'tariff89 = rowmean(j`i'good_tar1-j`i'good_tar`r(nvars)')
	split j`i'good_sd, parse(,) destring force
	egen j`i'tar_sd89 = rowmean(j`i'good_sd1-j`i'good_sd`r(nvars)')
	split j`i'good_line, parse(,) destring force
	egen j`i'tar_line89 = rowmean(j`i'good_line1-j`i'good_line`r(nvars)')
	keep `x' j`i'good j`i'tariff89 j`i'tar_*89
	save j`i'tariff89, replace
	}
