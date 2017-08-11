

label drop _all

#delimit ;

* Relation to Head of Household ;
label define relation
	1  HEAD
	2  SPOUSE
	3  "CHILD(BIOLOGICAL)"
	4  "CHILD(ADOPTED/STEP)"
	5  "SON/DAUGHTER-IN-LAW"
	6  PARENT
	7  "PARENT-IN-LAW"
	8  SIBLING
	9  "SIBLING-IN-LAW"
	10 GRANDCHILD
	11 GRANDPARENT
	12 "UNCLE/AUNT"
	13 "NEPHEW/NIECE"
	14 COUSIN
	15 SERVANT
	16 "FAMILY RELATED"
	17 "NON-FAMILY RELATED"
	, replace ;

* Sex ;
label define sex 
	0 MALE 
	1 FEMALE
	, replace ;

* Marital Status ;
label define marital
	1 SINGLE
	2 MARRIED
	3 SEPARATED
	4 DIVORCED
	5 WIDOWED
	, replace ;

* Religion ;
label define religion
	1 ISLAM
	2 PROTESTANT
	3 CATHOLIC
	4 HINDUISM
	5 BUDDHISM
	6 OTHER
	, replace ;

* Highest Education ;
label define education
	1  UNSCHOOLED
	2  "GRADE SCHOOL"
	3  "GENERAL JR.HIGH"
	4  "VOCATIONAL JR.HIGH"
	5  "GENERAL SR.HIGH"
	6  "VOCATIONAL SR.HIGH"
	7  "DIPLOMA(D1,D2)"
	8  "DIPLOMA(D3)"
	9  "UNIVERSITY(BA/MA/PhD)"
	10 OTHER
	11 KINDERGARTEN
	, replace ;
	
* Currently Attending School ;
label define student
	1 YES
	0 NO
	, replace ;

* Primary Activity last week ;
label define activity 
	1 WORKING
	2 "JOB SEARCHING"
	3 "ATTENDING SCHOOL"
	4 HOUSEKEEPING
	5 RETIRED
	6 OTHER
	, replace ;


#delimit cr

