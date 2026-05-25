/*==============================================================================

                      Cleaning individual datasets                          
==============================================================================*/
/*

Project:               (Im)mobility in Mexico
Database:              Mexico Life Survey - Wave 1, 2 and 3
Level:                 Household and Individual databases
Books:                 Several
Subsection:            Several
Dofile author:         Gabriela Judith López Gutiérrez
Creation date:         May 2026 /25
Modification date:     
Product 1:             Merge employment outcomes with demographic data

*/

/*==============================================================================
                            Wave 1 or period t-1
==============================================================================*/

/*==============================================================================
 1.Generate merging codes
==============================================================================*/

*------------1.1: Generate codes for demographic hh data
clear all
global finaldata= "C:\Users\hp\Desktop\Thesis\Stata procedure\01. Data\01.3 Final data"
use "${finaldata}/demographics_w1_fin.dta"
numlabel, add

tostring folio, gen(folio_str) format(%15.0f)
tostring ls, gen(ls_str)
gen individual_id = folio_str + "_" + ls_str

global mergeddata= "C:\Users\hp\Desktop\Thesis\Stata procedure\01. Data\01.4 Merged data"
save "${mergeddata}/demographics_w1_fmerge.dta", replace

*------------1.2: Generate codes for employment outcomes

clear all
global finaldata= "C:\Users\hp\Desktop\Thesis\Stata procedure\01. Data\01.3 Final data"
use "${finaldata}/employment_w1_fin.dta"
numlabel, add

tostring folio, gen(folio_str) format(%15.0f)
tostring ls, gen(ls_str)
gen individual_id = folio_str + "_" + ls_str

global mergeddata= "C:\Users\hp\Desktop\Thesis\Stata procedure\01. Data\01.4 Merged data"
save "${mergeddata}/employment_w1_fmerge.dta",replace

/*==============================================================================
 2.Merge and save
==============================================================================*/
cd "C:\Users\hp\Desktop\Thesis\Stata procedure\01. Data\01.4 Merged data"
merge 1:1 individual_id using demographics_w1_fmerge.dta
global mergeddata= "C:\Users\hp\Desktop\Thesis\Stata procedure\01. Data\01.4 Merged data"

*Verify that only kids did not merge as "TB - Employment" is only recorded for adults in hh
tab age_cat _merge, miss
save "${mergeddata}/empl_and_demo_w1merged.dta", replace
