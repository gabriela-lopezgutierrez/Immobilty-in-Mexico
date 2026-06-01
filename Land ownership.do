/*==============================================================================
                      Generating variables                      
==============================================================================*/
/*

Project:               (Im)mobility in Mexico
Database:              Mexico Life Survey - Wave 1, 2 and 3
Level:                 Household databases
Book:                  II - Household economy / Book C - Control Book
Subsection:            SU - Land / CV - Dwelling characteristics
Dofile author:         Gabriela Judith López Gutiérrez
Creation date:         May 2026 /01
Modification date:     May 2026 /01
Product 1:             Produce household ownership proxy for rural and urban
*/

/*==============================================================================
                                    RURAL HH
==============================================================================*/
/*==============================================================================
                     Wave 1 or period t-1 (Household level)
==============================================================================*/

/*==============================================================================
 0.General setup / Work environment (Wave 1)                                  
==============================================================================*/
set more off , perm
clear all
global rawdata= "C:\Users\hp\Desktop\Thesis\Stata procedure\01. Data\01.1 Raw data\Wave I\Household\hh02dta_b2 - Book 2 (Household Economy) W1"

/*==============================================================================
 1.Import (Wave 1)                                                            
==============================================================================*/

use "${rawdata}/ii_su1.dta"
numlabel, add

/*==============================================================================
 2.Add label variables    
==============================================================================*/

*------------2.1: Define state of ownership label
label define stateown 1"Private property" 2"Ejido/Communal parcel" 3"Rented" ///
4"Taken in sharecropping" 5"Borrowed" 6"In society" 7"Other"
label values su08 stateown

*------------2.2: Define legal document label
label define document 1"Script or private property certificate" ///
2"Ejido certificate or cerificate of agricultural rights" ///
3"Other" 4"None"
label values su09_1 document

tab su09_1 su08, miss

*------------2.3: Save intermediate dataset
global intdata= "C:\Users\hp\Desktop\Thesis\Stata procedure\01. Data\01.2 Intermediate data"
save "${intdata}/landrural_w1_int.dta", replace

/*==============================================================================
 3.Generate rural land ownership and security variable
==============================================================================*/
clear all
global intdata= "C:\Users\hp\Desktop\Thesis\Stata procedure\01. Data\01.2 Intermediate data"
use "${intdata}/landrural_w1_int.dta"
keep folio secuencia su06_1a-su09_1

*------------3.1: Relabel members own plot vars
local numeros su06_1a su06_1b su06_1c su06_1d su06_1e su06_1f su06_1g su06_1h su06_1i su06_1k
foreach numero of local numeros {
    replace `numero' = 1 if `numero'>1 & `numero'!=.
} 	

*------------3.2: Generate number of plots owned by the hh
egen count_hhown= rowtotal(su06_1a-su06_1i su06_1k)

*------------3.3: Plot owner hh variable
gen hh_land=1 if count_hhown>0 & count_hhown!=.
replace hh_land=0 if count_hhown==0
tab hh_land, miss

*------------3.3.1: Replace those that did not register plot by plot ownership
replace hh_land=1 if (hh_land==0 & su08==1) | (hh_land==0 & su08==2)

*------------3.3.2: Replace those that did not register plot by plot ownership
replace hh_land=1 if (hh_land==0 & su09_1==1) | (hh_land==0 & su09_1==2) | ///
(hh_land==0 & su09_1==3)

*------------3.4: Generate tenure security variable
gen hh_document=1 if (su09_1==1 & hh_land==1 | su09_1==2 & hh_land==1 | su09_1==3 & hh_land==1)
replace hh_document=0 if (su09_1==4 & hh_land==1 | su09_1==. & hh_land==1)

*------------3.5: Save dataset
global finaldata= "C:\Users\hp\Desktop\Thesis\Stata procedure\01. Data\01.3 Final data"
save "${finaldata}/landrural_w1_fin.dta", replace

/*==============================================================================
                                    URBAN HH
==============================================================================*/
/*==============================================================================
                     Wave 1 or period t-1 (Household level)
==============================================================================*/

/*==============================================================================
 4.General setup / Work environment (Wave 1)                                  
==============================================================================*/
set more off , perm
clear all
global rawdata= "C:\Users\hp\Desktop\Thesis\Stata procedure\01. Data\01.1 Raw data\Wave I\Household\hh02dta_bc - Book C (Control book) W1"

/*==============================================================================
 5.Import (Wave 1)                                                            
==============================================================================*/

use "${rawdata}/c_cv.dta"
numlabel, add

/*==============================================================================
 6.Add label variables    
==============================================================================*/

*------------6.1: Define house property status label
label define houseprop 1"You are currently paying it" 2"Of your own and fully paid" ///
3"Of your own ejido or community land" 4"Borrowed or given without payment" ///
5"Rented" 6"Other" 
label values cv02_1 houseprop

*------------6.2: Save intermediate dataset
global intdata= "C:\Users\hp\Desktop\Thesis\Stata procedure\01. Data\01.2 Intermediate data"
save "${intdata}/housepropurban_w1_int.dta", replace

/*==============================================================================
 7.Generate urban house property variable
==============================================================================*/
clear all
global intdata= "C:\Users\hp\Desktop\Thesis\Stata procedure\01. Data\01.2 Intermediate data"
use "${intdata}/housepropurban_w1_int.dta"
keep folio cv02_1

*------------7.1: Generate house property variable
gen hh_house=1 if (cv02_1==2 | cv02_1==3)
replace hh_house=0 if (cv02_1==1 | cv02_1==4 | cv02_1==5 | cv02_1==6)
tab hh_house

*------------7.2: Save dataset
global finaldata= "C:\Users\hp\Desktop\Thesis\Stata procedure\01. Data\01.3 Final data"
save "${finaldata}/housepropurban_w1_fin.dta", replace

