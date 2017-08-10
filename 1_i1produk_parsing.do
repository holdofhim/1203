
clear all
set more off

cd D:\OneDrive\IFLS\IFLS1
loc i = 1
loc x "tk19a"

use hh93dta\buk3tk2.dta, clear

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
	replace j`i'g1 = regexr(j`i'g1, "P[AO]?L[AO]?W[I]?J[AO]?", " , VEGETABLE , ")	// PALAWIJA or POLOWIJO
	replace j`i'g1 = regexr(j`i'g1, "KC[G]?", "KACANG")								// KACANG
	replace j`i'g1 = regexr(j`i'g1, "(KACANG)?[ ]?KEDEL[AEI][I]?", " , SOYBEAN , ")	// KACANG KEDELEI
	replace j`i'g1 = regexr(j`i'g1, "J[A]?G[U]?N[G]?", " , CORN , ")				// JAGUNG
	replace j`i'g1 = regexr(j`i'g1, "[SM][A]?[S]?YUR(AN)?[ ]?([SM]AYUR(AN)?)?", " , VEGETABLE , ")	// SAYUR-SAYURAN
	replace j`i'g1 = regexr(j`i'g1, "BUAH(AN)?[ ]?([B]?UAH(AN)?)?", " , FRUIT , ")					// BUAH-BUAHAN
	replace j`i'g1 = regexr(j`i'g1, "(UB[IU][ ]?KAYU)|(KETEL[A]?[ ]?(P[O]?H[O]?N)?)|(S[I]?N[G]?K[O]?N[G]?)", ///
							" , CASSAVA , ")	// UBI KAYU, KETELA POHON, SINGKONG
	replace j`i'g1 = regexr(j`i'g1, "TELU[RT]?", " , EGG , ")	// TELUT
	replace j`i'g1 = regexr(j`i'g1, "T[A]?N[A]?MAN|PANEN(AN)?", " , CROP , ")		// TANAMAN	
	replace j`i'g1 = regexr(j`i'g1, "(B[A]?R(AN)?G|(MENG)?H[A]?S[I]?L(KAN)?|([A-Z][A-Z][A-Z])?PRODUK(SI)?|BURUH)( ,)?[ ]?[A-Z]*TANI(AN)?", ///
							" , AGRICULTURAL_PRODUCTS , ")		// BARANG-, HASIIL-, PRODUKSI-PERTANIAN
	replace j`i'g1 = regexr(j`i'g1, "B[A]?R(AN)?G|(MENG)?H[A]?S[I]?L(KAN)?|[A-Z]?[A-Z]?[A-Z]?PRODUK(SI)?", " , PRODUCTS , ")
	replace j`i'g1 = regexr(j`i'g1, "DAUN", " , ")
	egen j`i'g2 = msub(j`i'g1), f(UBI KACANGTANAH KALANG KACANGAN) r(" , YAM , " " , GROUNDNUT , " " , BEAN , " "")
	replace j`i'good = j`i'g2
	
	foreach k in 6 4 {
		merge 1:1 _n using C:\mypaper\1203\tariff\produk`k'd, nogen
		qui tab produk`k'd
		qui forval j=1/`r(N)' {
			loc y = produk`k'd[`j']
			loc z = product`k'd[`j']
			replace j`i'good = subinword(j`i'good, "`y'", " , `z' , ", .)
			}
		drop produ*
		}
	gen nword = wordcount(j`i'good)
	egen j`i'gn = msub(j`i'good) if nword>1, f(PERTANIAN BERTANI PERKEBUNAN PANEN MENANAM MERAH) n(1) w
	replace j`i'good = j`i'gn if nword>1
	replace j`i'good = trim(itrim(j`i'good))
	replace j`i'good = regexr(j`i'good, "^[, ]+", "")
	replace j`i'good = regexr(j`i'good, "[ ,]+$", "")
	replace j`i'good = subinword(j`i'good, ", ,", ",", .)
	replace j`i'good = subinword(j`i'good, ", ,", ",", .)
	keep `x' j`i'good

	save j`i'good_`x', replace
	contract j`i'good
	drop _f
	outsheet using j`i'good_`x'.csv, comma replace

	screening, source(j1good, upper removesign) keys(MENGHASILKAN PERTANIAN PERKEBUNAN TANAMAN TANI PANEN MENANAM MERAH DAUN) e(tab) save
