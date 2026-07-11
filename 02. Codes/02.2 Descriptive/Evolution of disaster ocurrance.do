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
Creation date:         July 2026 /07
Modification date:     
Product 1:             Obtain figure 1 evolution of disaster occurrance globally
Product 2:             Obtain figure 2 evolution of disaster occurrance regionally


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

*---------1.1: Keep only most influential climate hazards
keep if DisasterType == "Drought" | DisasterType == "Flood" ///
| DisasterType == "Storm"| DisasterType == "Extreme temperature"

*---------1.2: Keep only relevant variables
keep DisasterType Country Subregion Region StartYear StartMonth EndYear EndMonth TotalDeaths NoInjured NoAffected NoHomeless TotalAffected ReconstructionCosts000US ReconstructionCostsAdjusted InsuredDamage000US InsuredDamageAdjusted000U TotalDamage000US TotalDamageAdjusted000US

/*==============================================================================
 2.Labeling variables and categories                                                         
==============================================================================*/

*---------2.1: Disaster type

gen DisasterType_cat=.
replace DisasterType_cat = 1 if DisasterType == "Flood"
replace DisasterType_cat = 2 if DisasterType == "Storm"
replace DisasterType_cat = 3 if DisasterType == "Extreme temperature"
replace DisasterType_cat = 4 if DisasterType == "Drought"

label define disaster_lbl 1 "Flood" 2 "Storm" 3"Extreme temperature" ///
4"Drought" 

label values DisasterType_cat disaster_lbl
order DisasterType_cat, after (DisasterType)
drop DisasterType
label var DisasterType_cat "Disaster type"

*---------2.2: Region
gen Region_cat = .
replace Region_cat = 1 if Region == "Africa"
replace Region_cat = 2 if Region == "Americas"
replace Region_cat = 3 if Region == "Asia"
replace Region_cat = 4 if Region == "Europe"
replace Region_cat = 5 if Region == "Oceania"

label define region_lbl 1 "Africa" 2 "Americas" 3 "Asia" 4 "Europe" ///
5 "Oceania"

label values Region_cat region_lbl
order Region_cat, after (Region)
drop Region
label var Region_cat "Region"

*---------2.3: Subregion

gen Subregion_cat = .

replace Subregion_cat = 1 if Subregion == "Central Asia"
replace Subregion_cat = 2 if Subregion == "Eastern Asia"
replace Subregion_cat = 3 if Subregion == "South-eastern Asia"
replace Subregion_cat = 4 if Subregion == "Southern Asia"
replace Subregion_cat = 5 if Subregion == "Western Asia"
replace Subregion_cat = 6 if Subregion == "Eastern Europe"
replace Subregion_cat = 7 if Subregion == "Northern Europe"
replace Subregion_cat = 8 if Subregion == "Southern Europe"
replace Subregion_cat = 9 if Subregion == "Western Europe"
replace Subregion_cat = 10 if Subregion == "Northern America"
replace Subregion_cat = 11 if Subregion == "Latin America and the Caribbean"
replace Subregion_cat = 12 if Subregion == "Northern Africa"
replace Subregion_cat = 13 if Subregion == "Sub-Saharan Africa"

replace Subregion_cat = 14 if inlist(Subregion, "Australia and New Zealand", ///
"Melanesia", "Micronesia", "Polynesia")

label define subregion_lbl 1 "Central Asia" 2 "Eastern Asia" 3 "South-eastern Asia" ///
4 "Southern Asia" 5 "Western Asia" 6 "Eastern Europe" 7 "Northern Europe" ///
8 "Southern Europe" 9 "Western Europe" 10 "Northern America" ///
11 "Latin America and the Caribbean" 12 "Northern Africa" ///
13 "Sub-Saharan Africa"  14 "Others"

label values Subregion_cat subregion_lbl
order Subregion_cat, after(Subregion)
drop Subregion
label var Subregion_cat "Subregion"

/*==============================================================================
 3.Graph 1. Evolutation worldwide                                                     
==============================================================================*/
gen n=1

preserve
collapse (count) n, by(StartYear DisasterType_cat)
drop if StartYear>=2026
drop if StartYear<1980

ssc install palettes
ssc install colrspace
graph set window fontface "Garamond"
colorpalette Set1, select(1/3 5)
cd "C:\Users\hp\Desktop\Thesis\Stata procedure\03. Output\03.2 Figures"

