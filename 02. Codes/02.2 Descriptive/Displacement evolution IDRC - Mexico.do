/*==============================================================================
                      Bulding background figures                          
==============================================================================*/
/*

Project:               (Im)mobility in Mexico
Database:              IDRC Data
Level:                 Not applicable (macro data)
Books:                 Not applicable (macro data)
Subsection:            Not applicable (macro data)
Dofile author:         Gabriela Judith López Gutiérrez
Creation date:         July 2026 /08
Modification date:     
Product 1:             Obtain figure 4 evolution of CID for Mexico


*/
/*==============================================================================
 0.General setup / Work environment (Wave 1)                                  
==============================================================================*/

clear all
global rawdata= "C:\Users\hp\Desktop\Dissertation\Dissertation procedure\01. Data\01.1 Raw data\IDRC data"
set more off , perm

/*==============================================================================
 1.Import (global data) and keep only relevant data                                                          
==============================================================================*/
import excel "${rawdata}/IDMC_GIDD_Disasters_Internal_Displacement_Data_Mexico.xlsx", firstrow clear
numlabel, add

/*==============================================================================
 2.Labeling variables and categories                                                         
==============================================================================*/

*---------2.1: Disaster type

gen DisasterType_cat=.
replace DisasterType_cat = 1 if HazardType == "Flood"
replace DisasterType_cat = 2 if HazardType == "Storm"
replace DisasterType_cat = 3 if HazardType == "Earthquake"
replace DisasterType_cat = 4 if HazardType == "Mass Movement"
replace DisasterType_cat = 5 if HazardType == "Volcanic activity"
replace DisasterType_cat = 6 if HazardType == "Wildfire"
replace DisasterType_cat = 7 if HazardType == "Extreme Temperature"

label define disaster_lbl 1 "Flood" 2 "Storm" 3"Earthquake" 4"Mass movement" ///
5"Volcanic activity" 6"Wildfire"  7"Extreme temperature"

label values DisasterType_cat disaster_lbl
order DisasterType_cat, after (HazardType)
drop HazardType
label var DisasterType_cat "Disaster type"

/*==============================================================================
 3.Graph 1. Evolutation worldwide                                                     
==============================================================================*/
gen n=1

preserve

ssc install palettes
ssc install colrspace
graph set window fontface "Garamond"
colorpalette Set1, select(1/3 5)
cd "C:\Users\hp\Desktop\Dissertation\Dissertation procedure\03. Output\03.2 Figures"

*------------:Collapse to annual totals by disaster type
collapse (sum) DisasterInternalDisplacements, by(Year DisasterType_cat)

*------------: Reshape to wide format
reshape wide DisasterInternalDisplacements, i(Year) j(DisasterType_cat)

foreach v of varlist DisasterInternalDisplacements1-DisasterInternalDisplacements7 {
    replace `v' = 0 if missing(`v')
}

gen y1 = DisasterInternalDisplacements1
gen y2 = y1 + DisasterInternalDisplacements2
gen y3 = y2 + DisasterInternalDisplacements3
gen y4 = y3 + DisasterInternalDisplacements4
gen y5 = y4 + DisasterInternalDisplacements5
gen y6 = y5 + DisasterInternalDisplacements6
gen y7 = y6 + DisasterInternalDisplacements7

gen Total_lbl = string(y7,"%12.0fc")


cd "C:\Users\hp\Desktop\Dissertation\Dissertation procedure\01. Data\01.3 Final data"
save displacement_wide_mexico.dta, replace
export excel displacement_wide_mexico, firstrow(variables) replace


twoway (bar y1 Year, barw(0.75)  color(navy) lcolor(none)) ///
 (rbar y1 y2 Year, barw(0.75) color(teal) lcolor(none)) ///
 (rbar y2 y3 Year, barw(0.75) color(forest_green) lcolor(none)) ///
 (rbar y3 y4 Year, barw(0.75) color(sand) lcolor(none)) ///
 (rbar y4 y5 Year, barw(0.75) color(black) lcolor(none)) ///
 (rbar y5 y6 Year, barw(0.75) color(eltblue) lcolor(none)) ///
 (rbar y6 y7 Year, barw(0.75) color(oliveteal) lcolor(none)) ///
(scatter y7 Year, msymbol(none) mlabel(Total_lbl) mlabposition(12) mlabgap(2) ///
  mlabangle(90) mlabsize(vsmall) mlabcolor(black)), ///
legend(order(1 "Flood" 2 "Storm" 3 "Earthquake" 4 "Mass movement" ///
             5 "Volcanic activity" 6 "Wildfire" 7 "Extreme temperature") ///
       rows(2) position(6) size(vsmall) region(lcolor(none) fcolor(none))) ///
xtitle("Year", size(small)) ///
ytitle("Internally displaced people", size(small) margin(large)) ///
xlabel(2008(1)2025, angle(90) labsize(small) nogrid) ///
ylabel(0(200000)1000000, format(%12.0fc) angle(horizontal) labsize(small) ///
       nogrid) ///
yscale(range(0 1100000)) ///
graphregion(color(white) margin(l-9 r+2)) ///
plotregion(color(white)) ///
title("") ///
note("")

graph export fig4_displacementevolmex.svg, replace

restore
restore