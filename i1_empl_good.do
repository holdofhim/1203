
********************************
* Before running,
* 1. check produk4d.csv and produk6d.csv file to be the most updated version.

* After running,
* 1. run tariff_assign.do
* 2. run i1_hh_income.do
* 3. run i1_sample.do
********************************

loc date "170808"
gl path "D:\onedrive\IFLS"

clear all
set more off

/* Product Translation
cd $path\tariff
foreach j in 4 6 {
	insheet using produk`j'd.csv, names clear
	replace product`j'd = upper(product`j'd)
	replace produk`j'd = upper(produk`j'd)
	gen words = wordcount(produk`j'd)
	gen wordlong = length(produk`j'd)
	gsort -words -wordlong
	drop word*
	save produk`j'd, replace
	}
*/


cd $path\IFLS1
use hh93dta\buk3tk2.dta, clear

foreach x in "tk19a" "tk19b" "tk20a" "tk20b" {

	if "`x'"=="tk19a" | "`x'"=="tk20a" loc i=1	// primary job
	if "`x'"=="tk19b" | "`x'"=="tk20b" loc i=2	// secondary job

	** String cleaning before translation
	preserve
	contract `x'
	drop _freq
	
	* General
	egen j`i'g1 = msub(`x'), f(0 1 2 3 4 5 6 7 8 9 " DAN " & + \ / . = : ; _ "(" ")" [ ] ,) r(" , ")
	replace j`i'g1 = trim(itrim(j`i'g1))
	replace j`i'g1 = regexr(j`i'g1, "[ ]*-[ ]*", "-")
	replace j`i'g1 = subinstr(j`i'g1,"-"+regexs(2)+regexs(3), " , ", 1) if regexm(j`i'g1, "([A-Z]+)-([A-Z]+)(AN)") & regexs(1)==regexs(2)
	replace j`i'g1 = subinstr(j`i'g1,"-"+regexs(2), " , ", 1) if regexm(j`i'g1, "([A-Z]+)-([A-Z]+)") & regexs(1)==regexs(2)
	replace j`i'g1 = regexr(j`i'g1, "[ ]*-[ ]*", " ")
	replace j`i'g1 = regexr(j`i'g1, "[ ]*-[ ]*", " ")
	replace j`i'g1 = regexr(j`i'g1, "[BPM]?E?[A-Z]?JU[A]?L(AN)?[ ,]*(BELI)?", " , SALES , ")		// JUAL BELI, JUALBELI, JUAL-BELI, ***JUAL**
	replace j`i'g1 = regexr(j`i'g1, "[A-Z]?[A-Z]?[A-Z]?DAGANG(AN)?|EXPORT[ ,]*(IMPORT)?", " , TRADE ,")
	replace j`i'g1 = regexr(j`i'g1, "J[A]?S[A]?|SERVIS[E]?|PELAYAN(AN)?", " , SERVICES , ")
	replace j`i'g1 = regexr(j`i'g1, "(PER)?(PENG)?USAHA(AN)?", " , BUSINESS , ")
	replace j`i'g1 = regexr(j`i'g1, "K(EBUTUHAN)?(EPERLUAN)?(ONSUMSI)?[ ,]*(HIDUP)?[ ,]*SEHA[R]?I[ ,]*((SE)?H[A]?R[I]?)?", " , GROCERY , ")
	replace j`i'g1 = regexr(j`i'g1, "KELON[G]?TON[G]?(AN)?", " , GROCERY , ")
	replace j`i'g1 = regexr(j`i'g1, "M[A]?K[A]?N(AN)?", " , FOOD , ")
	egen j`i'g2 = msub(j`i'g1), f(BHN RT PEMASANGANMEKANIK WARUNG AIR ES PRABOTAN) 	///
								r(" , BAHAN , " " , RETAIL , " "PEMASANGAN MEKANIK" " , STORE , " WATER ICE " , FURNITURE , ") w	
	egen j`i'g3 = msub(j`i'g2), f(DISTRIBUTOR ADMINISTRASI "MEDIA MASSA" "SURAT MENYURAT") 	///
								r(" , DISTRIBUTOR , " " , ADMINISTRASI , " "" "WRITING LETTER")
	egen j`i'good = msub(j`i'g3), f(DLL ATAU KLUI XAN PNJG DSB TLR TNH TTG KLP JADI SEHARI) n(1) w
	replace j`i'good = trim(itrim(j`i'good))
	replace j`i'good = regexr(j`i'good, "^[, ]+", "")
	replace j`i'good = regexr(j`i'good, "[ ,]+$", "")
	replace j`i'good = subinword(j`i'good, ", ,", ",", .)
	replace j`i'good = subinword(j`i'good, ", ,", ",", .)
	keep `x' j`i'good
	save j`i'good, replace

	* Agricultural Products
	use j`i'good, clear
	egen j`i'g1 = msub(j`i'good), f("PADI LADANG" "PADI GOGO" "PADI SAWAH" PARI PADAI GABAH BERAS NASI SAWAH) r(" , RICE , ")
	replace j`i'g1 = regexr(j`i'g1, "P.?L.?W.?J[A-Z]?", " , VEGETABLE , ")	// PALAWIJA or POLOWIJO
	replace j`i'g1 = regexr(j`i'g1, "KC[G]?", "KACANG")								// KACANG
	replace j`i'g1 = regexr(j`i'g1, "(KACANG)?[ ,]*KEDEL[A-Z][I]?", " , SOYBEAN , ")	// KACANG KEDELEI
	replace j`i'g1 = regexr(j`i'g1, "J[A]?G[U]?N[G]?", " , CORN , ")				// JAGUNG
	replace j`i'g1 = regexr(j`i'g1, "[SM][A]?[S]?YUR(AN)?[ ,]*([SM]AYUR(AN)?)?", " , VEGETABLE , ")	// SAYUR-SAYURAN
	replace j`i'g1 = regexr(j`i'g1, "BUAH(AN)?[ ,]*([B]?UAH(AN)?)?", " , FRUIT , ")					// BUAH-BUAHAN
	replace j`i'g1 = regexr(j`i'g1, "(UB.?[ ,]*KAYU)|(KETEL[A-Z]?[ ,]*(P.?H.?N)?)|(S.?N.?K.?N.?)", ///
							" , CASSAVA , ")	// UBI KAYU, KETELA POHON, SINGKONG
	replace j`i'g1 = regexr(j`i'g1, "TELU[RT]?", " , EGG , ")	// TELUR
	replace j`i'g1 = regexr(j`i'g1, "(T[A]?N[A]?MAN|PANEN(AN)?)[ ,]*([A-Z]*TANI(AN)?)?", " , CROP , ")		// TANAMAN	
	replace j`i'g1 = regexr(j`i'g1, "(B[A]?R(AN)?G|(MENG)?H[A]?S[I]?L(KAN)?|([A-Z][A-Z][A-Z])?PRODUK(SI)?|BURUH)[ ,]*[A-Z]*TANI(AN)?", ///
							" , AGRICULTURAL PRODUCTS , ")		// BARANG-, HASIIL-, PRODUKSI-PERTANIAN
	replace j`i'g1 = regexr(j`i'g1, "B[A]?R(AN)?G|(MENG)?H[A]?S[I]?L(KAN)?|[A-Z]?[A-Z]?[A-Z]?PRODUK(SI)?", " , PRODUCTS , ")
	replace j`i'g1 = regexr(j`i'g1, "DAUN", " , ")
	replace j`i'g1 = regexr(j`i'g1, "UBI", " , YAM , ")
	replace j`i'g1 = regexr(j`i'g1, "KA.?ANG[ ,]*TANA[A-Z]?", " , GROUNDNUT , ")
	replace j`i'g1 = regexr(j`i'g1, "BIJI[ ,]*JAMBU|JAMBU[ ,]*ME.*TE", " , CASHEW , ")
	replace j`i'g1 = regexr(j`i'g1, "KACANGAN", "")
	replace j`i'good = j`i'g1
	
	* Merge with translated products
	foreach k in 6 4 {
		merge 1:1 _n using $path\produk`k'd, nogen
		qui tab produk`k'd
		qui forval j=1/`r(N)' {
			loc y = produk`k'd[`j']
			loc z = product`k'd[`j']
			replace j`i'good = subinword(j`i'good, "`y'", " , `z' , ", .)
			}
		drop produ*
		}
	gen nword = wordcount(j`i'good)
	egen j`i'gn = msub(j`i'good) if nword>1, f("AGRICULTURAL PRODUCTS" PERTANIAN BERTANI PERKEBUNAN BARANG PANEN MENANAM MERAH) n(1) w
	replace j`i'good = j`i'gn if nword>1
	replace j`i'good = trim(itrim(j`i'good))
	replace j`i'good = regexr(j`i'good, "^[, ]+", "")
	replace j`i'good = regexr(j`i'good, "[ ,]+$", "")
	replace j`i'good = subinword(j`i'good, ", ,", ",", .)
	replace j`i'good = subinword(j`i'good, ", ,", ",", .)
	keep `x' j`i'good
	save j`i'good, replace
	
	* Manufacturing goods
	*use j`i'good, clear
	
	
	save j`i'good_`x', replace
	outsheet using j`i'good_`x'.csv, comma replace

	restore
	}
