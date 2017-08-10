
clear all
set more off
cd D:\OneDrive\IFLS\IFLS1

use hh93dta\buk3tk2.dta, clear
egen j1g = msub(tk19a), f(" DAN " & + \ / . = : ; _ , "(" ")" [ ]) r(|)
split j1g, parse(|)
foreach x of varlist j1g? {
	replace `x' = trim(itrim(`x'))
	}
keep j1g?

save j1g_tk19a, replace

stack j1g?, into(j1goods)
contract j1goods
drop if inlist(j1goods,"","W","X","Y","Z","DLL")
gsort -_freq


gen a = "PADI"

matchit j1g1 j1g2, g(b)


list j1g1 if regexm(j1g1, "([A-Z]+)-([A-Z]+)(AN)") & regexs(1)==regexs(2)

replace j1g1 = subinstr(j1g1,"-"+regexs(2)+regexs(3), " , ", 1) if regexm(j1g1, "([A-Z]+)-([A-Z]+)(AN)") & regexs(1)==regexs(2)
replace j1g1 = subinstr(j1g1,"-"+regexs(2), " , ", 1) if regexm(j1g1, "([A-Z]+)-([A-Z]+)") & regexs(1)==regexs(2)
replace j1g1 = regexr(j1g1, "[ ]*-[ ]*", " ")
replace j1g1 = regexr(j1g1, "[ ]*-[ ]*", " ")
replace j1g1 = regexr(j1g1, "[BPM]?E?[A-Z]?JU[A]?L(AN)?[ ,]*(BELI)?", " , SALES , ")		// JUAL BELI, JUALBELI, JUAL-BELI, ***JUAL**
replace j1g1 = regexr(j1g1, "[A-Z]?[A-Z]?[A-Z]?DAGANG(AN)?|EXPORT[ ,]*(IMPORT)?", " , TRADE ,")
replace j1g1 = regexr(j1g1, "J[A]?S[A]?|SERVIS[E]?|PELAYAN(AN)?", " , SERVICES , ")
replace j1g1 = regexr(j1g1, "(PER)?(PENG)?USAHA(AN)?", " , BUSINESS , ")
replace j1g1 = regexr(j1g1, "K(EBUTUHAN)?(EPERLUAN)?(ONSUMSI)?[ ,]*(HIDUP)?[ ,]*SEHA[R]?I[ ,]*((SE)?H[A]?R[I]?)?", " , GROCERY , ")
replace j1g1 = regexr(j1g1, "KELON[G]?TON[G]?(AN)?", " , GROCERY , ")
replace j1g1 = regexr(j1g1, "M[A]?K[A]?N(AN)?", " , FOOD , ")

egen j1g2 = msub(j1g1), f(BHN RT PEMASANGANMEKANIK WARUNG AIR ES PRABOTAN) 	///
							r(" , BAHAN , " " , RETAIL , " "PEMASANGAN MEKANIK" " , STORE , " WATER ICE " , FURNITURE , ") w	
egen j1g3 = msub(j1g2), f(DISTRIBUTOR ADMINISTRASI "MEDIA MASSA" "SURAT MENYURAT") 	///
							r(" , DISTRIBUTOR , " " , ADMINISTRASI , " "" "WRITING LETTER")
egen j1good = msub(j1g3), f(DLL ATAU KLUI XAN PNJG DSB TLR TNH TTG KLP JADI SEHARI) n(1) w
replace j1good = trim(itrim(j1good))
replace j1good = regexr(j1good, "^[, ]+", "")
replace j1good = regexr(j1good, "[ ,]+$", "")
replace j1good = subinword(j1good, ", ,", ",", .)
replace j1good = subinword(j1good, ", ,", ",", .)

keep tk19a j1good
save j1good, replace