twoway ///
(line n StartYear if DisasterType_cat==1, lcolor(black) ///
    lwidth(medthick) lpattern(line)) ///
(line n StartYear if DisasterType_cat==2, lcolor(navy) lwidth(medthick) ///
    lpattern(longdash)) ///
(line n StartYear if DisasterType_cat==3, lcolor(green) lwidth(medthick) ///
     lpattern(dash)) ///
(line n StartYear if DisasterType_cat==4, lcolor(gray) lwidth(medthick) ///
     lpattern(shortdash)), ///
legend(order(1 "Flood" 2 "Storm" 3 "Extreme temperature" 4 "Drought") ///
    rows(1) position(6) ring(1) region(lcolor(none) fcolor(none)) ///
    size(small)) ///
xtitle("Year", size(small)) ///
ytitle("Number of disasters", size(small)) ///
xlabel(1980(2)2025, angle(90) labsize(small) nogrid) ///
ylabel(0(50)250, angle(horizontal) labsize(small) nogrid) ///
graphregion(color(white)) ///
plotregion(color(white)) ///
xscale(range(1980 2025)) ///
yscale(range(0 250)) ///
title("") ///
note("")
graph export fig1_emdat_evol2.svg, replace

restore

/*==============================================================================
 3.Graph 1.1 Evolutation by subregions
==============================================================================*/
gen n=1

*---------2.4: Analytical subregions (World Bank subregions classification 
* to align with OPHI & UNDP 2025 Multidimensional poverty report)

gen AnalyticalRegion = .
* 1. Sub-Saharan Africa
replace AnalyticalRegion = 1 if Subregion_cat == 13
* 2. South Asia
replace AnalyticalRegion = 2 if Subregion_cat == 4
* 3. East Asia and the Pacific
replace AnalyticalRegion = 3 if inlist(Subregion_cat, 2, 3, 14)
* 4. Arab States
replace AnalyticalRegion = 4 if inlist(Subregion_cat, 5, 12)
* 5. Latin America and the Caribbean
replace AnalyticalRegion = 5 if Subregion_cat == 11
* 6. Europe and Central Asia
replace AnalyticalRegion = 6 if inlist(Subregion_cat, 1, 6, 7, 8, 9)
* 7. North America (optional)
replace AnalyticalRegion = 7 if Subregion_cat == 10

label define analytical_lbl 1 "Sub-Saharan Africa" 2 "South Asia" ///
3 "East Asia and the Pacific" 4 "Arab States" ///
5 "Latin America and the Caribbean" 6 "Europe and Central Asia" ///
7 "North America"

label values AnalyticalRegion analytical_lbl
label var AnalyticalRegion "Analytical region"
order AnalyticalRegion, after(Subregion_cat)

preserve
collapse (count) n, by(StartYear DisasterType_cat AnalyticalRegion)
drop if StartYear>=2026
drop if StartYear<1980
drop if AnalyticalRegion==7

graph set window fontface "Garamond"
colorpalette Set1, select(1/3 5)

drop if StartYear < 1980
drop if StartYear >= 2026

cd "C:\Users\hp\Desktop\Thesis\Stata procedure\03. Output\03.2 Figures"

twoway ///
(line n StartYear if DisasterType_cat==1, lcolor(black) ///
    lwidth(medthin) lpattern(solid)) ///
(line n StartYear if DisasterType_cat==2, lcolor(navy) ///
    lwidth(medthin) lpattern(solid)) ///
(line n StartYear if DisasterType_cat==3, lcolor(green) ///
    lwidth(medthin) lpattern(solid)) ///
(line n StartYear if DisasterType_cat==4, lcolor(gs8) ///
    lwidth(medthin) lpattern(solid)), ///
by(AnalyticalRegion, cols(2) yrescale note("") graphregion(color(white))) ///
legend(order(1 "Flood" 2 "Storm" 3 "Extreme temperature" 4 "Drought") ///
       rows(1) position(6) ring(1) region(lcolor(none) fcolor(none)) ///
       size(small)) ///
xtitle("Year", size(small)) ytitle("Number of disasters", size(small)) ///
xlabel(1980(10)2020, angle(0) labsize(vsmall) nogrid) ///
ylabel(, angle(horizontal) labsize(vsmall) nogrid) ///
graphregion(color(white)) plotregion(color(white)) ///
title("") ///
note("") ///
xsize(8) ///
ysize(10)

graph export fig2_analytical_regions.svg, replace

restore