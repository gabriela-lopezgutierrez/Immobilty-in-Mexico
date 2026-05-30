/*==============================================================================
                      Generating variables                      
==============================================================================*/
/*

Project:               (Im)mobility in Mexico
Database:              Mexico Life Survey - Wave 1, 2 and 3
Level:                 Household databases
Book:                  II - Household economy
Subsection:            AH - Household assets
Dofile author:         Gabriela Judith López Gutiérrez
Creation date:         May 2026 /30
Modification date:     
Product 1:             Produce household asset index
*/

/*==============================================================================
                            Wave 1 or period t-1
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

use "${rawdata}/ii_ah.dta"
numlabel, add

/*==============================================================================
 2.Add label variables    
==============================================================================*/

*------------2.1: Define yesno dataset
label define yesno 1"Yes" 3"No"
foreach var in ah03a-ah03n {
    label values `var' yesno
}

*------------2.2: Save intermediate dataset
global intdata= "C:\Users\hp\Desktop\Thesis\Stata procedure\01. Data\01.2 Intermediate data"
save "${intdata}/hhassets_w1_int.dta", replace

/*==============================================================================
 3.Generate hh assets index   
==============================================================================*/
clear all
global intdata= "C:\Users\hp\Desktop\Thesis\Stata procedure\01. Data\01.2 Intermediate data"
use "${intdata}/hhassets_w1_int.dta"
keep folio-ah03n

*------------3.1: Relabel asset variables
local numeros ah03a ah03b ah03c ah03d ah03e ah03f ah03g ah03h ah03i ///
ah03j ah03k ah03l ah03m ah03n
foreach numero of local numeros {
    replace `numero' = 0 if `numero' == 3
} 	

label define yesno2 1"Yes" 0"No"
foreach var in ah03a-ah03n {
    label values `var' yesno2
}

*------------3.2: Count number of equipment
egen assets = rsum (ah03a-ah03n)
lab var assets "Number of equipment of the household"

*------------3.3: Merge with weights
tostring folio, gen(folio_str) format(%15.0f)
rename folio_str folio_str2
merge 1:1 folio_str2 using "C:\Users\hp\Desktop\Thesis\Stata procedure\01. Data\01.1 Raw data\Wave I\Household\hh02dta_b2 - Book 2 (Household Economy) W1\hh02w_b2.dta"

*------------3.4: Replace missing values
local numeros ah03a ah03b ah03c ah03d ah03e ah03f ah03g ah03h ah03i ///
ah03j ah03k ah03l ah03m ah03n
foreach numero of local numeros {
    replace `numero' = 0 if `numero' == .
} 

*------------3.5: Generate asset index and quintiles
factor ah03a-ah03n [aw = factor_b2], pcf
predict asset_index

drop if _merge==2
xtile h_riq = asset_index [aw = factor_b2], nq(5)
tab h_riq, miss
tabstat asset_index , by(h_riq) miss stats(mean) 

*------------3.6: Generate binary capability
gen immob_asset1=1 if assets>6 & assets!=.
replace immob_asset1=0 if assets<=6
gen immob_asset2=1 if h_riq>3
replace immob_asset2=0 if h_riq<3

*------------3.7: Label binary asset capability vars
label define asset_lbl 0 "Low capability (asset proxy)" 1"High capability (asset proxy)"
label values immob_asset1 asset_lbl
label values immob_asset2 asset_lbl

*------------3.8: Save dataset
global finaldata= "C:\Users\hp\Desktop\Thesis\Stata procedure\01. Data\01.3 Final data"
save "${finaldata}/hhassets_w1_fin.dta", replace