* Agricultural Products
use j1good, clear
egen j1g1 = msub(j1good), f("PADI LADANG" "PADI GOGO" "PADI SAWAH" PARI PADAI GABAH BERAS NASI SAWAH) r(" , RICE , ")
replace j1g1 = regexr(j1g1, "P[AO]?L[AO]?W[I]?J[AO]?", " , VEGETABLE , ")	// PALAWIJA or POLOWIJO
replace j1g1 = regexr(j1g1, "KC[G]?", "KACANG")								// KACANG
replace j1g1 = regexr(j1g1, "(KACANG)?[ ]?KEDEL[AEI][I]?", " , SOYBEAN , ")	// KACANG KEDELEI
replace j1g1 = regexr(j1g1, "J[A]?G[U]?N[G]?", " , CORN , ")				// JAGUNG
replace j1g1 = regexr(j1g1, "[SM][A]?[S]?YUR(AN)?[ ]?([SM]AYUR(AN)?)?", " , VEGETABLE , ")	// SAYUR-SAYURAN
replace j1g1 = regexr(j1g1, "BUAH(AN)?[ ]?([B]?UAH(AN)?)?", " , FRUIT , ")					// BUAH-BUAHAN
replace j1g1 = regexr(j1g1, "(UB[IU][ ]?KAYU)|(KETEL[A]?[ ]?(P[O]?H[O]?N)?)|(S[I]?N[G]?K[O]?N[G]?)", ///
						" , CASSAVA , ")	// UBI KAYU, KETELA POHON, SINGKONG
replace j1g1 = regexr(j1g1, "TELU[RT]?", " , EGG , ")	// TELUT
replace j1g1 = regexr(j1g1, "T[A]?N[A]?MAN|PANEN(AN)?", " , CROP , ")		// TANAMAN	
replace j1g1 = regexr(j1g1, "(B[A]?R(AN)?G|(MENG)?H[A]?S[I]?L(KAN)?|([A-Z][A-Z][A-Z])?PRODUK(SI)?|BURUH)( ,)?[ ]?[A-Z]*TANI(AN)?", ///
						" , AGRICULTURAL_PRODUCTS , ")		// BARANG-, HASIIL-, PRODUKSI-PERTANIAN
replace j1g1 = regexr(j1g1, "B[A]?R(AN)?G|(MENG)?H[A]?S[I]?L(KAN)?|[A-Z]?[A-Z]?[A-Z]?PRODUK(SI)?", " , PRODUCTS , ")
replace j1g1 = regexr(j1g1, "DAUN", " , ")
egen j1g2 = msub(j1g1), f(UBI KACANGTANAH KALANG KACANGAN) r(" , YAM , " " , GROUNDNUT , " " , BEAN , " "")
replace j1good = j1g2

foreach k in 6 4 {
	merge 1:1 _n using C:\mypaper\1203\tariff\produk`k'd, nogen
	qui tab produk`k'd
	qui forval j=1/`r(N)' {
		loc y = produk`k'd[`j']
		loc z = product`k'd[`j']
		replace j1good = subinword(j1good, "`y'", " , `z' , ", .)
		}
	drop produ*
	}
gen nword = wordcount(j1good)
egen j1gn = msub(j1good) if nword>1, f(PERTANIAN BERTANI PERKEBUNAN PANEN MENANAM MERAH) n(1) w
replace j1good = j1gn if nword>1
replace j1good = trim(itrim(j1good))
replace j1good = regexr(j1good, "^[, ]+", "")
replace j1good = regexr(j1good, "[ ,]+$", "")
replace j1good = subinword(j1good, ", ,", ",", .)
replace j1good = subinword(j1good, ", ,", ",", .)
keep tk19a j1good

save j1good_tk19a, replace
contract j1good
drop _f
outsheet using j1good_tk19a.csv, comma replace

screening, source(j1good, upper removesign) keys(MENGHASILKAN PERTANIAN PERKEBUNAN TANAMAN TANI PANEN MENANAM MERAH DAUN) e(tab) save
