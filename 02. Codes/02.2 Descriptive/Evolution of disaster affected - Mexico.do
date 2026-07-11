/*==============================================================================
                      Bulding background figures                          
==============================================================================*/
/*

Project:               (Im)mobility in Mexico
Database:              EM-DAT dataset
Level:                 Not applicable (macro data)
Books:                 Not applicable (macro data)
Subsection:            Not applicable (macro data)
Dofile author:         Gabriela Judith López Gutiérrez
Creation date:         July 2026 /08
Modification date:     
Product 1:             Obtain figure 3 evolution of affected for Mexico

*/
/*==============================================================================
 0.General setup / Work environment (Wave 1)                                  
==============================================================================*/

clear all
global rawdata= "C:\Users\hp\Desktop\Dissertation\Dissertation procedure\01. Data\01.1 Raw data\EM-DAT"
set more off , perm

/*==============================================================================
 1.Import (global data) and keep only relevant data                                                          
==============================================================================*/
import excel "${rawdata}/public_emdat_custom_request_international.xlsx", firstrow clear
numlabel, add

keep if Country=="Mexico"

preserve
collapse (sum) NoAffected NoHomeless NoInjured TotalAffected, by(StartYear)
drop if StartYear>=2026
drop if StartYear<2008

cd "C:\Users\hp\Desktop\Dissertation\Dissertation procedure\01. Data\01.3 Final data"
save "${finaldata}\affected_wide_mexico.dta", replace
export excel using affected_wide_mexico, firstrow(variables) replace